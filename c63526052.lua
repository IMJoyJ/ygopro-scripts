--クローラー・ソゥマ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。这个回合，作为对象的怪兽不能把表示形式变更。
-- ②：自己主要阶段才能发动。这张卡的等级下降2星或者4星，等级合计直到变成和下降数值相同为止，从自己的手卡·卡组·墓地选「机怪虫」怪兽表侧守备表示或里侧守备表示特殊召唤（同名卡最多1张）。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以自己场上1只表侧表示怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽变成里侧守备表示。这个回合，作为对象的怪兽不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.hsptg)
	e1:SetOperation(s.hspop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。这张卡的等级下降2星或者4星，等级合计直到变成和下降数值相同为止，从自己的手卡·卡组·墓地选「机怪虫」怪兽表侧守备表示或里侧守备表示特殊召唤（同名卡最多1张）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤自己场上可以变成里侧守备表示的表侧表示怪兽
function s.filter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- 效果①（手卡特殊召唤并使对象怪兽转为里侧守备表示）的发动准备与合法性检测
function s.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在可以变成里侧守备表示的表侧表示怪兽
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置改变对象怪兽表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 效果①（手卡特殊召唤并使对象怪兽转为里侧守备表示）的效果处理
function s.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查怪兽区域是否有空位且自身卡片仍与效果相关联
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e)
		-- 将这张卡从手卡表侧表示特殊召唤，并判断是否特殊召唤成功
		and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取效果①所选择的对象怪兽
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 将作为对象的怪兽变成里侧守备表示
			Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
			-- 这个回合，作为对象的怪兽不能把表示形式变更。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
		end
	end
end
-- 过滤手卡·卡组·墓地中等级在0到4之间、可以守备表示特殊召唤的「机怪虫」怪兽
function s.spfilter(c,e,tp)
	return c:IsLevelAbove(0) and c:IsLevelBelow(4) and c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 检查所选怪兽组的等级合计是否等于下降的数值
function s.gselect(sg,lv)
	return sg:GetSum(Card.GetLevel)==lv
end
-- 辅助检查函数，用于确保所选怪兽组内没有同名卡，且等级合计不超过下降的数值
function s.gcheck(lv)
	return	function(sg)
				-- 检查怪兽组内卡名各不相同，且等级合计不超过目标数值
				return aux.dncheck(sg) and sg:GetSum(Card.GetLevel)<=lv
			end
end
-- 效果②（下降等级并特殊召唤「机怪虫」怪兽）的发动准备与合法性检测
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local clv=c:GetLevel()
		if clv<=2 then return false end
		-- 获取自己场上可用的怪兽区域数量
		local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
		if ft<=0 then return false end
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
		-- 获取手卡·卡组·墓地中所有符合特殊召唤条件的「机怪虫」怪兽
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
		-- 设置辅助检查条件，限制选择的怪兽卡名不同且等级合计不超过2
		aux.GCheckAdditional=s.gcheck(2)
		local b2=clv>2 and g:CheckSubGroup(s.gselect,1,ft,2)
		-- 设置辅助检查条件，限制选择的怪兽卡名不同且等级合计不超过4
		aux.GCheckAdditional=s.gcheck(4)
		local b4=clv>4 and g:CheckSubGroup(s.gselect,1,ft,4)
		-- 重置辅助检查条件
		aux.GCheckAdditional=nil
		return b2 or b4
	end
	-- 设置从手卡·卡组·墓地特殊召唤怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果②（下降等级并特殊召唤「机怪虫」怪兽）的效果处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local clv=c:GetLevel()
	if clv<=2 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取当前可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡·卡组·墓地中不受「王家长眠之谷」影响且符合特殊召唤条件的「机怪虫」怪兽
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	-- 设置辅助检查条件，限制选择的怪兽卡名不同且等级合计不超过2
	aux.GCheckAdditional=s.gcheck(2)
	local b2=clv>2 and g:CheckSubGroup(s.gselect,1,ft,2)
	-- 设置辅助检查条件，限制选择的怪兽卡名不同且等级合计不超过4
	aux.GCheckAdditional=s.gcheck(4)
	local b4=clv>4 and g:CheckSubGroup(s.gselect,1,ft,4)
	-- 重置辅助检查条件
	aux.GCheckAdditional=nil
	local off=1
	local ops={}
	local opval={}
	if b2 then
		ops[off]=aux.Stringid(id,2)  --"下降2星"
		opval[off-1]=2
		off=off+1
	end
	if b4 then
		ops[off]=aux.Stringid(id,3)  --"下降4星"
		opval[off-1]=4
		off=off+1
	end
	if off==1 then return end
	-- 让玩家选择下降2星或4星，并获取对应的数值
	local lv=opval[Duel.SelectOption(tp,table.unpack(ops))]
	-- 这张卡的等级下降2星或者4星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(-lv)
	c:RegisterEffect(e1)
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 设置辅助检查条件，限制选择的怪兽卡名不同且等级合计不超过选择的下降数值
	aux.GCheckAdditional=s.gcheck(lv)
	local sg=g:SelectSubGroup(tp,s.gselect,false,1,ft,lv)
	-- 重置辅助检查条件
	aux.GCheckAdditional=nil
	-- 将选中的「机怪虫」怪兽以守备表示（表侧或里侧）特殊召唤
	Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_DEFENSE)
end
