--恐牙狼 ダイヤウルフ
-- 效果：
-- 4星怪兽×2
-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只兽族·兽战士族·鸟兽族怪兽和场上1张卡为对象才能发动。那些卡破坏。
function c95169481.initial_effect(c)
	-- 添加超量召唤手续：4星怪兽×2
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- ①：1回合1次，把这张卡1个超量素材取除，以自己场上1只兽族·兽战士族·鸟兽族怪兽和场上1张卡为对象才能发动。那些卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(95169481,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c95169481.descost)
	e1:SetTarget(c95169481.destg)
	e1:SetOperation(c95169481.desop)
	c:RegisterEffect(e1)
end
-- 发动代价：把这张卡1个超量素材取除
function c95169481.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤自己场上表侧表示的兽族、鸟兽族、兽战士族怪兽，且场上存在其他卡作为破坏对象
function c95169481.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_WINDBEAST+RACE_BEASTWARRIOR)
		-- 检查场上是否存在除该怪兽以外的至少1张卡可以作为破坏对象
		and Duel.IsExistingTarget(aux.TRUE,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
end
-- 效果发动：选择自己场上1只兽族/兽战士族/鸟兽族怪兽和场上另1张卡作为对象
function c95169481.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 可行性检查：自己场上是否存在符合条件的兽族/兽战士族/鸟兽族怪兽
	if chk==0 then return Duel.IsExistingTarget(c95169481.desfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的第一张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只表侧表示的兽族/兽战士族/鸟兽族怪兽作为对象
	local g1=Duel.SelectTarget(tp,c95169481.desfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择要破坏的第二张卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上除第一张卡以外的任意1张卡作为对象
	local g2=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,g1:GetFirst())
	g1:Merge(g2)
	-- 设置效果处理的操作信息为破坏选中的2张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,g1:GetCount(),0,0)
end
-- 效果处理：破坏作为对象的卡
function c95169481.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍与效果相关的对象卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	-- 将这些卡因效果破坏
	Duel.Destroy(g,REASON_EFFECT)
end
