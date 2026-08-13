--ベアルクティ・ディパーチャー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把2只「北极天熊」怪兽加入手卡。
-- ②：自己为让「北极天熊」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
function c16471775.initial_effect(c)
	-- ①：丢弃1张手卡才能发动。从卡组把2只「北极天熊」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,16471775)
	e1:SetCost(c16471775.cost)
	e1:SetTarget(c16471775.target)
	e1:SetOperation(c16471775.activate)
	c:RegisterEffect(e1)
	-- ②：自己为让「北极天熊」怪兽的效果发动而把怪兽解放的场合，可以作为代替把墓地的这张卡除外。这个效果在这张卡送去墓地的回合不能使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(16471775)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置e2的发动条件：这张卡送去墓地的回合不能发动（通过aux.exccon检查是否为送墓回合）。
	e2:SetCondition(aux.exccon)
	e2:SetCountLimit(1,16471776)
	c:RegisterEffect(e2)
end
-- 支付①效果的发动代价：从手牌丢弃1张手卡，先检查是否有可丢弃的手卡，然后执行丢弃。
function c16471775.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- cost检测阶段：确认存在1张可以丢弃的手卡（不包含这张卡自身），满足则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,c) end
	-- 实际执行代价：从手牌选择1张卡丢弃，丢弃理由为COST+REASON_DISCARD。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD,nil)
end
-- 定义检索过滤器：选择怪兽族且卡名含有「北极天熊」字段、可以被加入手卡的卡。
function c16471775.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x163) and c:IsAbleToHand()
end
-- ①效果的发动条件检测与操作信息设置：检查卡组是否有2只符合条件的「北极天熊」怪兽，并设置从卡组加入手卡的操作信息。
function c16471775.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- target检测阶段：确认卡组中存在至少2只满足filter的「北极天熊」怪兽，作为发动条件。
	if chk==0 then return Duel.IsExistingMatchingCard(c16471775.filter,tp,LOCATION_DECK,0,2,nil) end
	-- 设置连锁处理的操作信息：将“从卡组将2张卡加入手卡”的信息写入当前连锁，供效果处理和相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- ①效果的实际处理：从卡组选择2只「北极天熊」怪兽加入手牌，并向对手展示确认。
function c16471775.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家显示选择提示：请选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 使用过滤条件从卡组挑选2张符合条件的「北极天熊」怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c16471775.filter,tp,LOCATION_DECK,0,2,2,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
