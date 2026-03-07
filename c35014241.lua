--リミットオーバー・ドライブ
-- 效果：
-- 「破限疾驰」在1回合只能发动1张。
-- ①：让自己场上1只同调怪兽调整和1只调整以外的同调怪兽回到额外卡组才能发动。和那2只怪兽的等级合计相同等级的1只同调怪兽无视召唤条件从额外卡组特殊召唤。
function c35014241.initial_effect(c)
	-- 效果原文内容：「破限疾驰」在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,35014241+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c35014241.cost)
	e1:SetTarget(c35014241.target)
	e1:SetOperation(c35014241.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检索满足条件的调整怪兽
function c35014241.cfilter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER) and c:IsAbleToExtraAsCost()
		-- 效果作用：检查是否存在满足条件的调整以外的同调怪兽
		and Duel.IsExistingMatchingCard(c35014241.cfilter2,tp,LOCATION_MZONE,0,1,nil,e,tp,c)
end
-- 效果作用：检索满足条件的调整以外的同调怪兽
function c35014241.cfilter2(c,e,tp,tc)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and not c:IsType(TYPE_TUNER) and c:IsAbleToExtraAsCost()
		-- 效果作用：检查是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(c35014241.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,c:GetLevel()+tc:GetLevel(),Group.FromCards(c,tc))
end
-- 效果作用：检索满足条件的同调怪兽
function c35014241.spfilter(c,e,tp,lv,mg)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
		-- 效果作用：检查场上是否有足够的位置特殊召唤
		and Duel.GetLocationCountFromEx(tp,tp,mg,c)>0
end
-- 效果作用：设置发动时的处理流程
function c35014241.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	-- 效果作用：检查场上是否存在满足条件的调整怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c35014241.cfilter1,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择满足条件的调整怪兽
	local g1=Duel.SelectMatchingCard(tp,c35014241.cfilter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 效果作用：提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 效果作用：选择满足条件的调整以外的同调怪兽
	local g2=Duel.SelectMatchingCard(tp,c35014241.cfilter2,tp,LOCATION_MZONE,0,1,1,nil,e,tp,g1:GetFirst())
	e:SetLabel(g1:GetFirst():GetLevel()+g2:GetFirst():GetLevel())
	g1:Merge(g2)
	-- 效果作用：将选中的怪兽送回额外卡组作为代价
	Duel.SendtoDeck(g1,nil,SEQ_DECKTOP,REASON_COST)
end
-- 效果作用：设置效果的处理目标
function c35014241.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=1 then return false end
		e:SetLabel(0)
		return true
	end
	-- 效果作用：设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：设置效果的发动处理
function c35014241.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的同调怪兽
	local g=Duel.SelectMatchingCard(tp,c35014241.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lv,nil)
	if g:GetCount()>0 then
		-- 效果作用：将选中的同调怪兽无视召唤条件从额外卡组特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,true,false,POS_FACEUP)
	end
end
