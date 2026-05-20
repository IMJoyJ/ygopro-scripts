--発条装攻ゼンマイオー
-- 效果：
-- 5星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以场上2张里侧表示卡为对象才能发动。那些卡破坏。
function c77334267.initial_effect(c)
	-- 添加超量召唤手续：5星怪兽2只
	aux.AddXyzProcedure(c,nil,5,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以场上2张里侧表示卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(77334267,0))  --"破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c77334267.descost)
	e1:SetTarget(c77334267.destg)
	e1:SetOperation(c77334267.desop)
	c:RegisterEffect(e1)
end
-- 效果①的代价：把这张卡1个超量素材取除
function c77334267.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤条件：里侧表示的卡
function c77334267.filter(c)
	return c:IsFacedown()
end
-- 效果①的发动准备：选择场上2张里侧表示卡作为对象
function c77334267.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c77334267.filter(chkc) end
	-- 检查场上是否存在至少2张里侧表示卡可以作为效果对象
	if chk==0 then return Duel.IsExistingTarget(c77334267.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上2张里侧表示卡作为效果的对象
	local g=Duel.SelectTarget(tp,c77334267.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,2,2,nil)
	-- 设置效果处理信息：破坏选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,0,0)
end
-- 效果①的效果处理：将作为对象的卡破坏
function c77334267.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local dg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍存在于场上且与效果相关的对象卡片破坏
	Duel.Destroy(dg,REASON_EFFECT)
end
