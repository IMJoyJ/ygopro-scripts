--巡死神リーパー
-- 效果：
-- 6星怪兽×2
-- 「巡死神 收割者」的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力上升双方墓地的暗属性怪兽数量×200。
-- ②：把这张卡1个超量素材取除才能发动。从双方卡组上面把5张卡送去墓地。
function c45742626.initial_effect(c)
	-- 添加XYZ召唤手续，使用等级为6的怪兽进行叠放，需要2只怪兽
	aux.AddXyzProcedure(c,nil,6,2)
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力·守备力上升双方墓地的暗属性怪兽数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c45742626.value)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
	-- ②：把这张卡1个超量素材取除才能发动。从双方卡组上面把5张卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(45742626,0))  --"卡组送墓"
	e3:SetCategory(CATEGORY_DECKDES)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,45742626)
	e3:SetCost(c45742626.cost)
	e3:SetTarget(c45742626.target)
	e3:SetOperation(c45742626.operation)
	c:RegisterEffect(e3)
end
-- 计算双方墓地暗属性怪兽数量并乘以200作为攻击力和守备力的增加量
function c45742626.value(e,c)
	-- 检索双方墓地的暗属性怪兽数量并乘以200
	return Duel.GetMatchingGroupCount(Card.IsAttribute,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,ATTRIBUTE_DARK)*200
end
-- 支付效果代价，从自身取除1个超量素材
function c45742626.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 设置效果目标，检查双方玩家是否可以将卡组顶部5张卡送去墓地
function c45742626.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方玩家是否可以将卡组顶部5张卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	-- 设置连锁操作信息，指定将卡组顶部5张卡送去墓地的效果分类
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
-- 执行效果操作，从双方卡组顶部各取5张卡并送去墓地
function c45742626.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组顶部5张卡
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 获取对方卡组顶部5张卡
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁止后续操作自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 将卡片组送去墓地
	Duel.SendtoGrave(g1,REASON_EFFECT)
end
