--スモール・ピース・ゴーレム
-- 效果：
-- 自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「中块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c22754505.initial_effect(c)
	-- 效果原文：自己场上有「大块石人」表侧表示存在的场合这张卡召唤·反转召唤·特殊召唤成功时，可以从自己卡组把1只「中块石人」特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22754505,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(c22754505.spcon)
	e1:SetTarget(c22754505.sptg)
	e1:SetOperation(c22754505.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 检查场上是否存在「大块石人」
function c22754505.cfilter(c)
	return c:IsFaceup() and c:IsCode(25247218)
end
-- 效果条件：自己场上有「大块石人」表侧表示存在
function c22754505.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「大块石人」
	return Duel.IsExistingMatchingCard(c22754505.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤函数：检索可以特殊召唤的「中块石人」
function c22754505.filter(c,e,tp)
	return c:IsCode(58843503) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理目标设定：确认场上是否有空位且卡组是否存在「中块石人」
function c22754505.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在「中块石人」
		and Duel.IsExistingMatchingCard(c22754505.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只「中块石人」
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：执行特殊召唤并使召唤的怪兽效果无效
function c22754505.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只「中块石人」从卡组特殊召唤
	local g=Duel.SelectMatchingCard(tp,c22754505.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 特殊召唤选定的怪兽
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
