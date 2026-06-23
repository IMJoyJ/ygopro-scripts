--原初の種
-- 效果：
-- 「混沌战士 -开辟的使者-」或「混沌帝龙 -终焉的使者-」在场上存在的场合，这张卡才能发动。将自己2张从游戏中除外的卡加入自己手卡。
function c23701465.initial_effect(c)
	-- 创建效果，设置效果分类为回手牌，设置为取对象效果，设置为魔陷发动，设置为自由时点，设置发动条件、目标和效果处理函数
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c23701465.condition)
	e1:SetTarget(c23701465.target)
	e1:SetOperation(c23701465.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查场上是否存在表侧表示的「混沌战士 -开辟的使者-」或「混沌帝龙 -终焉的使者-」
function c23701465.cfilter(c)
	return c:IsFaceup() and c:IsCode(72989439,82301904)
end
-- 发动条件函数，检查场上是否存在至少1张满足cfilter条件的卡
function c23701465.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1张满足cfilter条件的卡
	return Duel.IsExistingMatchingCard(c23701465.cfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
-- 效果目标函数，设置选择对象为己方除外区中能加入手牌的卡，选择2张
function c23701465.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and chkc:IsAbleToHand()end
	-- 检查己方除外区是否存在至少2张能加入手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_REMOVED,0,2,nil) end
	-- 向玩家提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择己方除外区中2张能加入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_REMOVED,0,2,2,nil)
	-- 设置效果处理信息，指定将2张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果处理函数，获取连锁中的目标卡组并处理
function c23701465.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将满足条件的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
