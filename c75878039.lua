--星因士 デネブ
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星因士 天津四」以外的1只「星骑士」怪兽加入手卡。
function c75878039.initial_effect(c)
	-- ①：这张卡召唤·反转召唤·特殊召唤的场合才能发动。从卡组把「星因士 天津四」以外的1只「星骑士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75878039,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,75878039)
	e1:SetTarget(c75878039.target)
	e1:SetOperation(c75878039.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c75878039.star_knight_summon_effect=e1
end
-- 过滤卡组中「星因士 天津四」以外的「星骑士」怪兽且能加入手牌的卡
function c75878039.filter(c)
	return c:IsSetCard(0x9c) and c:IsType(TYPE_MONSTER) and not c:IsCode(75878039) and c:IsAbleToHand()
end
-- 效果发动的目标检测与操作信息设置
function c75878039.target(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 在发动阶段，检测卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c75878039.filter,tp,LOCATION_DECK,0,1,exc) end
	-- 设置操作信息，声明该效果包含将卡组的1张卡加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理的执行，从卡组选择1只符合条件的怪兽加入手牌并给对方确认
function c75878039.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c75878039.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
