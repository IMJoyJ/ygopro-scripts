--六武衆の軍大将
-- 效果：
-- 包含「六武众」怪兽的战士族怪兽2只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。把持有把武士道指示物放置效果的1张卡从卡组加入手卡。
-- ②：只要这张卡在怪兽区域存在，每次这张卡所连接区有「六武众」怪兽召唤·特殊召唤，给这张卡放置1个武士道指示物。
-- ③：这张卡的攻击力上升自己场上的武士道指示物数量×100。
function c74752631.initial_effect(c)
	c:EnableCounterPermit(0x3)
	-- 连接召唤素材设定：战士族怪兽2只，且至少包含1只「六武众」怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),2,2,c74752631.lcheck)
	c:EnableReviveLimit()
	-- 初始化卡片效果：注册连接召唤成功时丢弃1张手牌检索能放置武士道指示物卡片的诱发效果
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
	-- 初始化卡片效果：注册连接区有「六武众」怪兽召·特召时放置武士道指示物的场上持续效果
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
	-- 初始化卡片效果：注册攻击力上升自己场上武士道指示物数量×100的永续效果
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
-- 连接素材检查：素材中是否至少包含1只「六武众」怪兽
function c74752631.lcheck(g,lc)
	return g:IsExists(Card.IsLinkSetCard,1,nil,0x103d)
end
-- ①效果发动条件：此卡是以连接召唤方式特殊召唤成功
function c74752631.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- ①效果发动Cost：丢弃1张手牌
function c74752631.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌丢弃1张卡作为Cost
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索卡片过滤条件：具有放置武士道指示物效果且可加入手牌
function c74752631.thfilter(c)
	-- 判断卡片是否有放置武士道指示物的效果且能加入手牌
	return aux.IsCounterAdded(c,0x3) and c:IsAbleToHand()
end
-- ①效果发动准备：检查卡组是否存在满足条件的卡并设置检索操作信息
function c74752631.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的放置武士道指示物的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c74752631.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组把1张可放置武士道指示物的卡加入手牌
function c74752631.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c74752631.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 召·特召怪兽位置及字段过滤：是否为在连接区召·特召的「六武众」表侧表示怪兽
function c74752631.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0x103d) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0x103d) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- ②效果发动条件：检查是否有「六武众」怪兽在连接区召·特召
function c74752631.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c74752631.cfilter,1,nil,e:GetHandler())
end
-- ②效果处理：给此卡放置1个武士道指示物
function c74752631.ctop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x3,1)
end
-- ③效果攻击力上升数值计算：计算自己场上所有武士道指示物总数×100
function c74752631.atkval(e,c)
	-- 返回自己场上武士道指示物总数乘以100的值
	return Duel.GetCounter(c:GetControler(),1,0,0x3)*100
end
