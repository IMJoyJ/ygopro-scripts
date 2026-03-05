--急き兎馬
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上攻击表示特殊召唤。
-- ②：和这张卡相同纵列有其他卡被放置的场合发动。这张卡破坏。
-- ③：1回合1次，自己主要阶段才能发动。这个回合，这张卡的原本攻击力变成一半，可以直接攻击。
function c19636995.initial_effect(c)
	-- ①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,19636995+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c19636995.hspcon)
	e1:SetValue(c19636995.hspval)
	c:RegisterEffect(e1)
	-- ②：和这张卡相同纵列有其他卡被放置的场合发动。这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(19636995,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_MOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c19636995.descon)
	e2:SetTarget(c19636995.destg)
	e2:SetOperation(c19636995.desop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段才能发动。这个回合，这张卡的原本攻击力变成一半，可以直接攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(19636995,1))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(c19636995.datop)
	c:RegisterEffect(e3)
end
-- 计算当前玩家场上所有卡所占据的纵列区域，返回未被占用的纵列区域掩码。
function c19636995.hspzone(tp)
	local zone=0
	-- 获取当前玩家场上所有卡的集合。
	local lg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 遍历场上所有卡，计算其占据的纵列区域。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return bit.bnot(zone)
end
-- 判断特殊召唤条件是否满足，即是否有足够的空位进行特殊召唤。
function c19636995.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=c19636995.hspzone(tp)
	-- 检查当前玩家在指定区域是否有足够的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置特殊召唤时的目标区域。
function c19636995.hspval(e,c)
	local tp=c:GetControler()
	local zone=c19636995.hspzone(tp)
	return 0,zone
end
-- 判断目标卡是否与当前卡在同一纵列。
function c19636995.desfilter(c,col)
	-- 比较目标卡的纵列编号与当前卡的纵列编号是否一致。
	return col==aux.GetColumn(c)
end
-- 判断是否触发效果，即是否有其他卡移动到与当前卡相同的纵列。
function c19636995.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前卡所在的纵列编号。
	local col=aux.GetColumn(e:GetHandler())
	return col and eg:IsExists(c19636995.desfilter,1,e:GetHandler(),col)
end
-- 设置破坏效果的连锁操作信息。
function c19636995.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19636995)==0 end
	e:GetHandler():RegisterFlagEffect(19636995,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	-- 设置连锁操作信息，表示将要破坏当前卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- 执行破坏操作，将当前卡破坏。
function c19636995.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 实际执行破坏动作，以效果为原因将卡破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- 执行③效果，将攻击力减半并获得直接攻击能力。
function c19636995.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local batk=c:GetBaseAttack()
		-- 将当前卡的原本攻击力设置为原来的一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 使当前卡获得直接攻击能力。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
