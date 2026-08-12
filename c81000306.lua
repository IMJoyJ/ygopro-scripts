--渾身の一撃
-- 效果：
-- 选择自己场上表侧表示存在的1只怪兽发动。这个回合，选择的怪兽不会被战斗破坏，那次攻击发生的对双方的战斗伤害变成0。此外，这个回合，选择的怪兽向对方怪兽攻击的场合，伤害计算后那只对方怪兽破坏。
function c81000306.initial_effect(c)
	-- 选择自己场上表侧表示存在的1只怪兽发动。这个回合，选择的怪兽不会被战斗破坏，那次攻击发生的对双方的战斗伤害变成0。此外，这个回合，选择的怪兽向对方怪兽攻击的场合，伤害计算后那只对方怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81000306.target)
	e1:SetOperation(c81000306.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的对象选择处理：检查并选择自己场上1只表侧表示的怪兽
function c81000306.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在可以作为对象的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置提示信息为选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：对选择的怪兽适用不会被战破、伤害为0以及伤害计算后破坏对方怪兽的效果
function c81000306.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那次攻击发生的对双方的战斗伤害变成0
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
		-- 那次攻击发生的对双方的战斗伤害变成0
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		-- 此外，这个回合，选择的怪兽向对方怪兽攻击的场合，伤害计算后那只对方怪兽破坏。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_BATTLED)
		e4:SetOperation(c81000306.desop)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e4)
	end
end
-- 伤害计算后破坏对方怪兽的具体效果处理
function c81000306.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被攻击的怪兽（攻击目标）
	local tc=Duel.GetAttackTarget()
	-- 判断自身是否是攻击怪兽，且攻击目标存在并仍处于战斗中
	if c==Duel.GetAttacker() and tc and tc:IsRelateToBattle() then
		-- 将该对方怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
