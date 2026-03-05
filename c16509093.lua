--王族親衛隊
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转时，在回合结束前这张卡的攻击力守备力上升300。
function c16509093.initial_effect(c)
	-- 效果原文：这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16509093,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c16509093.target)
	e1:SetOperation(c16509093.operation)
	c:RegisterEffect(e1)
	-- 效果原文：这张卡反转时，在回合结束前这张卡的攻击力守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16509093,1))  --"攻守上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c16509093.adop)
	c:RegisterEffect(e2)
end
-- 规则层面：检查是否可以变回里侧守备表示，并注册标识效果以限制每回合只能使用一次。
function c16509093.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(16509093)==0 end
	c:RegisterFlagEffect(16509093,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 规则层面：设置连锁操作信息，表明将要改变表示形式为里侧守备。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 规则层面：执行将自身变为里侧守备表示的操作。
function c16509093.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 规则层面：将目标怪兽变为里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 规则层面：创建攻击力上升300的永续效果，并复制该效果用于守备力上升。
function c16509093.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 效果原文：这张卡反转时，在回合结束前这张卡的攻击力守备力上升300。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
end
