--連慄砲固定式
-- 效果：
-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。
-- ●选对方场上1只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的1只超量怪兽和1只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
local s,id,o=GetID()
-- 效果作用
function s.initial_effect(c)
	-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 检查组是否满足等级或阶级总和等于目标值且包含2只超量怪兽和1只融合怪兽
function s.rcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==2 and g:IsExists(s.xyzfilter,1,nil,g)
end
-- 检查组中是否存在与指定怪兽阶级相同的怪兽
function s.xyzfilter(c,g)
	return g:IsExists(Card.IsRank,1,c,c:GetRank())
end
-- 获取怪兽的等级或阶级值
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 效果作用
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方场上和手牌的卡数量
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取自己额外卡组中可除外的融合怪兽和超量怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if chk==0 then return g and g:CheckSubGroup(s.rcheck,3,3,ct) end
	-- 设置操作信息为除外3张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end
-- 检查对方场上是否存在满足条件的怪兽
function s.lrfilter(c,tp)
	-- 获取自己除外区中可送回额外卡组的融合怪兽和超量怪兽
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
	local lr=0
	if c:IsType(TYPE_XYZ) then lr=c:GetRank() else lr=c:GetLevel() end
	return c:IsFaceup() and g:CheckSubGroup(s.lrcheck,2,2,lr)
end
-- 检查组是否满足等级或阶级总和等于目标值且包含相同数量的超量怪兽和融合怪兽
function s.lrcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==g:FilterCount(Card.IsType,nil,TYPE_FUSION)
end
-- 效果作用
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算双方场上和手牌的卡数量
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取自己额外卡组中可除外的融合怪兽和超量怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if not g:CheckSubGroup(s.rcheck,3,3,ct) then return false end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rcheck,false,3,3,ct)
	-- 执行除外操作并判断是否成功除外3张卡
	if not sg or not Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==3 then return false end
	-- 判断对方场上是否存在满足条件的怪兽并询问是否发动后续效果
	if Duel.IsExistingMatchingCard(s.lrfilter,tp,0,LOCATION_MZONE,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收怪兽并除外对方的卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 选择对方场上的满足条件的怪兽
		local tc=Duel.SelectMatchingCard(tp,s.lrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		-- 获取自己除外区中可送回额外卡组的融合怪兽和超量怪兽
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
		local lr=0
		if tc:IsType(TYPE_XYZ) then lr=tc:GetRank() else lr=tc:GetLevel() end
		local rg=tg:SelectSubGroup(tp,s.lrcheck,false,2,2,lr)
		if rg then
			-- 确认对方查看选中的卡
			Duel.ConfirmCards(1-tp,rg)
			-- 将选中的卡送回额外卡组并判断是否成功送回2张
			if Duel.SendtoDeck(rg,nil,1,REASON_EFFECT)==2 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 获取对方场上的所有可除外卡
				local qg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,POS_FACEUP)
				-- 将对方场上的所有卡除外
				Duel.Remove(qg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
