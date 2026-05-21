--マックス・ウォリアー
-- 效果：
-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升400。这张卡战斗破坏对方怪兽的场合，直到下次的自己的准备阶段时这张卡的等级变成2星，原本的攻击力·守备力成为一半数值。
function c94538053.initial_effect(c)
	-- 这张卡向对方怪兽攻击的场合，伤害步骤内攻击力上升400。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetCondition(c94538053.condtion)
	e1:SetValue(400)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏对方怪兽的场合，直到下次的自己的准备阶段时这张卡的等级变成2星，原本的攻击力·守备力成为一半数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94538053,0))  --"等级攻守变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c94538053.atkcon)
	e2:SetOperation(c94538053.atkop)
	c:RegisterEffect(e2)
end
-- 判断当前是否处于伤害步骤，且自身向对方怪兽发动攻击
function c94538053.condtion(e)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_DAMAGE or ph==PHASE_DAMAGE_CAL)
		-- 判断攻击怪兽是否为自身，且存在攻击目标
		and Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()~=nil
end
-- 判断自身是否仍处于战斗关系中且表侧表示存在
function c94538053.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsRelateToBattle() and e:GetHandler():IsFaceup()
end
-- 在自身战斗破坏对方怪兽时，将原本攻击力与守备力减半，并使等级变为2星，持续到下次自己的准备阶段
function c94538053.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToBattle() and c:IsFaceup() then
		local batk=c:GetBaseAttack()
		local bdef=c:GetBaseDefense()
		-- 直到下次的自己的准备阶段时……原本的攻击力……成为一半数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE_FINAL)
		e2:SetValue(math.ceil(bdef/2))
		c:RegisterEffect(e2)
		local e3=e1:Clone()
		e3:SetCode(EFFECT_CHANGE_LEVEL)
		e3:SetValue(2)
		c:RegisterEffect(e3)
	end
end
