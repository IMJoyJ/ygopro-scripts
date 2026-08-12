--ファーニマル・ドッグ
-- 效果：
-- 「毛绒动物·狗」的效果1回合只能使用1次。
-- ①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物·狗」以外的「毛绒动物」怪兽加入手卡。
function c39246582.initial_effect(c)
	-- ①：这张卡从手卡的召唤·特殊召唤成功时才能发动。从卡组把1只「锋利小鬼·剪刀」或者1只「毛绒动物·狗」以外的「毛绒动物」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39246582,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,39246582)
	e1:SetCondition(c39246582.thcon)
	e1:SetTarget(c39246582.thtg)
	e1:SetOperation(c39246582.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 效果发动的条件：这张卡是从手卡召唤或特殊召唤成功
function c39246582.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 检索卡牌的过滤条件：卡号为锋利小鬼·剪刀或属于毛绒动物卡组且为怪兽卡且不是毛绒动物·狗的卡
function c39246582.filter(c)
	return (c:IsCode(30068120) or (c:IsSetCard(0xa9) and c:IsType(TYPE_MONSTER) and not c:IsCode(39246582)))
		and c:IsAbleToHand()
end
-- 效果的发动时点处理：检查卡组中是否存在满足条件的卡并设置操作信息
function c39246582.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c39246582.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要从卡组加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果的处理过程：提示选择卡牌并进行检索和确认
function c39246582.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,c39246582.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
