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
-- 筛选被破坏的卡：要求其破坏前位于场上，且破坏原因为战斗或卡的效果，以此判定是否满足“场上存在的卡被战斗或者卡的效果破坏”的触发条件。
function c27416701.filter(c)
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 检查本次破坏事件中被破坏的卡组中，是否存在至少1张满足条件的卡（即场上被战斗或效果破坏的卡），存在则触发本效果。
function c27416701.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c27416701.filter,1,nil)
end
-- 发动时的可选性检查：无额外限制时返回true允许发动；随后预设置将本卡返回手牌的操作信息。
function c27416701.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：宣告效果处理时将本卡（效果持有者）返回持有者手牌（CATEGORY_TOHAND），数量为1，供连锁检测和效果处理使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 效果处理：取得本卡；若本卡仍与当前效果关联且处于表侧表示，则将其返回持有者手牌。
function c27416701.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将本卡以效果原因送回其持有者手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
