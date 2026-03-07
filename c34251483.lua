--ゴブリン切り込み部隊
-- 效果：
-- 这张卡的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合结束时这张卡不能把表示形式变更。
function c34251483.initial_effect(c)
	-- 这张卡的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetOperation(c34251483.atkop)
	c:RegisterEffect(e1)
	-- 这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合结束时这张卡不能把表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c34251483.poscon)
	e2:SetOperation(c34251483.posop)
	c:RegisterEffect(e2)
end
-- 注册一个在攻击宣言时触发的效果，用于禁止对方发动魔法·陷阱·效果怪兽的效果。
function c34251483.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建一个禁止对方发动魔法·陷阱·效果怪兽效果的永续效果。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c34251483.aclimit)
	e1:SetReset(RESET_CHAIN)
	-- 将效果注册给指定玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 判断对方发动的效果是否为魔法·陷阱·效果怪兽的效果。
function c34251483.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:GetHandler():IsType(TYPE_MONSTER)
end
-- 判断该卡是否已经攻击过。
function c34251483.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 处理战斗阶段结束时的效果，将攻击表示的怪兽变为守备表示并设置不能改变表示形式。
function c34251483.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将目标怪兽变为守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 设置一个永续效果，使该怪兽在战斗阶段结束后不能改变表示形式。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
