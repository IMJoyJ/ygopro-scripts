--霊王の波動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方场上有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：包含把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，再把那张无效的卡破坏。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·地·风属性怪兽的效果发动。
local s,id,o=GetID()
-- 注册灵王的波动的两个效果：无效特殊召唤效果并破坏陷阱卡，以及允许从手卡发动。
function s.initial_effect(c)
	-- 包含把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果发动时才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 对方场上有卡存在的场合，这张卡的发动从手卡也能用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"适用「灵王的波动」的效果来发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
-- 判断是否为包含特殊召唤的连锁效果且该效果可被无效。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为包含特殊召唤的连锁效果且该效果可被无效。
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
end
-- 设置连锁处理信息，标记将要无效的效果。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
	-- 设置连锁处理信息，标记将要无效的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 执行效果：使连锁效果无效，并在满足条件时破坏该效果对应的卡。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使连锁效果无效。
	Duel.NegateEffect(ev)
	-- 检查自己墓地是否存在陷阱卡，若存在则破坏被无效的卡。
	if Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if e:GetLabel()==100 then
		-- 创建并注册一个场上的效果，禁止自己发动光·地·风属性怪兽的效果。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「灵王的波动」的效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 将效果注册到场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断对方场上是否有卡存在。
function s.handcon(e)
	-- 判断对方场上是否有卡存在。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)~=0
end
-- 判断是否为光·地·风属性的怪兽效果。
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_EARTH+ATTRIBUTE_WIND)
end
