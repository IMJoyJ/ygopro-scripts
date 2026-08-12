--極炎舞－「星斗」
-- 效果：
-- 把自己墓地7张名字带有「炎舞」的魔法·陷阱卡从游戏中除外才能发动。从自己墓地把名字带有「炎星」的怪兽尽可能特殊召唤。那之后，可以从卡组选最多有这个效果特殊召唤的怪兽数量的「极炎舞-「星斗」」以外的名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。
function c6713443.initial_effect(c)
	-- 把自己墓地7张名字带有「炎舞」的魔法·陷阱卡从游戏中除外才能发动。从自己墓地把名字带有「炎星」的怪兽尽可能特殊召唤。那之后，可以从卡组选最多有这个效果特殊召唤的怪兽数量的「极炎舞-「星斗」」以外的名字带有「炎舞」的魔法·陷阱卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SSET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c6713443.spcost)
	e1:SetTarget(c6713443.sptg)
	e1:SetOperation(c6713443.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：自己墓地名字带有「炎舞」的魔法·陷阱卡，且可以作为发动代价除外
function c6713443.cfilter(c)
	return c:IsSetCard(0x7c) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 发动代价处理：检查并从自己墓地将7张「炎舞」魔法·陷阱卡除外
function c6713443.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否存在至少7张满足条件的「炎舞」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c6713443.cfilter,tp,LOCATION_GRAVE,0,7,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择7张满足条件的「炎舞」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c6713443.cfilter,tp,LOCATION_GRAVE,0,7,7,nil)
	-- 将选中的卡片作为发动代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤函数：自己墓地名字带有「炎星」且可以特殊召唤的怪兽
function c6713443.filter(c,e,tp)
	return c:IsSetCard(0x79) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动准备：检查怪兽区域空位以及墓地是否存在可特召的「炎星」怪兽，并设置特殊召唤的操作信息
function c6713443.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只可以特殊召唤的「炎星」怪兽
		and Duel.IsExistingMatchingCard(c6713443.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息（从墓地特殊召唤至少1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 过滤函数：卡组中「极炎舞-「星斗」」以外的名字带有「炎舞」且可以盖放的魔法·陷阱卡
function c6713443.sfilter(c)
	return c:IsSetCard(0x7c) and not c:IsCode(6713443) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 过滤函数：用于选择盖放的卡片组，确保场地魔法卡不超过1张，且普通魔陷数量不超过魔陷区空位数
function c6713443.fselect(g,ft)
	local fc=g:FilterCount(Card.IsType,nil,TYPE_FIELD)
	return fc<=1 and #g-fc<=ft
end
-- 效果处理：尽可能特殊召唤墓地的「炎星」怪兽，之后可选择从卡组盖放对应数量的「炎舞」魔法·陷阱卡
function c6713443.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取自己墓地所有满足特殊召唤条件的「炎星」怪兽
	local tg=Duel.GetMatchingGroup(c6713443.filter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if ft<=0 or tg:GetCount()==0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local g=tg:Select(tp,ft,ft,nil)
	-- 将选中的怪兽表侧表示特殊召唤，并获取成功特殊召唤的数量
	local ct=Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	if ct>0 then
		-- 获取自己场上可用的魔法·陷阱区域空格数
		local ft2=Duel.GetLocationCount(tp,LOCATION_SZONE)
		-- 获取卡组中所有满足盖放条件的「炎舞」魔法·陷阱卡
		local sg=Duel.GetMatchingGroup(c6713443.sfilter,tp,LOCATION_DECK,0,nil)
		-- 如果卡组有符合条件的卡，询问玩家是否要从卡组盖放「炎舞」魔法·陷阱卡
		if sg:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(6713443,0)) then  --"是否要选择名字带有「炎舞」的魔法·陷阱卡在自己场上盖放？"
			-- 中断当前效果，使后续的盖放处理不与特殊召唤同时处理
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local setg=sg:SelectSubGroup(tp,c6713443.fselect,false,1,math.min(ct,ft2+1),ft2)
			-- 将选中的魔法·陷阱卡在自己场上盖放
			Duel.SSet(tp,setg)
		end
	end
end
