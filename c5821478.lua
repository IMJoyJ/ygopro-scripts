--トポロジック・ボマー・ドラゴン
-- 效果：
-- 效果怪兽2只以上
-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽在连接怪兽所连接区特殊召唤的场合发动。双方的主要怪兽区域的怪兽全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
-- ②：这张卡向对方怪兽攻击的伤害计算后发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
function c5821478.initial_effect(c)
	-- 设置连接召唤的手续，需要2只以上的效果怪兽作为素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	c:EnableReviveLimit()
	-- ①：这张卡已在怪兽区域存在的状态，这张卡以外的怪兽在连接怪兽所连接区特殊召唤的场合发动。双方的主要怪兽区域的怪兽全部破坏。这个回合，这张卡以外的自己怪兽不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5821478,0))  --"主要怪兽区域的怪兽全部破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e1:SetCondition(c5821478.descon)
	e1:SetTarget(c5821478.destg)
	e1:SetOperation(c5821478.desop)
	c:RegisterEffect(e1)
	-- ②：这张卡向对方怪兽攻击的伤害计算后发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5821478,1))
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BATTLED)
	e2:SetCondition(c5821478.damcon)
	e2:SetTarget(c5821478.damtg)
	e2:SetOperation(c5821478.damop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断特殊召唤的怪兽是否在连接怪兽所指向的区域。
function c5821478.cfilter(c,zone)
	local seq=c:GetSequence()
	if c:IsLocation(LOCATION_MZONE) then
		if c:IsControler(1) then seq=seq+16 end
	else
		seq=c:GetPreviousSequence()
		if c:IsPreviousControler(1) then seq=seq+16 end
	end
	return bit.extract(zone,seq)~=0
end
-- 效果①的发动条件：这张卡以外的怪兽在连接怪兽所连接区特殊召唤。
function c5821478.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方玩家场上所有连接怪兽所指向的区域。
	local zone=Duel.GetLinkedZone(0)+(Duel.GetLinkedZone(1)<<0x10)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(c5821478.cfilter,1,nil,zone)
end
-- 过滤函数：判断怪兽是否在主要怪兽区域。
function c5821478.desfilter(c)
	return c:GetSequence()<5
end
-- 效果①的发动准备：检测并设置破坏双方主要怪兽区域所有怪兽的操作信息。
function c5821478.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取双方主要怪兽区域的所有怪兽。
	local g=Duel.GetMatchingGroup(c5821478.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏操作信息，包含要破坏的怪兽组及其数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的效果处理：破坏双方主要怪兽区域的所有怪兽，并适用“这张卡以外的自己怪兽不能攻击”的效果。
function c5821478.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前双方主要怪兽区域的所有怪兽。
	local g=Duel.GetMatchingGroup(c5821478.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 因效果破坏这些怪兽。
	Duel.Destroy(g,REASON_EFFECT)
	-- 这个回合，这张卡以外的自己怪兽不能攻击。②：这张卡向对方怪兽攻击的伤害计算后发动。给与对方那只对方怪兽的原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c5821478.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册全局效果，使本回合自己场上除这张卡以外的怪兽不能攻击。
	Duel.RegisterEffect(e1,tp)
end
-- 过滤函数：用于限制攻击，排除自身（即除这张卡以外的怪兽）。
function c5821478.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②的发动条件：这张卡向对方怪兽攻击的伤害计算后。
function c5821478.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否为自身，且存在攻击对象。
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget()
end
-- 效果②的发动准备：设置给与对方伤害的操作信息。
function c5821478.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害操作信息，伤害数值为攻击对象的原本攻击力。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,Duel.GetAttackTarget():GetBaseAttack())
end
-- 效果②的效果处理：给与对方该对方怪兽原本攻击力数值的伤害。
function c5821478.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为攻击对象的对方怪兽。
	local bc=Duel.GetAttackTarget()
	if bc and bc:IsRelateToBattle() and bc:IsFaceup() then
		-- 给与对方该怪兽原本攻击力数值的效果伤害。
		Duel.Damage(1-tp,bc:GetBaseAttack(),REASON_EFFECT)
	end
end
