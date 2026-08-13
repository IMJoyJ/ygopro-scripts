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
-- 攻击宣言时，创建并注册一个以对方为对象的禁止发动效果：直到本次连锁结束前，对方不能发动魔法·陷阱·效果怪兽的效果。
function c34251483.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这张卡的攻击宣言时，对方不能把魔法·陷阱·效果怪兽的效果发动。这张卡攻击的场合，战斗阶段结束时变成守备表示，直到下次的自己回合结束时这张卡不能把表示形式变更。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c34251483.aclimit)
	e1:SetReset(RESET_CHAIN)
	-- 将上述禁止对方发动效果的持续效果注册到场上，使其对对方玩家生效，并随连锁结束自动失效。
	Duel.RegisterEffect(e1,tp)
end
-- 用于限制效果的判定：若对方发动的效果是魔法/陷阱卡的发动（EFFECT_TYPE_ACTIVATE），或者该效果来自怪兽卡（效果怪兽的效果），则返回 true 表示不能发动。
function c34251483.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) or re:GetHandler():IsType(TYPE_MONSTER)
end
-- 战斗阶段结束时效果的条件：这张卡本回合进行过攻击（攻击次数大于 0）才处理后续变成守备表示和不能变更表示形式的效果。
function c34251483.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 若这张卡仍在攻击表示，则在战斗阶段结束时将其变更为表侧守备表示；随后给自己附加一个不能变更表示形式的封印效果，该效果持续到下次自己回合结束且不能被无效。
function c34251483.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡的表示形式变更为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
	-- 直到下次的自己回合结束时这张卡不能把表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,3)
	c:RegisterEffect(e1)
end
