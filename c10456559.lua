--悪魂邪苦止
-- 效果：
-- 自己场上存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把「恶魂邪苦止」加入手卡。之后卡组洗切。
function c10456559.initial_effect(c)
	-- 自己场上存在的这张卡被战斗破坏送去墓地时，可以从自己卡组把「恶魂邪苦止」加入手卡。之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetDescription(aux.Stringid(10456559,0))  --"把「恶魂邪苦止」加入手牌"
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c10456559.condition)
	e1:SetTarget(c10456559.target)
	e1:SetOperation(c10456559.operation)
	c:RegisterEffect(e1)
end
-- 触发条件判定：被战斗破坏的这张卡必须位于墓地，且其上一个控制者为发动效果的玩家，同时破坏原因必须是战斗。
function c10456559.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp) and c:IsReason(REASON_BATTLE)
end
-- 检索过滤函数：筛选出卡组中卡名为「恶魂邪苦止」（10456559）且能够加入手卡的卡。
function c10456559.filter(c)
	return c:IsCode(10456559) and c:IsAbleToHand()
end
-- 效果发动时的目标处理：确认卡组存在可检索的同名卡后，将本次效果的信息登记为从卡组把1张卡加入手牌。
function c10456559.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：当chk==0（效果发动前的确认阶段）时，检查自己卡组是否存在至少1张符合条件的「恶魂邪苦止」，否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c10456559.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：向连锁系统告知本效果涉及从卡组将卡加入手牌，用于后续时点/对应卡的判定。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段：提示玩家选择要加入手牌的卡，从卡组选择1~3张符合条件的「恶魂邪苦止」，并以效果原因加入持有者的手卡。
function c10456559.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：提示玩家正在选择要加入手牌的卡片（HINTMSG_ATOHAND）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 执行选择：从自己卡组中选出1~3张符合filter条件的「恶魂邪苦止」（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c10456559.filter,tp,LOCATION_DECK,0,1,3,nil)
	-- 将选中的卡以效果原因（REASON_EFFECT）送去持有者手卡，即加入手牌。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
