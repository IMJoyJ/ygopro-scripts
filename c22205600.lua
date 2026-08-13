--連鎖旋風
-- 效果：
-- 魔法·陷阱·效果怪兽的效果让场上存在的卡破坏时，选择场上存在的2张魔法·陷阱卡才能发动。选择的卡破坏。
function c22205600.initial_effect(c)
	-- 魔法·陷阱·效果怪兽的效果让场上存在的卡破坏时，选择场上存在的2张魔法·陷阱卡才能发动。选择的卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c22205600.condition)
	e1:SetTarget(c22205600.target)
	e1:SetOperation(c22205600.activate)
	c:RegisterEffect(e1)
end
-- 筛选因“魔法·陷阱·效果怪兽的效果”而被破坏且离场前在场上的卡，用于判断是否满足发动条件。
function c22205600.cfilter(c)
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 发动条件：连锁处理的离场卡组中存在至少1张满足“因效果破坏且原本在场上”的卡，即场上卡被魔法·陷阱·效果怪兽的效果破坏时满足。
function c22205600.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c22205600.cfilter,1,nil)
end
-- 目标筛选条件：选择场上的魔法·陷阱卡（不包含自身）。
function c22205600.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动时的目标选择与操作信息设置：确认存在2张符合条件的魔法·陷阱卡，选择其中2张（不含自身）作为对象，并设置本次连锁将破坏这2张卡的操作信息。
function c22205600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c22205600.filter(chkc) and chkc~=e:GetHandler() end
	-- 在效果发动前检查场上是否存在至少2张符合条件的魔法·陷阱卡（且不能选择本卡自身），若不足则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c22205600.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,e:GetHandler()) end
	-- 向玩家显示“请选择要破坏的卡”的提示信息，用于选择目标时的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从双方场上选择2张符合条件的魔法·陷阱卡作为效果对象，且不能选择此卡自身。
	local g=Duel.SelectTarget(tp,c22205600.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,e:GetHandler())
	-- 设置本次连锁的操作信息：将对象卡组标记为破坏类别，数量为2，用于后续如“星尘龙”等效果的联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果处理阶段：获取发动时选择的目标卡，过滤出仍与效果关联的卡，将其破坏。
function c22205600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组，并筛选出仍然与效果存在联系（未被无关效果无效或离场导致关联重置）的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 以效果原因将筛选后的对象卡破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
