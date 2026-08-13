--ヴェルズ・ナイトメア
-- 效果：
-- 暗属性4星怪兽×2
-- ①：对方把怪兽特殊召唤时，把这张卡1个超量素材取除才能发动。那些怪兽变成里侧守备表示。
function c359563.initial_effect(c)
	-- 为这张卡添加超量召唤手续：可用2只暗属性4星怪兽作为超量素材叠放召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),4,2)
	c:EnableReviveLimit()
	-- ①：对方把怪兽特殊召唤时，把这张卡1个超量素材取除才能发动。那些怪兽变成里侧守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(359563,0))  --"变成里侧守备表示"
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c359563.cost)
	e1:SetTarget(c359563.target)
	e1:SetOperation(c359563.operation)
	c:RegisterEffect(e1)
end
-- 定义可被变成里侧守备表示的怪兽的筛选条件：必须是表侧表示、可以变成里侧表示、由对方玩家特殊召唤，且（若传入效果e）与该效果仍有联系。
function c359563.filter(c,e,tp)
	return c:IsFaceup() and c:IsCanTurnSet() and c:IsSummonPlayer(1-tp) and (not e or c:IsRelateToEffect(e))
end
-- 代价处理：发动时确认这张卡有至少1个超量素材可作为代价，然后取除1个超量素材作为发动代价。
function c359563.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果发动时的对象选择：检查特殊召唤的怪兽群中是否存在符合条件的怪兽，若有则将那群怪兽全部设为对象，并设置改变表示形式的操作信息。
function c359563.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c359563.filter,1,nil,nil,tp) end
	-- 将此次特殊召唤成功的那些怪兽（eg）全部设置为当前连锁处理的对象，确保后续处理时能确认与效果的关联。
	Duel.SetTargetCard(eg)
	-- 设置操作信息：本次效果处理为改变表示形式（CATEGORY_POSITION），涉及对象为eg中的所有怪兽，数量为eg的数量。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,eg,eg:GetCount(),0,0)
end
-- 效果处理时，从之前特殊召唤的怪兽群中筛选仍然满足条件且与效果仍有联系的怪兽，并将它们全部变成里侧守备表示。
function c359563.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=eg:Filter(c359563.filter,nil,e,tp)
	-- 将筛选出的怪兽全部改变为里侧守备表示。
	Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
end
