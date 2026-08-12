--レアル・ジェネクス・ヴィンディカイト
-- 效果：
-- 「次世代」调整＋调整以外的风属性怪兽1只以上
-- ①：对方怪兽不能选择这张卡作为攻击对象。
-- ②：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只「次世代」怪兽加入手卡。
function c73483491.initial_effect(c)
	-- 添加同调召唤手续：以「次世代」调整为调整，调整以外的风属性怪兽1只以上为非调整
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x2),aux.NonTuner(Card.IsAttribute,ATTRIBUTE_WIND),1)
	c:EnableReviveLimit()
	-- ①：对方怪兽不能选择这张卡作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_BE_BATTLE_TARGET)
	-- 设置不能成为攻击对象效果的过滤函数（不受效果影响的怪兽除外）
	e1:SetValue(aux.imval1)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。从卡组把1只「次世代」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73483491,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c73483491.thcon)
	e2:SetTarget(c73483491.thtg)
	e2:SetOperation(c73483491.thop)
	c:RegisterEffect(e2)
end
-- 设置效果发动的条件：这张卡在战斗中，且战斗破坏的对方怪兽是怪兽卡
function c73483491.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsRelateToBattle() and c:GetBattleTarget():IsType(TYPE_MONSTER)
end
-- 过滤函数：卡组中可以加入手牌的「次世代」怪兽
function c73483491.filter(c)
	return c:IsSetCard(0x2) and c:IsAbleToHand()
end
-- 设置效果发动的目标：检查卡组中是否存在可检索的卡，并设置操作信息
function c73483491.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的「次世代」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73483491.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 设置效果运行的操作：从卡组选择1只「次世代」怪兽加入手牌并给对方确认
function c73483491.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「次世代」怪兽
	local g=Duel.SelectMatchingCard(tp,c73483491.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
