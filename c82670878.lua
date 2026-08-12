--血涙のオーガ
-- 效果：
-- 对方回合同1次的战斗阶段中宣言第2次的直接攻击时，这张卡可以从手卡特殊召唤。这个效果特殊召唤成功时，这张卡的攻击力·守备力变成和这个回合进行第1次直接攻击的场上表侧表示存在的怪兽相同的数值。这个回合，只要这个效果特殊召唤的这张卡在场上表侧表示存在，对方不能选择这张卡以外的怪兽作为攻击对象。
function c82670878.initial_effect(c)
	-- 对方回合同1次的战斗阶段中宣言第2次的直接攻击时，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82670878,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_CUSTOM+82670878)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c82670878.condition)
	e1:SetTarget(c82670878.target)
	e1:SetOperation(c82670878.operation)
	c:RegisterEffect(e1)
	-- 这个效果特殊召唤成功时，这张卡的攻击力·守备力变成和这个回合进行第1次直接攻击的场上表侧表示存在的怪兽相同的数值。这个回合，只要这个效果特殊召唤的这张卡在场上表侧表示存在，对方不能选择这张卡以外的怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82670878,1))  --"攻守变化"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c82670878.adcon)
	e2:SetOperation(c82670878.adop)
	c:RegisterEffect(e2)
	if not c82670878.global_check then
		c82670878.global_check=true
		c82670878[0]=0
		c82670878[1]=0
		-- 同1次的战斗阶段中宣言第2次的直接攻击时
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(c82670878.check)
		-- 注册全局效果，用于在攻击宣言时记录直接攻击次数以及进行第1次直接攻击的怪兽。
		Duel.RegisterEffect(ge1,0)
		-- 进行第1次直接攻击
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ATTACK_DISABLED)
		ge2:SetOperation(c82670878.check2)
		-- 注册全局效果，用于在攻击被无效或转移时，如果该攻击是第1次直接攻击，则回滚直接攻击次数。
		Duel.RegisterEffect(ge2,0)
		-- 同1次的战斗阶段中
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(c82670878.clear)
		-- 注册全局效果，在每个回合开始时重置直接攻击次数计数器。
		Duel.RegisterEffect(ge3,0)
	end
end
-- 攻击宣言时的触发函数：如果是直接攻击，则增加该玩家被直接攻击的次数；第1次直接攻击时记录攻击怪兽并添加标记，第2次直接攻击时触发自定义事件。
function c82670878.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断攻击对象是否为空（即是否为直接攻击）。
	if Duel.GetAttackTarget()==nil then
		c82670878[1-tc:GetControler()]=c82670878[1-tc:GetControler()]+1
		if c82670878[1-tc:GetControler()]==1 then
			c82670878[2]=tc
			tc:RegisterFlagEffect(82670878,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		elseif c82670878[1-tc:GetControler()]==2 then
			-- 触发自定义事件，通知手牌中的此卡可以发动特殊召唤效果。
			Duel.RaiseEvent(tc,EVENT_CUSTOM+82670878,e,0,0,0,0)
		end
	end
end
-- 攻击被无效或转移时的触发函数：如果被无效或转移的攻击是带有标记的第1次直接攻击，则将直接攻击次数减1。
function c82670878.check2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断该怪兽是否为第1次直接攻击的怪兽，且当前攻击对象不为空（即攻击被转移，不再是直接攻击）。
	if tc:GetFlagEffect(82670878)~=0 and Duel.GetAttackTarget()~=nil then
		c82670878[1-tc:GetControler()]=c82670878[1-tc:GetControler()]-1
	end
end
-- 回合开始时的重置函数：清空双方玩家的直接攻击次数计数。
function c82670878.clear(e,tp,eg,ep,ev,re,r,rp)
	c82670878[0]=0
	c82670878[1]=0
end
-- 手牌特殊召唤效果的发动条件函数。
function c82670878.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 必须是对方回合、当前是直接攻击、且对方在本回合已宣言了2次直接攻击。
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil and c82670878[tp]==2
end
-- 手牌特殊召唤效果的靶向/发动准备函数。
function c82670878.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自身怪兽区域是否有空位，以及此卡是否可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手牌特殊召唤效果的执行函数。
function c82670878.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以自身效果的形式在自身场上表侧表示特殊召唤。
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 攻守变化及攻击限制效果的发动条件函数：必须是由自身效果特殊召唤成功。
function c82670878.adcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 攻守变化及攻击限制效果的执行函数：将自身攻守变为第1次直接攻击怪兽的数值，并使对方不能选择自身以外的怪兽作为攻击对象。
function c82670878.adop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c82670878[2]
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		if tc and tc:GetFlagEffect(82670878) then
			-- 这个效果特殊召唤成功时，这张卡的攻击力·守备力变成和这个回合进行第1次直接攻击的场上表侧表示存在的怪兽相同的数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			e1:SetValue(tc:GetAttack())
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(tc:GetDefense())
			c:RegisterEffect(e2)
		end
		-- 这个回合，只要这个效果特殊召唤的这张卡在场上表侧表示存在，对方不能选择这张卡以外的怪兽作为攻击对象。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e3:SetRange(LOCATION_MZONE)
		e3:SetTargetRange(0,LOCATION_MZONE)
		e3:SetValue(c82670878.atlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
-- 攻击限制的过滤函数：使对方不能选择除这张卡以外的怪兽作为攻击目标。
function c82670878.atlimit(e,c)
	return c~=e:GetHandler()
end
