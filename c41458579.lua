--六尺瓊勾玉
-- 效果：
-- ①：自己场上有「六武众」怪兽存在，要让卡破坏的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
function c41458579.initial_effect(c)
	-- ①：自己场上有「六武众」怪兽存在，要让卡破坏的怪兽的效果·魔法·陷阱卡由对方发动时才能发动。那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCondition(c41458579.condition)
	e1:SetTarget(c41458579.target)
	e1:SetOperation(c41458579.operation)
	c:RegisterEffect(e1)
end
-- 判断怪兽是否为表侧表示且属于「六武众」字段，作为自己场上有「六武众」怪兽存在的判定条件。
function c41458579.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x103d)
end
-- 发动条件判定：自己场上有表侧「六武众」怪兽，且对方发动了带有破坏卡片效果并可能被无效的怪兽效果或魔法·陷阱卡。
function c41458579.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示且属于「六武众」字段的怪兽。
	if not Duel.IsExistingMatchingCard(c41458579.filter,tp,LOCATION_MZONE,0,1,nil) then return false end
	-- 确认发动者为对方且该连锁可以被无效。
	if tp==ep or not Duel.IsChainNegatable(ev) then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 读取该连锁中与破坏卡片相关的操作信息，以判断对方发动的效果是否包含破坏效果。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc>0
end
-- 发动时处理：宣告要无效该发动，若该效果持有者卡可以破坏且与该效果仍有关联，则同时宣告破坏该卡。
function c41458579.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将这次发动无效的对象设为正在发动的卡（eg），并登记为无效效果。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 将破坏对象设为与无效对象相同的卡，并登记为破坏效果。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先使对方的发动无效，若成功且该卡仍与效果关联，则将其破坏。
function c41458579.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方的发动，并确保该效果持有者卡仍然与效果关联（没有离场或失去关联）时，才继续处理破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因破坏对方发动的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
