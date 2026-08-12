--ジャイアント・オーク
-- 效果：
-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡的表示形式不能变更。
function c73698349.initial_effect(c)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示。直到下次的自己回合结束时这张卡的表示形式不能变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c73698349.poscon)
	e1:SetOperation(c73698349.posop)
	c:RegisterEffect(e1)
end
-- 检查自身在本回合是否进行过攻击，以此作为效果发动的条件
function c73698349.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 若自身为攻击表示则将其转为表侧守备表示，并注册一个直到下次自己回合结束时不能变更表示形式的效果
function c73698349.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将该怪兽的表示形式变更为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡的表示形式不能变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
