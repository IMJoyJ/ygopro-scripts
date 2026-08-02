--バリアンズ・ホープ
local s,id,o=GetID()
-- 注册效果（初始化卡片）
function s.initial_effect(c)
	-- 效果一：从手卡·墓地特殊召唤1只怪兽，并可改变其他怪兽等级
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 效果二：从墓地除外此卡为怪兽补充超量素材
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 支付把这张卡除外的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.mattg)
	e2:SetOperation(s.matop)
	c:RegisterEffect(e2)
end
-- 检查是否为可以特殊召唤的「希望皇 霍普」怪兽或超量怪兽
function s.spfilter(c,e,tp)
	return (c:IsSetCard(0x87) or c:IsSetCard(0x1e3) and c:IsType(TYPE_XYZ)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP)
end
-- 检查是否为表侧表示的等级大于1且不等于指定等级的「希望皇 霍普」怪兽
function s.cfilter1(c,lv)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1) and not c:IsLevel(lv)
end
-- 检查自己场上是否有一只表侧表示的「希望皇 霍普」怪兽，且存在可以改变等级的另一只「希望皇 霍普」怪兽
function s.cfilter2(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x87)
		and c:IsLevelAbove(1)
		-- 检查自己场上是否存在等级不等于该怪兽等级的表侧表示「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_MZONE,0,1,nil,c:GetLevel())
end
-- 检查自己场上是否有空格，并且手卡·墓地是否有满足特殊召唤条件的怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可以特殊召唤怪兽的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡·墓地是否存在可以特殊召唤的满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：预计从手卡·墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 特殊召唤选中的怪兽，之后可以选择发动变星效果
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有主要怪兽区的空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 发送选择要特殊召唤的怪兽的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地选择1只满足特殊召唤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽特殊召唤成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 检查场上或墓地是否存在可以改变等级的「希望皇 霍普」怪兽
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,tp)
		-- 让玩家选择是否发动后续的变星效果
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 中断连锁处理，使得变星效果不与特殊召唤同时发生
		Duel.BreakEffect()
		-- 发送选择表侧表示卡片的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
		-- 从场上或墓地选择1只满足条件的「希望皇 霍普」怪兽作为变星基准
		local sg=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,tp)
		-- 手动为选中的怪兽显示被选为对象的动画
		Duel.HintSelection(sg)
		local lv=sg:GetFirst():GetLevel()
		-- 获取自己场上所有等级不等于选中怪兽等级的表侧表示「希望皇 霍普」怪兽
		local tg=Duel.GetMatchingGroup(s.cfilter1,tp,LOCATION_MZONE,0,nil,lv)
		-- 遍历所有需要改变等级的怪兽
		for lc in aux.Next(tg) do
			-- 为怪兽注册等级变更为选定等级的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(lv)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			lc:RegisterEffect(e1)
		end
	end
end
-- 检查怪兽是否为表侧表示的超量怪兽
function s.matfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
-- 检查卡片是否为「No.」超量怪兽，且可以作为超量素材
function s.mtfilter(c)
	return c:IsSetCard(0x48) and c:IsType(TYPE_XYZ) and c:IsCanOverlay()
end
-- 检查自己场上是否存在超量怪兽，以及额外卡组·墓地是否存在可以作为素材的「No.」怪兽
function s.mattg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.matfilter(chkc) end
	-- 检查自己场上是否至少存在1只表侧表示的超量怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(s.matfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查额外卡组·墓地是否存在至少1只「No.」超量怪兽可以作为超量素材
		and Duel.IsExistingMatchingCard(s.mtfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,nil) end
	-- 发送选择表侧表示卡片的提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选定自己场上的1只表侧表示超量怪兽作为效果的对象
	Duel.SelectTarget(tp,s.matfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 为选定的超量怪兽附加额外卡组·墓地的「No.」超量怪兽作为超量素材
function s.matop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被选为对象的超量怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsType(TYPE_MONSTER) and tc:IsRelateToChain() and not tc:IsImmuneToEffect(e) then
		-- 发送选择要作为超量素材的卡片的提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
		-- 选择额外卡组·墓地的1只满足条件的「No.」超量怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.mtfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选定的「No.」怪兽叠放在目标怪兽下作为超量素材
			Duel.Overlay(tc,g)
		end
	end
end
