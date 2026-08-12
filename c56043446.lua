--万力魔神バイサー・デス
-- 效果：
-- ①：这张卡的召唤成功的场合，以对方场上1只怪兽为对象发动。发动后，第3次的自己准备阶段把作为对象的怪兽破坏。
-- ②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗破坏。
function c56043446.initial_effect(c)
	-- ①：这张卡的召唤成功的场合，以对方场上1只怪兽为对象发动。发动后，第3次的自己准备阶段把作为对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56043446,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c56043446.target)
	e1:SetOperation(c56043446.operation)
	c:RegisterEffect(e1)
end
-- 召唤成功时效果的对象选择处理，确认并选择对方场上1只怪兽作为对象。
function c56043446.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	if chk==0 then return true end
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对方场上1只怪兽作为效果的对象。
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 召唤成功时效果的实际处理：使自身与对象怪兽建立连接，并注册后续的破坏效果与战斗抗性效果。
function c56043446.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本次连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) then
		c:SetCardTarget(tc)
		-- 发动后，第3次的自己准备阶段把作为对象的怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCountLimit(1)
		e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e1:SetCondition(c56043446.descon)
		e1:SetOperation(c56043446.desop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
		c:RegisterEffect(e1)
		-- ②：只要这张卡的①的效果作为对象的怪兽在场上存在，这张卡不会被战斗破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e2:SetValue(1)
		e2:SetCondition(c56043446.rcon)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,3)
		c:RegisterEffect(e2)
	end
end
-- 检查自身当前是否存在作为效果对象的怪兽，作为不会被战斗破坏效果的适用条件。
function c56043446.rcon(e)
	return e:GetHandler():GetFirstCardTarget()~=nil
end
-- 检查当前回合玩家是否为自己，作为准备阶段效果触发的条件。
function c56043446.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己的回合。
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段时的处理：递增回合计数器，并在第3次自己准备阶段时将对象怪兽破坏。
function c56043446.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if not tc then return end
	local ct=e:GetLabel()
	ct=ct+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct==3 then
		-- 因效果将作为对象的怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
