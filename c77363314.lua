--クリスタル・ドラゴン
-- 效果：
-- ①：1回合1次，这张卡进行过战斗的自己回合的战斗步骤才能发动。从卡组把1只龙族·8星怪兽加入手卡。
function c77363314.initial_effect(c)
	-- ①：1回合1次，这张卡进行过战斗的自己回合的战斗步骤才能发动。从卡组把1只龙族·8星怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77363314,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c77363314.thcon)
	e1:SetTarget(c77363314.thtg)
	e1:SetOperation(c77363314.thop)
	c:RegisterEffect(e1)
end
-- 定义效果的发动条件：当前是自己回合的战斗步骤，且没有正在处理的连锁，并且这张卡进行过战斗
function c77363314.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为自己回合的战斗步骤，且当前没有正在处理的连锁
	return Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_BATTLE_STEP and Duel.GetCurrentChain()==0
		and e:GetHandler():GetBattledGroupCount()>0
end
-- 过滤条件：龙族、8星且可以加入手牌的怪兽
function c77363314.thfilter(c)
	return c:IsRace(RACE_DRAGON) and c:IsLevel(8) and c:IsAbleToHand()
end
-- 定义效果的发动目标：检查卡组中是否存在符合条件的卡，并设置检索的操作信息
function c77363314.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c77363314.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义效果的处理：从卡组选择1只符合条件的怪兽加入手牌，并向对方展示
function c77363314.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c77363314.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
