--ランサー・デーモン
-- 效果：
-- 对方场上守备表示存在的怪兽为攻击对象的自己怪兽的攻击宣言时才能发动。那只怪兽向守备表示怪兽攻击的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这个效果1回合只能使用1次。
function c79418153.initial_effect(c)
	-- 对方场上守备表示存在的怪兽为攻击对象的自己怪兽的攻击宣言时才能发动。那只怪兽向守备表示怪兽攻击的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(79418153,0))  --"穿刺伤害"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c79418153.piercecon)
	e1:SetTarget(c79418153.piercetg)
	e1:SetOperation(c79418153.pierceop)
	c:RegisterEffect(e1)
end
-- 判断发动条件：攻击怪兽由自己控制，且存在攻击对象，该攻击对象为守备表示怪兽
function c79418153.piercecon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击宣言的怪兽
	local a=Duel.GetAttacker()
	-- 获取作为攻击对象的怪兽
	local d=Duel.GetAttackTarget()
	return d and a:IsControler(tp) and d:IsDefensePos()
end
-- 效果发动时的目标确认，并使攻击怪兽与此效果建立联系
function c79418153.piercetg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 使攻击怪兽与当前发动的效果建立联系
	Duel.GetAttacker():CreateEffectRelation(e)
end
-- 效果处理：给攻击怪兽赋予贯穿效果，持续到回合结束
function c79418153.pierceop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToEffect(e) and a:IsFaceup() then
		-- 那只怪兽向守备表示怪兽攻击的场合，若攻击力超过那个守备力，给与对方基本分那个数值的战斗伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_PIERCE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		a:RegisterEffect(e1)
	end
end
