--ハーフ・アンブレイク
-- 效果：
-- 选择场上1只怪兽才能发动。这个回合，选择的怪兽不会被战斗破坏，那只怪兽的战斗发生的对自己的战斗伤害变成一半。
function c981540.initial_effect(c)
	-- 选择场上1只怪兽才能发动。这个回合，选择的怪兽不会被战斗破坏，那只怪兽的战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c981540.target)
	e1:SetOperation(c981540.activate)
	c:RegisterEffect(e1)
end
-- 定义效果发动的目标选择与合法性检测函数
function c981540.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 在发动准备阶段，检查场上是否存在至少1只可以作为效果对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向发动效果的玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择场上1只怪兽作为当前连锁的效果对象
	Duel.SelectTarget(tp,nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 定义效果处理函数，为目标怪兽施加不破和伤害减半的效果
function c981540.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 这个回合，选择的怪兽不会被战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的战斗发生的对自己的战斗伤害变成一半。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_CHANGE_INVOLVING_BATTLE_DAMAGE)
		-- 设置战斗伤害变化效果的值，使自己受到的战斗伤害变成一半
		e2:SetValue(aux.ChangeBattleDamage(0,HALF_DAMAGE))
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
