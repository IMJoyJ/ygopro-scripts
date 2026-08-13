--H－C ガーンデーヴァ
-- 效果：
-- 战士族4星怪兽×2
-- 对方场上有4星以下的怪兽特殊召唤时，可以通过把这张卡1个超量素材取除，那些特殊召唤的怪兽破坏。这个效果1回合只能使用1次。
function c48009503.initial_effect(c)
	-- 为该卡添加XYZ召唤手续：以2只战士族4星怪兽作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- 对方场上有4星以下的怪兽特殊召唤时，可以通过把这张卡1个超量素材取除，那些特殊召唤的怪兽破坏。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(48009503,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c48009503.cost)
	e1:SetTarget(c48009503.target)
	e1:SetOperation(c48009503.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：表侧表示且为对方控制的4星以下的怪兽；若传入效果e，还要求该怪兽与效果e仍有关联（未被无效离场等导致关联重置）。
function c48009503.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:IsLevelBelow(4) and (not e or c:IsRelateToEffect(e))
end
-- 发动代价：检测自己场上此卡是否有可移除的超量素材，若有则取除1个作为发动代价。
function c48009503.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 发动时判定：当特殊召唤成功的怪兽群eg中存在满足筛选条件的怪兽时，将eg整体设为对象，并设置破坏其中全部怪兽的操作信息（数量按eg当前数量填写）。
function c48009503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c48009503.filter,1,nil,nil,tp) end
	-- 将本次特殊召唤成功的怪兽群eg设置为当前连锁的效果对象，建立效果关联（这样效果处理时可以判断哪些卡仍然适用）。
	Duel.SetTargetCard(eg)
	-- 设置连锁操作信息：声明本效果为破坏分类，预定处理对象为eg（数量为eg:GetCount()），使相关卡能够正确响应或检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 效果处理：从特殊召唤成功的怪兽群eg中筛出仍满足条件的怪兽，然后对它们执行破坏。
function c48009503.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c48009503.filter,nil,e,tp)
	-- 以效果原因将筛选出的怪兽g全部破坏。
	Duel.Destroy(g,REASON_EFFECT)
end
