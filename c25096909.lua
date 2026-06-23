--連慄砲固定式
-- 效果：
-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。
-- ●选对方场上1只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的1只超量怪兽和1只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
local s,id,o=GetID()
-- 注册卡片的主要效果，设置效果分类、类型、时点及处理函数。
function s.initial_effect(c)
	-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把 2 只超量怪兽（相同阶级）和 1 只融合怪兽除外。那之后，以下效果可以适用。●选对方场上 1 只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的 1 只超量怪兽和 1 只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查选择的怪兽组是否满足等级合计等于目标值、包含 2 只超量怪兽且其中有相同阶级的超量怪兽。
function s.rcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==2 and g:IsExists(s.xyzfilter,1,nil,g)
end
-- 过滤函数，检查组内是否存在另一只相同阶级的超量怪兽。
function s.xyzfilter(c,g)
	return g:IsExists(Card.IsRank,1,c,c:GetRank())
end
-- 获取怪兽的阶级（超量）或等级（非超量）。
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 效果发动时的目标检查，计算双方手卡及场上卡数，验证额外卡组是否存在符合条件的怪兽组并设置操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方手卡与场上的卡总数作为等级合计的目标值。
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取额外卡组中可以被除外的融合怪兽和超量怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if chk==0 then return g and g:CheckSubGroup(s.rcheck,3,3,ct) end
	-- 设置效果操作信息，预示将从额外卡组除外 3 张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end
-- 过滤函数，检查对方怪兽是否满足条件以触发后续回收除外怪兽并除外对方卡片的效果。
function s.lrfilter(c,tp)
	-- 获取除外状态中可以被返回额外卡组的正面表示融合怪兽和超量怪兽组。
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
	local lr=0
	if c:IsType(TYPE_XYZ) then lr=c:GetRank() else lr=c:GetLevel() end
	return c:IsFaceup() and g:CheckSubGroup(s.lrcheck,2,2,lr)
end
-- 检查选择的怪兽组等级合计是否等于目标值且超量怪兽与融合怪兽数量相等（各 1 只）。
function s.lrcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==g:FilterCount(Card.IsType,nil,TYPE_FUSION)
end
-- 效果处理函数，执行除外额外卡组怪兽的操作，并根据条件选择是否发动后续效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 再次计算双方手卡与场上的卡总数作为等级合计的目标值。
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取额外卡组中可以被除外的融合怪兽和超量怪兽组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if not g:CheckSubGroup(s.rcheck,3,3,ct) then return false end
	-- 向玩家显示提示消息，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rcheck,false,3,3,ct)
	-- 选择符合条件的怪兽组并将其除外，若除外数量不为 3 则中断处理。
	if not sg or not Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==3 then return false end
	-- 检查对方场上是否存在符合条件的怪兽并询问玩家是否发动后续效果。
	if Duel.IsExistingMatchingCard(s.lrfilter,tp,0,LOCATION_MZONE,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收怪兽并除外对方的卡？"
		-- 中断当前效果处理，使后续效果视为不同时处理。
		Duel.BreakEffect()
		-- 选择对方场上 1 只符合条件的表侧表示怪兽作为对象。
		local tc=Duel.SelectMatchingCard(tp,s.lrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		-- 获取除外状态中可以被返回额外卡组的正面表示融合怪兽和超量怪兽组。
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
		local lr=0
		if tc:IsType(TYPE_XYZ) then lr=tc:GetRank() else lr=tc:GetLevel() end
		local rg=tg:SelectSubGroup(tp,s.lrcheck,false,2,2,lr)
		if rg then
			-- 向对方玩家确认选择的怪兽卡。
			Duel.ConfirmCards(1-tp,rg)
			-- 将选择的 2 只怪兽返回额外卡组，若成功返回则继续处理。
			if Duel.SendtoDeck(rg,nil,1,REASON_EFFECT)==2 then
				-- 再次中断效果处理，使除外对方卡片的效果视为不同时处理。
				Duel.BreakEffect()
				-- 获取对方场上所有可以被除外的表侧表示卡组。
				local qg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,POS_FACEUP)
				-- 将对方场上的卡全部除外。
				Duel.Remove(qg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
