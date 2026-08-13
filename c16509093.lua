--王族親衛隊
-- 效果：
-- 这张卡1个回合可以有1次变回里侧守备表示。这张卡反转时，在回合结束前这张卡的攻击力守备力上升300。
function c16509093.initial_effect(c)
	-- 这张卡1个回合可以有1次变回里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16509093,0))  --"变成里侧守备"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c16509093.target)
	e1:SetOperation(c16509093.operation)
	c:RegisterEffect(e1)
	-- 这张卡反转时，在回合结束前这张卡的攻击力守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16509093,1))  --"攻守上升"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_FLIP)
	e2:SetOperation(c16509093.adop)
	c:RegisterEffect(e2)
end
-- 发动条件判定：此卡表侧表示且本回合未使用过该效果时才能发动；同时给自己设置一个“本回合已使用”的标识，用于一回合一次的限制。
function c16509093.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanTurnSet() and c:GetFlagEffect(16509093)==0 end
	c:RegisterFlagEffect(16509093,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,1)
	-- 设置操作信息：本次效果将改变表示形式（CATEGORY_POSITION），对象为本卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,c,1,0,0)
end
-- 效果处理时，若此卡仍与效果相关且处于表侧表示，则将其变更为里侧守备表示。
function c16509093.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身变成里侧守备表示。
		Duel.ChangePosition(c,POS_FACEDOWN_DEFENSE)
	end
end
-- 反转时效果处理：若此卡反转后为表侧表示，则赋予其攻击力和守备力各上升300的效果，持续到回合结束。
function c16509093.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 在回合结束前这张卡的攻击力上升300（对应原文“攻击力守备力上升300”中的攻击力部分）。
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
