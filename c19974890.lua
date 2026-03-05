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
		-- 把效果e作为玩家player的效果注册给全局环境
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c19974890.checkop)
		-- 把效果e作为玩家player的效果注册给全局环境
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 检索满足条件的卡片组
		Duel.RegisterEffect(ge2,0)
	end
end
-- 将目标怪兽特殊召唤
function c19974890.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	while tc do
		tc:RegisterFlagEffect(19974890,RESET_EVENT+RESETS_STANDARD-RESET_TEMP_REMOVE+RESET_PHASE+PHASE_END,0,1)
		tc=eg:GetNext()
	end
end
-- 效果作用
function c19974890.filter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and c:GetFlagEffect(19974890)==0
end
-- 效果作用
function c19974890.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用
	if chk==0 then return Duel.IsExistingMatchingCard(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 效果作用
	local g=Duel.GetMatchingGroup(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 效果作用
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 效果作用
function c19974890.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用
	local g=Duel.GetMatchingGroup(c19974890.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if g:GetCount()>0 then
		-- 效果作用
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
	-- ①：把这个回合没有召唤·特殊召唤的场上的怪兽全部变成守备表示。这个回合，自身场上有守备表示怪兽存在的玩家不能用这个回合召唤·特殊召唤的怪兽攻击宣言。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c19974890.atkcon1)
	e1:SetTarget(c19974890.atkfilter)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把效果e作为玩家player的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetCondition(c19974890.atkcon2)
	-- 把效果e作为玩家player的效果注册给全局环境
	Duel.RegisterEffect(e2,tp)
end
-- 效果作用
function c19974890.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果作用
function c19974890.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用
	return Duel.IsExistingMatchingCard(Card.IsDefensePos,tp,0,LOCATION_MZONE,1,nil)
end
-- 效果作用
function c19974890.atkfilter(e,c)
	return c:GetFlagEffect(19974890)~=0
end
