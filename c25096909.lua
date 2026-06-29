--連慄砲固定式
-- 效果：
-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。
-- ●选对方场上1只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的1只超量怪兽和1只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
local s,id,o=GetID()
-- 注册卡片发动时将额外怪兽除外，并可回收除外怪兽以除外对方场上所有卡片的效果
function s.initial_effect(c)
	-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。●选对方场上1只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的1只超量怪兽和1只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 从额外卡组除外2只相同阶级超量怪兽和1只融合怪兽的组合与数量合法性检查
function s.rcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==2 and g:IsExists(s.xyzfilter,1,nil,g)
end
-- 检查被选中的卡片中是否存在至少2只相同阶级的超量怪兽
function s.xyzfilter(c,g)
	return g:IsExists(Card.IsRank,1,c,c:GetRank())
end
-- 获取怪兽卡片的等级或超量怪兽的阶级数值
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 卡片发动的准备与可用性检查
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算双方玩家场上以及手牌中的卡片合计数量
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取自己额外卡组中所有可被除外的融合与超量怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if chk==0 then return g and g:CheckSubGroup(s.rcheck,3,3,ct) end
	-- 设置操作信息为从额外卡组除外3张卡片
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end
-- 以对方表侧怪兽的等级/阶级为基准，检查自己除外怪兽是否能满足回收的过滤条件
function s.lrfilter(c,tp)
	-- 获取自己除外状态中所有可返回额外卡组 the fusion and xyz monsters
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
	local lr=0
	if c:IsType(TYPE_XYZ) then lr=c:GetRank() else lr=c:GetLevel() end
	return c:IsFaceup() and g:CheckSubGroup(s.lrcheck,2,2,lr)
end
-- 检查被选中的回收卡片是否为1只超量和1只融合，且它们的等级与阶级数值合计等于对方怪兽的等级或阶级
function s.lrcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==g:FilterCount(Card.IsType,nil,TYPE_FUSION)
end
-- 卡片效果的执行
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算双方玩家场上及手牌的当前卡片合计数量
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 获取自己额外卡组中可被除外的融合与超量怪兽
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	-- 向玩家发送提示，请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rcheck,false,3,3,ct)
	-- 若成功从额外卡组选择并除外3只符合条件的怪兽，则继续处理
	if not sg or Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=3 then return end
	-- 若对方场上存在表侧表示怪兽且满足回收条件，询问玩家是否回收怪兽并除外对方卡片
	if Duel.IsExistingMatchingCard(s.lrfilter,tp,0,LOCATION_MZONE,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收怪兽并除外对方的卡？"
		-- 切断效果处理的连锁时点
		Duel.BreakEffect()
		-- 选择对方场上1只表侧表示怪兽作为等级/阶级的对照基准
		local tc=Duel.SelectMatchingCard(tp,s.lrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		-- 获取自己除外状态中的所有融合与超量怪兽
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
		local lr=0
		if tc:IsType(TYPE_XYZ) then lr=tc:GetRank() else lr=tc:GetLevel() end
		local rg=tg:SelectSubGroup(tp,s.lrcheck,false,2,2,lr)
		if rg then
			-- 向对方玩家确认并展示被选为回收目标的除外怪兽
			Duel.ConfirmCards(1-tp,rg)
			-- 将选中的2只怪兽返回额外卡组
			if Duel.SendtoDeck(rg,nil,1,REASON_EFFECT)==2 then
				-- 在回收成功后切断连锁以准备除外对方卡片
				Duel.BreakEffect()
				-- 获取对方场上所有可被除外的卡片
				local qg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,POS_FACEUP)
				-- 将对方场上的所有卡片全部除外
				Duel.Remove(qg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
