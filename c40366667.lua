--霊王の波動
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方场上有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：包含把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，再把那张无效的卡破坏。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·地·风属性怪兽的效果发动。
local s,id,o=GetID()
-- 卡片效果初始化注册流程
function s.initial_effect(c)
	-- ①：包含把怪兽特殊召唤效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，再把那张无效的卡破坏。
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
-- ①号效果的发动条件判定函数，检查连锁中的效果是否包含特殊召唤分类且该连锁可被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断所发动的效果是否包含特殊召唤且该效果是否可以被无效
	return re:IsHasCategory(CATEGORY_SPECIAL_SUMMON) and Duel.IsChainDisablable(ev)
end
-- ①号效果的发动靶指向（Target）函数，设置操作信息并标记是否是从手卡发动
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息，将发动的效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- ①号效果的执行逻辑（Operation）函数，无效对方效果，并在满足条件时破坏该卡。若从手卡发动，则注册限制自己发动特定属性怪兽效果的誓约效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 如果成功无效效果，且自己墓地存在陷阱卡，且该卡仍与当前连锁相关联，则执行后续破坏处理
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏该被无效效果的卡片
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，这次决斗中自己不能把光·地·风属性怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「灵王的波动」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 向玩家注册不能发动光·地·风属性怪兽效果的限制
		Duel.RegisterEffect(e1,tp)
	end
end
-- 手牌发动效果的发动条件判定函数，判断对方场上是否有卡存在
function s.handcon(e)
	-- 判断对方场上是否存在任何卡片
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)~=0
end
-- 限制玩家发动特定怪兽效果的过滤器函数，若为怪兽卡且属性属于光、地或风则禁止发动
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_EARTH+ATTRIBUTE_WIND)
end
