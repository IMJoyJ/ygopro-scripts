--フォトン・リザード
-- 效果：
-- 把这张卡解放才能发动。从卡组把1只4星以下的名字带有「光子」的怪兽加入手卡。「光子蜥蜴」的效果1回合只能使用1次。
function c38973775.initial_effect(c)
	-- 把这张卡解放才能发动。从卡组把1只4星以下的名字带有「光子」的怪兽加入手卡。「光子蜥蜴」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38973775,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,38973775)
	e1:SetCost(c38973775.cost)
	e1:SetTarget(c38973775.target)
	e1:SetOperation(c38973775.operation)
	c:RegisterEffect(e1)
end
-- 效果发动前的代价检查与执行：先确认自身是否满足可解放条件，若满足则把这张卡解放作为发动代价。
function c38973775.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 以规则代价解放这张卡（效果怪兽自身作为解放素材）。
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 定义检索对象必须满足的条件：等级4以下、持有「光子」字段且可以加入手卡。
function c38973775.filter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x55) and c:IsAbleToHand()
end
-- 效果发动目标：确认卡组中存在符合条件的可检索怪兽，并设置操作信息为从卡组将1张怪兽加入手卡。
function c38973775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足filter条件的卡，作为效果能否发动的判定。
	if chk==0 then return Duel.IsExistingMatchingCard(c38973775.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果的操作信息：从卡组将1张卡加入手卡，供系统及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：玩家从卡组选择1张满足条件的「光子」怪兽加入手卡，并向对手展示。
function c38973775.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给出选择提示，提示玩家正在选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足filter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c38973775.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认被加入手卡的卡片，以公开检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
