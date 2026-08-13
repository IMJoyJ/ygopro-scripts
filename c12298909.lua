--マテリアルドラゴン
-- 效果：
-- 只要这张卡在自己场上表侧表示存在，给与基本分伤害的效果变成基本分回复的效果。此外，持有「把场上的怪兽破坏的效果」的魔法·陷阱·效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
function c12298909.initial_effect(c)
	-- 此外，持有「把场上的怪兽破坏的效果」的魔法·陷阱·效果怪兽的效果发动时，可以把1张手卡送去墓地让那个发动无效并破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12298909,0))  --"破坏场上怪物的效果发动无效并破坏"
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c12298909.condition)
	e1:SetCost(c12298909.cost)
	e1:SetTarget(c12298909.target)
	e1:SetOperation(c12298909.operation)
	c:RegisterEffect(e1)
	-- 只要这张卡在自己场上表侧表示存在，给与基本分伤害的效果变成基本分回复的效果。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_REVERSE_DAMAGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,1)
	e2:SetValue(c12298909.rev)
	c:RegisterEffect(e2)
end
-- 判定触发伤害是否属于效果伤害（reason含REASON_EFFECT），若是则返回真，使该效果伤害被转换为生命值回复。
function c12298909.rev(e,re,r,rp,rc)
	return bit.band(r,REASON_EFFECT)>0
end
-- 筛选处于场上且为怪兽卡的卡片，用于判断破坏效果是否涉及场上的怪兽。
function c12298909.filter(c)
	return c:IsOnField() and c:IsType(TYPE_MONSTER)
end
-- 作为诱发即时效果的发动条件：本卡不是当前发动中的效果、本卡未处于战斗破坏确定状态、该连锁可以被无效，且对应破坏效果的操作信息中存在至少1只符合条件的场上怪兽作为破坏对象。
function c12298909.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 若当前发动的是本卡自身效果、本卡已因战斗被破坏确定、或连锁不能被无效，则不满足发动条件，返回false。
	if e==re or e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) or not Duel.IsChainNegatable(ev) then return false end
	-- 从连锁数据中获取该效果是否包含破坏分类，并取得其破坏对象组tg及预计破坏数量tc，用于后续判断对象中是否包含场上怪兽。
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c12298909.filter,nil)-tg:GetCount()>0
end
-- 发动代价：从手卡丢弃1张卡作为代价，用于发动“无效并破坏”的效果。
function c12298909.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以作为代价送去墓地的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家从手卡选择1张卡丢弃到墓地，作为发动效果的代价（REASON_COST）。
	Duel.DiscardHand(tp,Card.IsAbleToGraveAsCost,1,1,REASON_COST)
end
-- 目标处理：效果发动时无需选择对象，直接设置操作信息，宣告本次处理包含“无效发动”分类，并在效果持有者可被破坏且与效果相关时设置“破坏”分类。
function c12298909.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息，宣告本次连锁处理将包含“使发动无效”的效果，对象为发动中的效果所对应的卡（eg）。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置操作信息，宣告本次连锁处理将包含“破坏”的效果，对象为发动中的效果所对应的卡（eg）。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- 效果处理：先尝试无效该连锁的发动，若无效成功且效果持有者仍与该效果相关，则将其破坏。
function c12298909.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否成功无效了该效果的发动，并且效果持有者仍然与该效果存在关联（未被离场等重置），只有两者同时满足时才执行破坏。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		-- 以效果原因（REASON_EFFECT）将eg中的卡破坏，即破坏发动那个被无效效果的卡。
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
