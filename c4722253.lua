--ライトレイ ギア・フリード
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是5种类以上的场合才能特殊召唤。自己场上表侧表示存在的怪兽只有战士族的场合，可以把自己墓地1只战士族怪兽从游戏中除外，魔法·陷阱卡的发动无效并破坏。这个效果1回合只能使用1次。
function c4722253.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己墓地的光属性怪兽是5种类以上的场合才能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4722253.spcon)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤
	local e2=Effect.CreateEffect(c)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e2)
	-- 自己场上表侧表示存在的怪兽只有战士族的场合，可以把自己墓地1只战士族怪兽从游戏中除外，魔法·陷阱卡的发动无效并破坏。这个效果1回合只能使用1次。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(4722253,0))  --"破坏"
	e3:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_CHAINING)
	e3:SetCondition(c4722253.negcon)
	e3:SetCost(c4722253.negcost)
	e3:SetTarget(c4722253.negtg)
	e3:SetOperation(c4722253.negop)
	c:RegisterEffect(e3)
end
-- 检查是否满足特殊召唤条件：自己墓地光属性怪兽数量超过4种
function c4722253.spcon(e,c)
	if c==nil then return true end
	-- 检查场上是否有足够的召唤区域
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取自己墓地中所有光属性怪兽
	local g=Duel.GetMatchingGroup(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>4
end
-- 过滤函数：检查场上是否存在非战士族的表侧表示怪兽
function c4722253.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_WARRIOR)
end
-- 连锁发动时的条件判断：确认自身未因战斗破坏、对方发动的是魔法或陷阱效果且可无效，并且己方场上没有非战士族怪兽
function c4722253.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发动的连锁是魔法或陷阱卡的发动并且可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 确保自己场上没有非战士族的表侧表示怪兽
		and not Duel.IsExistingMatchingCard(c4722253.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：检查墓地中是否存在可除外的战士族怪兽
function c4722253.cfilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemove()
end
-- 效果的费用支付处理：从墓地选择一只战士族怪兽除外作为费用
function c4722253.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足费用支付条件：墓地是否存在至少一张战士族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c4722253.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张墓地中的战士族怪兽
	local g=Duel.SelectMatchingCard(tp,c4722253.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选中的怪兽从游戏中除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果发动时的操作信息：将无效和破坏的目标卡加入操作信息中
function c4722253.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将要使发动无效的卡加入操作信息
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 如果发动的卡可以被破坏，则将其加入操作信息
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数：检查场上是否存在战士族的表侧表示怪兽
function c4722253.cfilter3(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果发动时的处理逻辑：判断是否满足发动条件，若不满足则不执行后续操作
function c4722253.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断己方场上是否存在非战士族的表侧表示怪兽
	if Duel.IsExistingMatchingCard(c4722253.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断己方场上是否存在战士族的表侧表示怪兽
		or not Duel.IsExistingMatchingCard(c4722253.cfilter3,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 使连锁发动无效，并检查发动卡是否仍然有效
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 破坏被无效的魔法或陷阱卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
