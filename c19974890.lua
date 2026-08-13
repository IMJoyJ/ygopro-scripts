--獣累々
-- 效果：
-- ①：把这个回合没有召唤·特殊召唤的场上的怪兽全部变成守备表示。这个回合，自身场上有守备表示怪兽存在的玩家不能用这个回合召唤·特殊召唤的怪兽攻击宣言。
function c19974890.initial_effect(c)
	-- ①：把这个回合没有召唤·特殊召唤的场上的怪兽全部变成守备表示。这个回合，自身场上有守备表示怪兽存在的玩家不能用这个回合召唤·特殊召唤的怪兽攻击宣言。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c19974890.target)
	e1:SetOperation(c19974890.activate)
	c:RegisterEffect(e1)
	if not c19974890.global_check then
		c19974890.global_check=true
		-- 中‘这个回合没有召唤·特殊召唤的’与‘这个回合召唤·特殊召唤的’的判定依据：通过全局监听通常/特殊召唤成功并给对应怪兽注册19974890标识来区分。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c19974890.checkop)
		-- 将通常召唤成功时的全局监听效果注册到整个决斗（owner=0），使任意怪兽通常召唤成功时触发checkop，为其标记本回合召唤过的标识。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将特殊召唤成功时的全局监听效果注册到整个决斗（owner=0），使任意怪兽特殊召唤成功时触发checkop，为其标记本回合特殊召唤过的标识。
		Duel.RegisterEffect(ge2,0)
	end
end
-- checkop：对eg中的每只召唤/特殊召唤成功的怪兽注册标识效果19974890，表示该怪兽本回合曾被召唤/特殊召唤；该标识会在离场、回手、回卡组等标准重置或结束阶段时清除。
function c19974890.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(19974890,RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 筛选目标：怪兽处于攻击表示、可以变更表示形式、且本回合没有被召唤/特殊召唤过（即没有19974890标识）。
function c19974890.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and c:GetFlagEffect(19974890)==0
end
-- 效果发动时的目标处理：确认场上存在至少1只满足筛选条件的怪兽；并取得所有满足条件的怪兽，设置本次操作信息为变更表示形式。
function c19974890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：场上是否存在至少1只攻击表示、可变更表示形式、且本回合未召唤/特殊召唤过的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有满足筛选条件的怪兽（攻击表示、可变更表示形式、且本回合未召唤/特殊召唤过）。
	local g=Duel.GetMatchingGroup(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置连锁操作信息：将获取的怪兽组及其数量登记为CATEGORY_POSITION，供其他效果（如星尘龙、王家长眠之谷等）进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果处理：先将所有符合条件（攻击表示、可变更表示形式、且本回合未召唤/特殊召唤过）的怪兽变为表侧守备表示；再分别对双方场上本回合召唤/特殊召唤过的怪兽设置‘不能攻击宣言’效果，该效果持续到结束阶段。
function c19974890.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时重新获取场上所有满足筛选条件的怪兽，防止发动时与处理时的情况不一致。
	local g=Duel.GetMatchingGroup(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 将选中的所有怪兽的表示形式变为表侧守备表示（仅当存在符合条件的怪兽时执行）。
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	-- 这个回合，自身场上有守备表示怪兽存在的玩家不能用这个回合召唤·特殊召唤的怪兽攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c19974890.atkcon1)
	e1:SetTarget(c19974890.atkfilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将禁止攻击宣言的永续效果注册到己方场上（作用于己方怪兽），使己方本回合召唤/特殊召唤过的怪兽在满足条件时不能攻击宣言。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c19974890.atkcon2)
	-- 将同样的禁止攻击宣言效果复制并注册到对方场上（作用于对方怪兽），使对方本回合召唤/特殊召唤过的怪兽在满足条件时不能攻击宣言。
	Duel.RegisterEffect(e2,tp)
end
-- atkcon1：该禁攻效果的发动条件——己方场上有表侧守备表示怪兽存在。
function c19974890.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上是否存在至少1只表侧守备表示怪兽（判断依据为怪兽的表示形式是否为表侧守备）。
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,nil)
end
-- atkcon2：该禁攻效果的发动条件——对方场上有表侧守备表示怪兽存在。
function c19974890.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1只表侧守备表示怪兽（判断依据为怪兽的表示形式是否为表侧守备）。
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil)
end
-- atkfilter：禁攻效果适用的怪兽限定为本回合召唤/特殊召唤过的怪兽（即带有19974890标识的怪兽）。
function c19974890.atkfilter(e,c)
	return c:GetFlagEffect(19974890)~=0
end
