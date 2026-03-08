--ネオ・カイザー・グライダー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只怪兽丢弃，以自己墓地1只龙族通常怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降500。
function c45885288.initial_effect(c)
	-- ①：从手卡把这张卡和1只怪兽丢弃，以自己墓地1只龙族通常怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45885288,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45885288)
	e1:SetCost(c45885288.spcost)
	e1:SetTarget(c45885288.sptg)
	e1:SetOperation(c45885288.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45885288,1))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,45885289)
	e2:SetTarget(c45885288.atktg)
	e2:SetOperation(c45885288.atkop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手牌中是否包含可丢弃的怪兽
function c45885288.cfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动时的费用支付处理，检查手牌中是否存在可丢弃的怪兽
function c45885288.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable()
		-- 检查手牌中是否存在可丢弃的怪兽
		and Duel.IsExistingMatchingCard(c45885288.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向玩家提示选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择满足条件的手牌
	local g=Duel.SelectMatchingCard(tp,c45885288.cfilter,tp,LOCATION_HAND,0,1,1,c)
	g:AddCard(c)
	-- 将选择的手牌送去墓地作为费用
	Duel.SendtoGrave(g,REASON_DISCARD+REASON_COST)
end
-- 过滤函数，用于判断墓地中的怪兽是否为龙族通常怪兽且可特殊召唤
function c45885288.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果的发动宣言处理，检查墓地中是否存在满足条件的怪兽
function c45885288.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c45885288.filter(chkc,e,tp) end
	-- 检查场上是否存在可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c45885288.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为目标
	local g=Duel.SelectTarget(tp,c45885288.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果的处理执行，将目标怪兽特殊召唤
function c45885288.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动时的处理，检查对方场上是否存在表侧表示的怪兽
function c45885288.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果的处理执行，使对方场上所有表侧表示怪兽的攻击力下降500
function c45885288.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为对方场上所有表侧表示的怪兽设置攻击力下降500的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
