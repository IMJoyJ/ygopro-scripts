--アクアアクトレス・アロワナ
-- 效果：
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只「水伶女」怪兽加入手卡。
function c92053608.initial_effect(c)
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只「水伶女」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c92053608.thtg)
	e1:SetOperation(c92053608.thop)
	c:RegisterEffect(e1)
end
-- 过滤卡组中属于「水伶女」系列的怪兽卡且能加入手牌的卡
function c92053608.filter(c)
	return c:IsSetCard(0xcd) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动准备与效果分类设置
function c92053608.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段，检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92053608.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，表示该效果会将卡组中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理，从卡组检索「水伶女」怪兽
function c92053608.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c92053608.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入玩家手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
