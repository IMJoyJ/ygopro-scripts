--コアキメイルの金剛核
-- 效果：
-- 从卡组把「核成兽的金刚核」以外的1张名字带有「核成」的卡加入手卡。此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。这个回合，自己场上的名字带有「核成」的怪兽不会被破坏。
function c81994591.initial_effect(c)
	-- 从卡组把「核成兽的金刚核」以外的1张名字带有「核成」的卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81994591,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81994591.target)
	e1:SetOperation(c81994591.activate)
	c:RegisterEffect(e1)
	-- 此外，自己的主要阶段时把墓地的这张卡从游戏中除外才能发动。这个回合，自己场上的名字带有「核成」的怪兽不会被破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(81994591,1))  --"防止破坏"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	-- 将墓地的这张卡除外作为发动效果的代价
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c81994591.indop)
	c:RegisterEffect(e2)
end
-- 过滤卡组中「核成兽的金刚核」以外的名字带有「核成」且能加入手牌的卡
function c81994591.filter(c)
	return c:IsSetCard(0x1d) and not c:IsCode(81994591) and c:IsAbleToHand()
end
-- 检索效果的发动准备，检查卡组中是否存在可检索的卡并设置操作信息
function c81994591.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c81994591.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，让玩家从卡组选择1张符合条件的卡加入手牌并给对方确认
function c81994591.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c81994591.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 破坏抗性效果的处理，注册一个本回合内使自己场上「核成」怪兽不会被破坏的场上效果
function c81994591.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，自己场上的名字带有「核成」的怪兽不会被破坏。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	-- 设置效果的影响对象为名字带有「核成」的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1d))
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetValue(1)
	-- 在全局环境注册该效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
