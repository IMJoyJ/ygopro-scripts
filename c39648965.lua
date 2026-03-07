--機皇兵ワイゼル・アイン
-- 效果：
-- ①：这张卡的攻击力上升这张卡以外的场上的「机皇」怪兽数量×100。
-- ②：1回合1次，这张卡以外的自己的「机皇」怪兽向守备表示怪兽攻击宣言时才能发动。那次战斗用那只自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c39648965.initial_effect(c)
	-- 效果原文内容：①：这张卡的攻击力上升这张卡以外的场上的「机皇」怪兽数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c39648965.val)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：1回合1次，这张卡以外的自己的「机皇」怪兽向守备表示怪兽攻击宣言时才能发动。那次战斗用那只自己怪兽向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
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
-- 规则层面作用：过滤场上表侧表示的「机皇」怪兽
function c39648965.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x13)
end
-- 规则层面作用：计算场上「机皇」怪兽数量并乘以100作为攻击力加成
function c39648965.val(e,c)
	-- 规则层面作用：返回满足条件的「机皇」怪兽数量乘以100
	return Duel.GetMatchingGroupCount(c39648965.atkfilter,0,LOCATION_MZONE,LOCATION_MZONE,c)*100
end
-- 规则层面作用：判断攻击怪兽是否为己方「机皇」怪兽且攻击目标为守备表示
function c39648965.piercecon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取此次攻击的怪兽
	local a=Duel.GetAttacker()
	-- 规则层面作用：获取此次攻击的目标怪兽
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(tp) and a~=e:GetHandler() and d:IsDefensePos() and a:IsSetCard(0x13)
end
-- 规则层面作用：设置效果目标，用于后续处理
function c39648965.piercetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面作用：建立效果与攻击怪兽之间的关联
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 规则层面作用：为攻击怪兽设置贯穿伤害效果
function c39648965.pierceop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取此次攻击的怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToEffect(e) and a:IsFaceup() then
		-- 效果原文内容：给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		a:RegisterEffect(e1)
	end
end
