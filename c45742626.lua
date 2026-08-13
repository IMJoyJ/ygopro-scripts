--巡死神リーパー
-- 效果：
-- 6星怪兽×2
-- 「巡死神 收割者」的②的效果1回合只能使用1次。
-- ①：这张卡的攻击力·守备力上升双方墓地的暗属性怪兽数量×200。
-- ②：把这张卡1个超量素材取除才能发动。从双方卡组上面把5张卡送去墓地。
function c45742626.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：可以用2只等级6的怪兽作为超量素材来进行超量召唤（不限制素材怪兽的具体卡名或种族）。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡1个超量素材取除才能发动。从双方卡组上面把5张卡送去墓地。
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
-- 定义①效果的数值提供函数：统计双方墓地中暗属性怪兽的数量并乘以200，作为攻击力（克隆后为守备力）的提升值。
function c45742626.value(e,c)
	-- 统计双方墓地中满足暗属性条件的怪兽数量，乘以200作为攻击力/守备力的增减数值。
	return Duel.GetMatchingGroupCount(Card.IsAttribute,0,LOCATION_GRAVE,LOCATION_GRAVE,nil,ATTRIBUTE_DARK)*200
end
-- 定义②效果的发动代价：检查并移除这张卡的1个超量素材；chk==0时仅检查可行性，正式发动时执行移除。
function c45742626.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 定义②效果的发动目标与合法性判断：确认双方玩家都能将卡组顶5张送去墓地，并设置操作信息表明将双方卡组顶共10张送去墓地。
function c45742626.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查阶段，判断我方和对方是否都至少能从卡组顶将5张卡送去墓地（即双方卡组都至少有5张）。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,5) and Duel.IsPlayerCanDiscardDeck(1-tp,5) end
	-- 设置当前连锁的操作信息：本次效果包含从卡组送墓地的分类，处理对象为双方玩家各卡组顶5张（不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,PLAYER_ALL,5)
end
-- 定义②效果的处理：分别取出自己和对方卡组顶各5张卡，合并后一次性从卡组送去墓地，并禁止自动洗牌检查。
function c45742626.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得我方卡组最上方的5张卡。
	local g1=Duel.GetDecktopGroup(tp,5)
	-- 取得对方卡组最上方的5张卡。
	local g2=Duel.GetDecktopGroup(1-tp,5)
	g1:Merge(g2)
	-- 禁用此次操作的系统自动洗牌检查，因为直接从卡组顶取出卡送去墓地，无需在效果结束后洗牌。
	Duel.DisableShuffleCheck()
	-- 将合并后的双方卡组顶的卡（共10张）以“效果”为原因送去墓地。
	Duel.SendtoGrave(g1,REASON_EFFECT)
end
