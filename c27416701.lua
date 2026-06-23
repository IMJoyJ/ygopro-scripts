--柴戦士タロ
-- 效果：
-- 这张卡不会被战斗破坏。场上存在的卡被战斗或者卡的效果破坏时，自己场上表侧表示存在的这张卡回到持有者手卡。
function c27416701.initial_effect(c)
	-- 这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- 场上存在的卡被战斗或者卡的效果破坏时，自己场上表侧表示存在的这张卡回到持有者手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27416701,0))  --"返回手牌"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c27416701.condition)
	e2:SetTarget(c27416701.target)
	e2:SetOperation(c27416701.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查被破坏的卡是否在场上被破坏且破坏原因为战斗或效果。
function c27416701.filter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 判断被破坏的卡中是否存在满足条件的卡，即在场上被战斗或效果破坏的卡。
function c27416701.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27416701.filter,1,nil)
end
-- 设置连锁处理信息，指定将自身送回手牌的效果分类。
function c27416701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前处理的连锁的操作信息为将自身送回手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理函数，检查自身是否与效果相关且表侧表示存在，若满足条件则送回手牌。
function c27416701.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将自身以效果破坏原因为由送回持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
