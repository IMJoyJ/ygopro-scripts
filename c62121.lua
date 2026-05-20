--闇晦ましの城
-- 效果：
-- 反转：场上表侧表示的全部不死族的怪兽攻击力·守备力加200。只要这张卡在场上表侧表示存在，自己的每个准备阶段不死族的攻守力都会加200。这个效果持续到自己的第4个准备阶段。
function c62121.initial_effect(c)
	-- 反转：场上表侧表示的全部不死族的怪兽攻击力·守备力加200。只要这张卡在场上表侧表示存在，自己的每个准备阶段不死族的攻守力都会加200。这个效果持续到自己的第4个准备阶段。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(62121,0))  --"反转"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(c62121.operation)
	c:RegisterEffect(e1)
end
-- 反转效果的处理：使场上所有不死族怪兽的攻击力·守备力上升200，并在此卡表侧表示存在时，注册在自己准备阶段使不死族怪兽攻守上升的效果
function c62121.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有的不死族怪兽
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,nil,RACE_ZOMBIE)
	local tc=g:GetFirst()
	while tc do
		-- 攻击力·守备力加200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 只要这张卡在场上表侧表示存在，自己的每个准备阶段不死族的攻守力都会加200。这个效果持续到自己的第4个准备阶段。
		local e3=Effect.CreateEffect(c)
		e3:SetDescription(aux.Stringid(62121,1))  --"攻击上升"
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCountLimit(1)
		e3:SetCondition(c62121.atkcon)
		e3:SetOperation(c62121.atkop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,4)
		c:RegisterEffect(e3)
	end
end
-- 准备阶段效果的触发条件：当前回合是自己的回合
function c62121.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 准备阶段效果的处理：使场上所有不死族怪兽的攻击力·守备力上升200
function c62121.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取双方场上所有的不死族怪兽
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_MZONE,LOCATION_MZONE,nil,RACE_ZOMBIE)
	local tc=g:GetFirst()
	while tc do
		-- 不死族的攻守力都会加200
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
