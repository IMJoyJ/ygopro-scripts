--コマンド・リゾネーター
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只「共鸣者」怪兽才能发动。从卡组把1只4星以下的恶魔族怪兽加入手卡。
function c8559524.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡丢弃1只「共鸣者」怪兽才能发动。从卡组把1只4星以下的恶魔族怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,8559524+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c8559524.cost)
	e1:SetTarget(c8559524.target)
	e1:SetOperation(c8559524.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中可以丢弃的「共鸣者」怪兽
function c8559524.costfilter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 发动代价处理，检查并从手牌丢弃1只「共鸣者」怪兽
function c8559524.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手牌中是否存在可作为代价丢弃的「共鸣者」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8559524.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并丢弃手牌中的1只「共鸣者」怪兽作为发动代价
	Duel.DiscardHand(tp,c8559524.costfilter,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 过滤卡组中可以加入手牌的4星以下的恶魔族怪兽
function c8559524.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FIEND) and c:IsAbleToHand()
end
-- 效果发动时的目标检查与操作信息设置
function c8559524.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可加入手牌的4星以下的恶魔族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8559524.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果的处理为将卡组的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理，从卡组将1只4星以下的恶魔族怪兽加入手牌并给对方确认
function c8559524.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示其选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足条件的4星以下的恶魔族怪兽
	local g=Duel.SelectMatchingCard(tp,c8559524.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
