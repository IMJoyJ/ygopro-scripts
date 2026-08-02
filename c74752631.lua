--六武衆の軍大将
-- 效果：
-- 包含「六武众」怪兽的战士族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。把持有把武士道指示物放置效果的1张卡从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，每次这张卡所连接区有「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
-- ③：这张卡的攻击力上升自己场上的武士道指示物数量×100。
function c74752631.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 为这张卡添加需要包含「六武众」怪兽的2只战士族怪兽的连接召唤手续
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,c74752631.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。把持有把武士道指示物放置效果的1张卡从卡组加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(74752631,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,74752631)
	e1:SetCondition(c74752631.thcon)
	e1:SetCost(c74752631.thcost)
	e1:SetTarget(c74752631.thtg)
	e1:SetOperation(c74752631.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，每次这张卡所连接区有「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c74752631.ctcon)
	e2:SetOperation(c74752631.ctop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡的攻击力上升自己场上的武士道指示物数量×100。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_UPDATE_ATTACK)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(c74752631.atkval)
	c:RegisterEffect(e4)
end
c74752631.counter_add_list={0x3}
c74752631.mentioned_counter={
	[0x3]=true,
}
-- 检查连接素材中是否包含「六武众」怪兽
function c74752631.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x103d)
end
-- 检查这张卡是否是连接召唤的
function c74752631.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 丢弃1张手卡作为代价
function c74752631.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 选择1张手卡并丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤持有把武士道指示物放置效果且能加入手卡的卡
function c74752631.thfilter(c)
	-- 检查是否为记述有放置武士道指示物并且能加入手卡的卡
	return aux.IsCounterAdded(c,0x3) and c:IsAbleToHand()
end
-- 检查卡组中是否存在满足条件的卡，并设置加入手卡的操作信息
function c74752631.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74752631.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 从卡组把1张满足条件的卡加入手卡并确认
function c74752631.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c74752631.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检查召唤·特殊召唤的怪兽是否在所连接区且为「六武众」怪兽
function c74752631.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0x103d) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0x103d) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 检查事件发生的怪兽中是否有满足过滤条件的怪兽
function c74752631.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74752631.cfilter,1,nil,e:GetHandler())
end
-- 给这张卡放置1个武士道指示物
function c74752631.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x3,1)
end
-- 计算这张卡的攻击力上升值
function c74752631.atkval(e,c)
	-- 计算自己场上的武士道指示物数量×100
	return Duel.GetCounter(c:GetControler(),1,0,0x3)*100
end
