--機皇兵ワイゼル・アイン
-- 效果：
-- ①：这张卡的攻击力上升这张卡以外的场上的「机皇」怪兽数量×100。
-- ②：1回合1次，这张卡以外的自己的「机皇」怪兽向守备表示怪兽攻击宣言时才能发动。那次战斗用那只自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c39648965.initial_effect(c)
	-- ①：这张卡的攻击力上升这张卡以外的场上的「机皇」怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c39648965.val)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡以外的自己的「机皇」怪兽向守备表示怪兽攻击宣言时才能发动。那次战斗用那只自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(39648965,0))  --"贯穿伤害"
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c39648965.piercecon)
	e2:SetTarget(c39648965.piercetg)
	e2:SetOperation(c39648965.pierceop)
	c:RegisterEffect(e2)
end
-- 过滤条件：筛选场上的表侧表示且属于「机皇」字段的怪兽，用于后续计算数量。
function c39648965.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 计算这张卡以外场上的「机皇」怪兽数量，并乘以100作为这张卡的攻击力上升数值。
function c39648965.val(e,c)
	-- 统计场上表侧表示「机皇」怪兽的数量（排除自身），乘以100作为攻击力上升值。
	return Duel.GetMatchingGroupCount(c39648965.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*100
end
-- 发动条件：攻击方为这张卡以外的己方表侧表示「机皇」怪兽，且攻击对象为守备表示怪兽。
function c39648965.piercecon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(tp) and a~=e:GetHandler() and d:IsDefensePos() and a:IsSetCard(0x13)
end
-- 发动时的目标处理：满足条件即允许发动，并将攻击怪兽与效果建立关联。
function c39648965.piercetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将宣言攻击的「机皇」怪兽与当前效果建立联系，以便效果处理时确认其仍与效果相关。
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 效果处理：若攻击怪兽仍与效果相关且表侧表示，则为其赋予贯穿伤害效果（战斗伤害穿透）。
function c39648965.pierceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动攻击宣言的怪兽。
	local a=Duel.GetAttacker()
	if a:IsRelateToEffect(e) and a:IsFaceup() then
		-- 那次战斗用那只自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
