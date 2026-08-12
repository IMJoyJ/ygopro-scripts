--ハンプティ・ダンディ
-- 效果：
-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
-- ②：这张卡反转召唤成功的场合发动。这张卡的攻击力直到回合结束时上升800。
function c71415349.initial_effect(c)
	-- ①：自己主要阶段才能发动。这张卡变成里侧守备表示（1回合只有1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(71415349,0))  --"变成里侧"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c71415349.target)
	e1:SetOperation(c71415349.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡反转召唤成功的场合发动。这张卡的攻击力直到回合结束时上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(71415349,1))  --"攻守变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e2:SetOperation(c71415349.atkop)
	c:RegisterEffect(e2)
end
-- 检查自身是否可以转为里侧表示且本回合未发动过该效果，并注册本回合已发动的标记，设置改变表示形式的操作信息
function c71415349.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(71415349)==0 end
	c:RegisterFlagEffect(71415349,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置改变表示形式的操作信息，涉及卡片为自身
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理：若自身仍在场上且为表侧表示，则将自身转为里侧守备表示
function c71415349.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身转为里侧守备表示
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 效果处理：若自身仍在场上且为表侧表示，则使自身的攻击力直到回合结束时上升800
function c71415349.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 这张卡的攻击力直到回合结束时上升800。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(800)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
