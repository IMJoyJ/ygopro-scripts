--聖王の粉砕
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。对方场上有卡存在的场合，这张卡的发动从手卡也能用。
-- ①：包含从卡组把卡加入手卡效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，再把那张无效的卡破坏。这张卡从手卡发动的场合，发动后，这次决斗中自己不能把暗·水·炎属性怪兽的效果发动。
local s,id,o=GetID()
-- 初始化效果：注册卡片发动效果以及满足条件时可从手卡发动效果的永续效果
function s.initial_effect(c)
	-- ①：包含从卡组把卡加入手卡效果的魔法·陷阱·怪兽的效果发动时才能发动。那个效果无效。自己墓地有陷阱卡存在的场合，再把那张无效的卡破坏。
	local e1=Effect.CreateEffect(c)
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
	e2:SetDescription(aux.Stringid(id,1))  --"适用「圣王的粉碎」的效果从手卡发动"
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_TRAP_ACT_IN_HAND)
	e2:SetCondition(s.handcon)
	c:RegisterEffect(e2)
end
-- 发动条件：包含从卡组把卡加入手卡（抽卡或检索）的效果发动时
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local ex4=re:IsHasCategory(CATEGORY_DRAW)
	local ex5=re:IsHasCategory(CATEGORY_SEARCH)
	-- 判断被连锁的效果是否包含抽卡或检索，且该连锁的效果可以被无效
	return (ex4 or ex5) and Duel.IsChainDisablable(ev)
end
-- 效果目标：设置无效效果的操作信息，并标记这张卡是否是从手卡发动
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(0)
	if chk==0 then return true end
	-- 设置当前效果分类为效果无效，目标为发动效果的卡片
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if e:GetHandler():IsStatus(STATUS_ACT_FROM_HAND) then
		e:SetLabel(100)
	end
end
-- 效果处理：使被连锁的效果无效；若自己墓地有陷阱卡存在，则可以再破坏该无效的卡；若从手卡发动，则注册限制自身属性怪兽效果发动的誓约效果
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 若被连锁的效果被成功无效且自己墓地存在陷阱卡，且该卡依然在场上存在
	if Duel.NegateEffect(ev) and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_TRAP) and re:GetHandler():IsRelateToEffect(re) then
		-- 将那张无效的卡破坏
		Duel.Destroy(eg,REASON_EFFECT)
	end
	if e:GetLabel()==100 then
		-- 这张卡从手卡发动的场合，发动后，这次决斗中自己不能把暗·水·炎属性怪兽的效果发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「圣王的粉碎」效果适用中"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(s.aclimit)
		-- 在这次决斗中给自身玩家注册誓约限制效果（不能发动暗·水·炎属性怪兽的效果）
		Duel.RegisterEffect(e1,tp)
	end
end
-- 手卡发动的过滤条件：对方场上有卡存在
function s.handcon(e)
	-- 判断对方场上的卡片数量是否不为0
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_ONFIELD)~=0
end
-- 誓约限制条件：不能发动暗·水·炎属性怪兽的效果
function s.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsAttribute(ATTRIBUTE_DARK+ATTRIBUTE_FIRE+ATTRIBUTE_WATER)
end
