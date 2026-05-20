--絶対防御将軍
-- 效果：
-- 这张卡召唤·反转召唤成功的场合守备表示。这张卡可以在守备表示时攻击。守备表示攻击时用攻击力的数值计算伤害。
function c75372290.initial_effect(c)
	-- 这张卡召唤·反转召唤成功的场合守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75372290,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c75372290.postg)
	e1:SetOperation(c75372290.posop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 这张卡可以在守备表示时攻击。守备表示攻击时用攻击力的数值计算伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DEFENSE_ATTACK)
	c:RegisterEffect(e3)
end
-- 改变表示形式效果的Target函数：检测自身是否处于攻击表示，并设置改变表示形式的操作信息
function c75372290.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAttackPos() end
	-- 设置操作信息，表明此效果的处理包含将自身改变表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 改变表示形式效果的Operation函数：若自身在场上表侧攻击表示存在且此效果适用，则将其变为表侧守备表示
function c75372290.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsAttackPos() and c:IsRelateToEffect(e) then
		-- 将自身改变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
