--カラテマン
-- 效果：
-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力直到结束阶段时变成原本攻击力2倍的数值。这个效果使用的场合，这张卡在结束阶段时破坏。
function c23289281.initial_effect(c)
	-- 效果原文内容：1回合1次，自己的主要阶段时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23289281,0))  --"攻击变化"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetOperation(c23289281.operaion)
	c:RegisterEffect(e1)
end
-- 效果作用：检查卡是否里侧表示或与效果无关联，若满足则返回不执行效果。
function c23289281.operaion(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 效果原文内容：这张卡的攻击力直到结束阶段时变成原本攻击力2倍的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK_FINAL)
	e1:SetValue(c:GetBaseAttack()*2)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1,true)
	-- 效果原文内容：这个效果使用的场合，这张卡在结束阶段时破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(23289281,1))  --"破坏"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c23289281.destg)
	e2:SetOperation(c23289281.desop)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e2)
end
-- 效果作用：设置连锁操作信息，确定破坏目标为自身。
function c23289281.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 效果作用：设置当前处理的连锁操作信息为破坏效果，目标为自身。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 效果作用：破坏效果处理函数，检查目标是否与效果相关联，若关联则进行破坏。
function c23289281.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 效果作用：以效果原因将目标卡破坏至墓地。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
