--ふわんだりぃずと怖い海
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有上级召唤的表侧表示怪兽存在，没有特殊召唤的怪兽存在的场合，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽回到持有者手卡。这个回合，对方不能把怪兽特殊召唤，可以进行通常召唤最多3次。
function c77610503.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有上级召唤的表侧表示怪兽存在，没有特殊召唤的怪兽存在的场合，对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽回到持有者手卡。这个回合，对方不能把怪兽特殊召唤，可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCountLimit(1,77610503+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c77610503.discon)
	e1:SetTarget(c77610503.distg)
	e1:SetOperation(c77610503.disop)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上上级召唤且表侧表示存在的怪兽
function c77610503.cfilter1(c)
	return c:IsSummonType(SUMMON_TYPE_ADVANCE) and c:IsFaceup() and not c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 过滤条件：自己场上特殊召唤的怪兽
function c77610503.cfilter2(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL)
end
-- 判定发动条件：对方特殊召唤之际，且自己场上有上级召唤的表侧表示怪兽存在、没有特殊召唤的怪兽存在
function c77610503.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定是否为对方玩家在非连锁中进行特殊召唤
	return tp~=ep and aux.NegateSummonCondition()
		-- 判定自己场上是否存在上级召唤的表侧表示怪兽
		and Duel.IsExistingMatchingCard(c77610503.cfilter1,tp,LOCATION_MZONE,0,1,nil)
		-- 判定自己场上是否不存在特殊召唤的怪兽
		and not Duel.IsExistingMatchingCard(c77610503.cfilter2,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置效果发动的目标与操作信息
function c77610503.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：无效怪兽的特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将怪兽送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,eg,eg:GetCount(),0,0)
end
-- 执行效果处理：无效特殊召唤并回手牌，并对对方施加后续限制
function c77610503.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使对方怪兽的特殊召唤无效
	Duel.NegateSummon(eg)
	-- 将特殊召唤被无效的怪兽送回持有者手牌
	Duel.SendtoHand(eg,nil,REASON_EFFECT)
	-- 这个回合，对方不能把怪兽特殊召唤，可以进行通常召唤最多3次。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(0,1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 对对方玩家施加本回合不能特殊召唤怪兽的限制
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_SUMMON_COUNT_LIMIT)
	e2:SetValue(3)
	-- 对对方玩家施加本回合可以进行通常召唤最多3次的限制
	Duel.RegisterEffect(e2,tp)
end
