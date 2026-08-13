--急き兎馬
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上攻击表示特殊召唤。
-- ②：和这张卡相同纵列有其他卡被放置的场合发动。这张卡破坏。
-- ③：1回合1次，自己主要阶段才能发动。这个回合，这张卡的原本攻击力变成一半，可以直接攻击。
function c19636995.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：有着没有卡存在的纵列的场合，这张卡可以从手卡往那个纵列的自己场上攻击表示特殊召唤。
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
-- 计算可以特殊召唤的空列：获取双方场上所有卡，将每张卡在主要怪兽区所占据的纵列位合并，再按位取反得到没有卡的纵列区域（以zone位掩码表示）。
function c19636995.hspzone(tp)
	local zone=0
	-- 取得双方场上所有卡片（怪兽区+魔法陷阱区），用于后续检查哪些纵列已被占据。
	local lg=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	-- 遍历场上卡片组中的每张卡，逐一统计其占据的纵列。
	for tc in aux.Next(lg) do
		zone=bit.bor(zone,tc:GetColumnZone(LOCATION_MZONE,tp))
	end
	return bit.bnot(zone)
end
-- 判定①的特殊召唤条件：这张卡在手牌时，若其控制者场上存在没有卡的纵列且该纵列有可用怪兽区，则可进行特殊召唤。
function c19636995.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local zone=c19636995.hspzone(tp)
	-- 检查空列区域内是否存在可用的怪兽区空格，返回值大于0表示满足“有着没有卡存在的纵列”的条件。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
end
-- 设置规则特殊召唤的参数：以表侧攻击表示特殊召唤，并将可用的空列区域作为特殊召唤目标zone返回。
function c19636995.hspval(e,c)
	local tp=c:GetControler()
	local zone=c19636995.hspzone(tp)
	return 0,zone
end
-- 过滤函数：用于判断某张卡是否与指定纵列相同，从而识别“相同纵列的其他卡”。
function c19636995.desfilter(c,col)
	-- 返回卡片c的纵列是否等于指定的列号col。
	return col==aux.GetColumn(c)
end
-- ②的诱发条件：当有其他卡被放置（移动）到与这张卡相同纵列时，本效果发动。
function c19636995.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取这张卡当前所在纵列的编号，供同列比较使用。
	local col=aux.GetColumn(e:GetHandler())
	return col and eg:IsExists(c19636995.desfilter,1,e:GetHandler(),col)
end
-- ②发动时的目标处理：确认本卡尚未因这个②效果发动过（避免重复），并将自身标记为将被破坏的卡。
function c19636995.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(19636995)==0 end
	e:GetHandler():RegisterFlagEffect(19636995,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1)
	-- 设置操作信息：本次效果将破坏这张卡（1张），供时点检测与连锁处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则执行破坏。
function c19636995.desop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 以效果原因将这张卡破坏。
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end
-- ③效果处理：若这张卡仍在场上且表侧表示，将其原本攻击力变为一半，并付与直接攻击能力，直到回合结束。
function c19636995.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local batk=c:GetBaseAttack()
		-- 这个回合，这张卡的原本攻击力变成一半。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(math.ceil(batk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		-- 可以直接攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
