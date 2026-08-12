--魂粉砕
-- 效果：
-- 支付500分，互相选择对方墓地的1张怪兽卡。选择的卡从游戏中除外。这个效果在自己的场上有恶魔族存在的场合才能发动。
function c76297408.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 支付500分，互相选择对方墓地的1张怪兽卡。选择的卡从游戏中除外。这个效果在自己的场上有恶魔族存在的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76297408,0))  --"除外"
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(c76297408.condition)
	e2:SetCost(c76297408.cost)
	e2:SetTarget(c76297408.target)
	e2:SetOperation(c76297408.operation)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的恶魔族怪兽
function c76297408.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 过滤条件：墓地的怪兽卡且可以被除外
function c76297408.rfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToRemove()
end
-- 发动条件：自己场上有恶魔族怪兽存在
function c76297408.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的恶魔族怪兽
	return Duel.IsExistingMatchingCard(c76297408.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 发动代价：支付500基本分
function c76297408.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 玩家支付500基本分
	Duel.PayLPCost(tp,500)
end
-- 效果的目标选择与处理信息设置
function c76297408.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方墓地是否存在可以除外的怪兽卡
	if chk==0 then return Duel.IsExistingTarget(c76297408.rfilter,tp,0,LOCATION_GRAVE,1,nil)
		-- 以及自己墓地是否存在可以除外的怪兽卡
		and Duel.IsExistingTarget(c76297408.rfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示回合玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 回合玩家选择对方墓地的1张怪兽卡作为效果对象
	local g1=Duel.SelectTarget(tp,c76297408.rfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	-- 提示非回合玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 非回合玩家选择对方（即回合玩家）墓地的1张怪兽卡作为效果对象
	local g2=Duel.SelectTarget(1-tp,c76297408.rfilter,1-tp,0,LOCATION_GRAVE,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息：将双方选择的墓地卡片除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,g1:GetCount(),PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：将选择的卡片除外
function c76297408.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	if not g then return end
	g=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍适用的对象卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
