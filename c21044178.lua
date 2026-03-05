--深淵に潜む者
-- 效果：
-- 4星怪兽×2
-- ①：这张卡有水属性怪兽在作为超量素材的场合，自己场上的水属性怪兽的攻击力上升500。
-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。这个回合，对方不能把墓地的卡的效果发动。
function c21044178.initial_effect(c)
	-- 添加XYZ召唤手续，使用4星怪兽2只作为超量素材
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：这张卡有水属性怪兽在作为超量素材的场合，自己场上的水属性怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(c21044178.atkcon)
	-- 设置效果目标为水属性怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER))
	e1:SetValue(500)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，把这张卡1个超量素材取除才能发动。这个回合，对方不能把墓地的卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21044178,0))  --"效果发动限制"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMING_DRAW_PHASE)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c21044178.cost)
	e2:SetTarget(c21044178.target)
	e2:SetOperation(c21044178.operation)
	c:RegisterEffect(e2)
end
-- 判断此卡的超量素材中是否存在水属性怪兽
function c21044178.atkcon(e)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_WATER)
end
-- 支付1个超量素材作为代价
function c21044178.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断此卡是否已发动过效果
function c21044178.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断此卡是否已发动过效果
	if chk==0 then return Duel.GetFlagEffect(tp,21044178)==0 end
end
-- 发动效果，使对方在本回合不能发动墓地的卡的效果
function c21044178.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 使对方在本回合不能发动墓地的卡的效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c21044178.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册标识效果，防止此卡效果重复发动
	Duel.RegisterFlagEffect(tp,21044178,RESET_PHASE+PHASE_END,0,0)
end
-- 限制对方不能发动墓地的卡的效果
function c21044178.aclimit(e,re,tp)
	return re:GetActivateLocation()==LOCATION_GRAVE
end
