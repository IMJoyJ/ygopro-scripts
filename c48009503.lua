--H－C ガーンデーヴァ
-- 效果：
-- 战士族4星怪兽×2
-- 对方场上有4星以下的怪兽特殊召唤时，可以通过把这张卡1个超量素材取除，那些特殊召唤的怪兽破坏。这个效果1回合只能使用1次。
function c48009503.initial_effect(c)
	-- 添加XYZ召唤手续，使用满足种族为战士族的等级为4的怪兽进行叠放，需要2只
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
-- 过滤满足条件的怪兽：表侧表示、对方控制、等级为4以下，并且与当前效果有关联
function c48009503.filter(c,e,tp)
	return c:IsFaceup() and c:IsControler(1-tp) and c:IsLevelBelow(4) and (not e or c:IsRelateToEffect(e))
end
-- 将自身1个超量素材移除作为发动cost
function c48009503.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置连锁处理的目标为满足条件的特殊召唤怪兽，准备进行破坏效果
function c48009503.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c48009503.filter,1,nil,nil,tp) end
	-- 将目标怪兽设置为连锁处理对象
	Duel.SetTargetCard(eg)
	-- 设置操作信息，说明本次连锁将执行破坏效果，影响的怪兽数量为eg的数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- 执行效果操作，对符合条件的怪兽进行破坏
function c48009503.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c48009503.filter,nil,e,tp)
	-- 以效果原因破坏目标怪兽
	Duel.Destroy(g,REASON_EFFECT)
end
