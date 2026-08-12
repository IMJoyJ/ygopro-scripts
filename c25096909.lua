--連慄砲固定式
-- 效果：
-- ①：等级·阶级的合计直到变成和双方的手卡·场上的卡数量相同为止，从自己的额外卡组把2只超量怪兽（相同阶级）和1只融合怪兽除外。那之后，以下效果可以适用。
-- ●选对方场上1只表侧表示怪兽，等级·阶级的合计直到变成和那只怪兽的等级·阶级相同为止让自己的除外状态的1只超量怪兽和1只融合怪兽回到额外卡组。那之后，对方场上的卡全部除外。
local s,id,o=GetID()
-- 创建并注册这张卡的①效果：分类为除外+回到额外卡组，类型为魔法·陷阱卡的发动，可以在自由时点（含怪兽正面上场时和结束阶段）发动，并设定其目标检查函数与效果处理函数。
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
-- 检查选出的3张卡组合是否满足发动条件：等级·阶级合计等于双方手卡·场上的卡数量，且其中恰有2只超量怪兽，且这2只超量怪兽阶级相同。
function s.rcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==2 and g:IsExists(s.xyzfilter,1,nil,g)
end
-- 检查组g中是否存在与c阶级相同的另一只超量怪兽（用于确认除外的2只超量怪兽为相同阶级）。
function s.xyzfilter(c,g)
	return g:IsExists(Card.IsRank,1,c,c:GetRank())
end
-- 取卡的等级·阶级数值：超量怪兽取阶级，其他怪兽取等级。
function s.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 目标检查函数：统计双方手卡·场上的卡数量，检索自己额外卡组可以除外的融合·超量怪兽，检查能否选出满足条件的3张组合；可以发动时设置除外操作信息（从自己额外卡组除外3张）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计双方手卡·场上的卡的总数量，作为等级·阶级合计需要达到的目标数值。
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 从自己额外卡组检索可以表侧表示除外的融合·超量怪兽组成候选卡组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	if chk==0 then return g and g:CheckSubGroup(s.rcheck,3,3,ct) end
	-- 设置操作信息：这个效果将把自己额外卡组的3张卡除外，供对方确认连锁。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_EXTRA)
end
-- 对方场上表侧表示怪兽的过滤器：以自己除外状态可以回到额外卡组的融合·超量怪兽为候选，判断是否存在等级·阶级合计等于那只怪兽等级·阶级的1只超量怪兽和1只融合怪兽的组合。
function s.lrfilter(c,tp)
	-- 从自己除外状态的卡中检索表侧表示且可以回到额外卡组的融合·超量怪兽。
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
	local lr=0
	if c:IsType(TYPE_XYZ) then lr=c:GetRank() else lr=c:GetLevel() end
	return c:IsFaceup() and g:CheckSubGroup(s.lrcheck,2,2,lr)
end
-- 检查选出的2张卡组合是否满足条件：等级·阶级合计等于对象怪兽的等级·阶级，且其中超量怪兽和融合怪兽各1只。
function s.lrcheck(g,ct)
	return g:GetSum(s.lv_or_rk)==ct and g:FilterCount(Card.IsType,nil,TYPE_XYZ)==g:FilterCount(Card.IsType,nil,TYPE_FUSION)
end
-- 效果处理函数：统计双方手卡·场上的卡数量，检索自己额外卡组可除外的融合·超量怪兽，让玩家选出满足条件的3张并表侧表示除外；那之后若对方场上存在可选的表侧表示怪兽且玩家选择适用，选那只怪兽，让自己除外状态的1只超量怪兽和1只融合怪兽（等级·阶级合计与那只怪兽相同）给对方确认后回到额外卡组，再把对方场上的卡全部表侧表示除外。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 统计双方手卡·场上的卡的总数量，作为需要除外的怪兽等级·阶级合计的目标数值。
	local ct=Duel.GetMatchingGroupCount(nil,tp,LOCATION_ONFIELD+LOCATION_HAND,LOCATION_ONFIELD+LOCATION_HAND,nil)
	-- 从自己额外卡组检索可以表侧表示除外的融合·超量怪兽组成候选卡组。
	local g=Duel.GetMatchingGroup(Card.IsType,tp,LOCATION_EXTRA,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToRemove,nil,POS_FACEUP)
	-- 向玩家提示"请选择要除外的卡"，准备进行选卡操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:SelectSubGroup(tp,s.rcheck,false,3,3,ct)
	-- 把选出的3只怪兽以表侧表示从额外卡组除外，若未能除外3张则中断效果处理。
	if not sg or Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)~=3 then return end
	-- 检查对方场上是否存在满足条件的表侧表示怪兽，并询问玩家是否适用以下效果（回收怪兽并除外对方的卡）。
	if Duel.IsExistingMatchingCard(s.lrfilter,tp,0,LOCATION_MZONE,1,nil,tp) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then  --"是否回收怪兽并除外对方的卡？"
		-- 中断当前效果处理，使之后的处理视为不同时处理（错开时点）。
		Duel.BreakEffect()
		-- 让玩家选择对方场上1只满足条件的表侧表示怪兽作为对象。
		local tc=Duel.SelectMatchingCard(tp,s.lrfilter,tp,0,LOCATION_MZONE,1,1,nil,tp):GetFirst()
		-- 从自己除外状态的卡中检索表侧表示且可以回到额外卡组的融合·超量怪兽。
		local tg=Duel.GetMatchingGroup(aux.AND(Card.IsType,Card.IsFaceupEx),tp,LOCATION_REMOVED,0,nil,TYPE_FUSION+TYPE_XYZ):Filter(Card.IsAbleToExtra,nil)
		local lr=0
		if tc:IsType(TYPE_XYZ) then lr=tc:GetRank() else lr=tc:GetLevel() end
		local rg=tg:SelectSubGroup(tp,s.lrcheck,false,2,2,lr)
		if rg then
			-- 把选出的超量怪兽和融合怪兽给对方玩家确认。
			Duel.ConfirmCards(1-tp,rg)
			-- 把那2只怪兽送回持有者的额外卡组，若成功送回2只则继续后续处理。
			if Duel.SendtoDeck(rg,nil,1,REASON_EFFECT)==2 then
				-- 中断当前效果处理，使之后的除外处理视为不同时处理（错开时点）。
				Duel.BreakEffect()
				-- 检索对方场上全部可以表侧表示除外的卡。
				local qg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil,POS_FACEUP)
				-- 把对方场上的卡全部以表侧表示除外。
				Duel.Remove(qg,POS_FACEUP,REASON_EFFECT)
			end
		end
	end
end
