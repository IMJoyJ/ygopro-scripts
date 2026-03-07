--ドラグニティナイト－ガジャルグ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只4星以下的龙族·鸟兽族怪兽加入手卡。那之后，从手卡选1只龙族·鸟兽族怪兽丢弃。
function c34116027.initial_effect(c)
	-- 添加同调召唤手续，需要1只龙族调整和1只鸟兽族调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：1回合1次，自己主要阶段才能发动。从卡组把1只4星以下的龙族·鸟兽族怪兽加入手卡。那之后，从手卡选1只龙族·鸟兽族怪兽丢弃。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34116027,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c34116027.target)
	e1:SetOperation(c34116027.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足条件的卡：等级不超过4星、种族为龙族或鸟兽族、可以加入手牌
function c34116027.filter(c)
	return c:IsLevelBelow(4) and c:IsRace(RACE_DRAGON+RACE_WINDBEAST) and c:IsAbleToHand()
end
-- 设置连锁处理时的操作信息，包括从卡组检索1张符合条件的卡和丢弃1张手牌
function c34116027.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c34116027.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将1张符合条件的卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置操作信息：丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,1,tp,1)
end
-- 效果处理函数，执行检索和丢弃操作
function c34116027.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c34116027.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()==0 then return end
	-- 将选中的卡加入手牌
	Duel.SendtoHand(g,nil,REASON_EFFECT)
	-- 向对方确认翻开的卡
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手牌
	Duel.ShuffleHand(tp)
	-- 中断当前效果处理
	Duel.BreakEffect()
	-- 丢弃1张手牌，要求为龙族或鸟兽族
	Duel.DiscardHand(tp,Card.IsRace,1,1,REASON_EFFECT+REASON_DISCARD,nil,RACE_DRAGON+RACE_WINDBEAST)
end
