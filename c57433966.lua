--魅惑の未界域
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从手卡丢弃1只5星以上的「未界域」怪兽才能发动。从卡组把1只4星以下的「未界域」怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
function c57433966.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：从手卡丢弃1只5星以上的「未界域」怪兽才能发动。从卡组把1只4星以下的「未界域」怪兽加入手卡。这张卡的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,57433966+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c57433966.cost)
	e1:SetTarget(c57433966.target)
	e1:SetOperation(c57433966.activate)
	c:RegisterEffect(e1)
end
-- 过滤手牌中等级5星以上且可以丢弃的「未界域」怪兽
function c57433966.cfilter(c)
	return c:IsLevelAbove(5) and c:IsSetCard(0x11e) and c:IsDiscardable()
end
-- 发动代价处理：检查并从手卡丢弃1只5星以上的「未界域」怪兽
function c57433966.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57433966.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择并以发动代价和丢弃为原因丢弃1张手卡
	Duel.DiscardHand(tp,c57433966.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中等级4星以下、可以加入手卡的「未界域」怪兽
function c57433966.thfilter(c)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 发动效果的目标处理：检查卡组中是否存在满足条件的怪兽，并设置检索效果的操作信息
function c57433966.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1只满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c57433966.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组将1只4星以下的「未界域」怪兽加入手卡，并对玩家施加不能特殊召唤非「未界域」怪兽的限制
function c57433966.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c57433966.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡片加入玩家手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是「未界域」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c57433966.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能特殊召唤非「未界域」怪兽的限制效果注册给玩家
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制特殊召唤的过滤函数，判定非「未界域」怪兽不能特殊召唤
function c57433966.splimit(e,c)
	return not c:IsSetCard(0x11e)
end
