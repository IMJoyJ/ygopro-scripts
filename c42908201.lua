--デスマニア・デビル
-- 效果：
-- ①：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只4星以下的兽族怪兽加入手卡。
function c42908201.initial_effect(c)
	-- 创建效果，设置效果描述、分类、类型、时点、条件、目标和处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42908201,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果的发动条件为：这张卡战斗破坏对方怪兽时
	e1:SetCondition(aux.bdocon)
	e1:SetTarget(c42908201.target)
	e1:SetOperation(c42908201.operation)
	c:RegisterEffect(e1)
end
-- 定义过滤函数，用于筛选4星以下的兽族怪兽
function c42908201.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_BEAST) and c:IsAbleToHand()
end
-- 设置效果的目标处理函数，检查卡组中是否存在满足条件的怪兽
function c42908201.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查阶段判断卡组中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c42908201.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，指定将要从卡组检索1张怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果的处理函数，执行检索并加入手牌的操作
function c42908201.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c42908201.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方玩家看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
