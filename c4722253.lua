--ライトレイ ギア・フリード
-- 效果：
-- 这张卡不能通常召唤。自己墓地的光属性怪兽是5种类以上的场合才能特殊召唤。自己场上表侧表示存在的怪兽只有战士族的场合，可以把自己墓地1只战士族怪兽从游戏中除外，魔法·陷阱卡的发动无效并破坏。这个效果1回合只能使用1次。
function c4722253.initial_effect(c)
	c:EnableReviveLimit()
	-- 自己墓地的光属性怪兽是5种类以上的场合才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c4722253.spcon)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。
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
-- 特殊召唤手续的条件判定：检查这张卡是否能用自身规则特殊召唤——需要自己墓地存在5种类以上的光属性怪兽，且自己场上有可用的怪兽区域。
function c4722253.spcon(e,c)
	if c==nil then return true end
	-- 判断该怪兽的控制者场上是否有空余的怪兽区域，若无空闲区域则不能进行特殊召唤。
	if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)<=0 then return false end
	-- 获取该玩家墓地中所有的光属性怪兽，用于后续统计不同卡名的种类数。
	local g=Duel.GetMatchingGroup(Card.IsAttribute,c:GetControler(),LOCATION_GRAVE,0,nil,ATTRIBUTE_LIGHT)
	local ct=g:GetClassCount(Card.GetCode)
	return ct>4
end
-- 过滤函数：判断场上表侧表示存在的怪兽是否不是战士族，用于检测“场上存在非战士族怪兽”的情况。
function c4722253.cfilter(c)
	return c:IsFaceup() and not c:IsRace(RACE_WARRIOR)
end
-- 该效果发动条件判定：自己场上表侧表示存在的怪兽只有战士族，且连锁中的效果是魔法·陷阱卡的发动并可以被无效，同时自身未被战斗破坏确定。
function c4722253.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件前半部分：自身不处于战斗破坏确定状态；连锁的效果是魔法·陷阱卡的发动；该连锁的发动可以被无效。
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 条件后半部分：自己场上不存在表侧表示的非战士族怪兽，即自己场上表侧表示存在的怪兽只有战士族。
		and not Duel.IsExistingMatchingCard(c4722253.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：选择墓地中满足战士族且可以除外的怪兽，作为发动代价的候选。
function c4722253.cfilter2(c)
	return c:IsRace(RACE_WARRIOR) and c:IsAbleToRemove()
end
-- 代价处理：从自己墓地选择1只战士族怪兽除外；在检查阶段先确认是否存在符合条件的怪兽，若存在则执行选择并除外。
function c4722253.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：确认墓地中是否存在至少1只可除外的战士族怪兽，若不存在则无法发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c4722253.cfilter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家显示“请选择要除外的卡”的提示，用于选择要除外的战士族怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己墓地选择1只战士族且可以除外的怪兽作为发动代价。
	local g=Duel.SelectMatchingCard(tp,c4722253.cfilter2,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的战士族怪兽以表侧表示除外，作为效果发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 目标处理：登记无效并破坏魔法·陷阱卡的操作信息，不取对象，处理时再决定是否破坏。
function c4722253.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：将当前连锁中的魔法·陷阱卡标记为无效对象（CATEGORY_NEGATE）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 若该魔法·陷阱卡可以被破坏且仍与当前连锁相关，则追加登记破坏该卡（CATEGORY_DESTROY）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 过滤函数：判断怪兽是否为表侧表示的战士族怪兽，用于处理时确认场上仍有符合条件的战士族怪兽。
function c4722253.cfilter3(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果处理开始时再次确认条件：若自己场上不存在非战士族的表侧怪兽，且存在表侧战士族怪兽，则继续处理；否则效果不适用。
function c4722253.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的非战士族怪兽，若存在则条件不满足，效果不处理。
	if Duel.IsExistingMatchingCard(c4722253.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 若自己场上不存在任何表侧表示的战士族怪兽，则条件不满足，效果不处理。
		or not Duel.IsExistingMatchingCard(c4722253.cfilter3,tp,LOCATION_MZONE,0,1,nil) then return end
	-- 尝试无效该魔法·陷阱卡的发动；若无效成功且该卡仍与当前连锁相关，则继续执行破坏处理。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 将已无效发动的魔法·陷阱卡破坏，破坏原因为效果（REASON_EFFECT）。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
