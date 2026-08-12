--極星宝ブリージンガ・メン
-- 效果：
-- 选择自己以及对方场上表侧表示存在的怪兽各1只发动。选择的自己怪兽的攻击力直到结束阶段时变成和选择的对方怪兽的原本攻击力相同攻击力。
function c42793609.initial_effect(c)
	-- 选择自己以及对方场上表侧表示存在的怪兽各1只发动。选择的自己怪兽的攻击力直到结束阶段时变成和选择的对方怪兽的原本攻击力相同攻击力。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制效果不能在伤害计算后进行。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c42793609.target)
	e1:SetOperation(c42793609.operation)
	c:RegisterEffect(e1)
end
-- 判断效果发动时是否满足条件：自己场上和对方场上各存在1只表侧表示的怪兽。
function c42793609.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断自己场上是否存在1只表侧表示的怪兽。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		-- 判断对方场上是否存在1只表侧表示的怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择自己的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只表侧表示的怪兽作为对象。
	local g1=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	e:SetLabelObject(g1:GetFirst())
	-- 向玩家提示选择对方的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只表侧表示的怪兽作为对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 处理效果的发动，获取连锁中的对象卡片组并进行有效性判断。
function c42793609.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	local sc=g:GetNext()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e)
		or sc:IsFacedown() or not sc:IsRelateToEffect(e) then return end
	local ac=e:GetLabelObject()
	if tc==ac then tc=sc end
	local atk=tc:GetBaseAttack()
	-- 将选择的自己怪兽的攻击力设置为与对方怪兽的原本攻击力相同。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(atk)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	ac:RegisterEffect(e1)
end
