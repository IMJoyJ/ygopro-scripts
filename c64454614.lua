--アルカナ エクストラジョーカー
-- 效果：
-- 卡名不同的战士族怪兽3只
-- ①：1回合1次，以场上的这张卡或者这张卡所连接区的怪兽为对象的怪兽的效果·魔法·陷阱卡发动时，把和那张卡相同种类（怪兽·魔法·陷阱）的1张手卡丢弃才能发动。那个发动无效。
-- ②：连接召唤的这张卡被战斗破坏送去墓地时才能发动。从卡组把1只战士族·4星的通常怪兽特殊召唤，从卡组把1只战士族·4星怪兽加入手卡。
function c64454614.initial_effect(c)
	-- 添加连接召唤手续：卡名不同的战士族怪兽3只
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_WARRIOR),3,3,c64454614.lcheck)
	c:EnableReviveLimit()
	-- ①：1回合1次，以场上的这张卡或者这张卡所连接区的怪兽为对象的怪兽的效果·魔法·陷阱卡发动时，把和那张卡相同种类（怪兽·魔法·陷阱）的1张手卡丢弃才能发动。那个发动无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64454614,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c64454614.negcon)
	e1:SetCost(c64454614.negcost)
	e1:SetTarget(c64454614.negtg)
	e1:SetOperation(c64454614.negop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗破坏送去墓地时才能发动。从卡组把1只战士族·4星的通常怪兽特殊召唤，从卡组把1只战士族·4星怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(64454614,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c64454614.spcon)
	e2:SetTarget(c64454614.sptg)
	e2:SetOperation(c64454614.spop)
	c:RegisterEffect(e2)
end
-- 检查连接素材的卡名是否各不相同
function c64454614.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 过滤出属于当前连锁对象卡片组的卡
function c64454614.negfilter(c,g)
	return g:IsContains(c)
end
-- 效果①的发动条件判定：以场上的这张卡或其所连接区的怪兽为对象的卡的效果发动时
function c64454614.negcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_BATTLE_DESTROYED) then return false end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return end
	local lg=e:GetHandler():GetLinkedGroup()
	lg:AddCard(c)
	-- 获取当前连锁的对象卡片组
	local tg=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	-- 判定对象卡片组中是否包含这张卡或其所连接区的怪兽，且该发动可以被无效
	return tg and lg:IsExists(c64454614.negfilter,1,nil,tg) and Duel.IsChainNegatable(ev)
end
-- 过滤出与发动效果的卡相同种类且可以丢弃的手卡
function c64454614.costfilter(c,tpe)
	return c:IsType(tpe) and c:IsDiscardable()
end
-- 效果①的Cost：丢弃1张与发动效果的卡相同种类的手卡
function c64454614.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local rtype=bit.band(re:GetActiveType(),0x7)
	-- 检查手卡中是否存在至少1张与发动效果的卡相同种类的可丢弃卡
	if chk==0 then return Duel.IsExistingMatchingCard(c64454614.costfilter,tp,LOCATION_HAND,0,1,nil,rtype) end
	-- 玩家选择并丢弃1张与发动效果的卡相同种类的手卡
	Duel.DiscardHand(tp,c64454614.costfilter,1,1,REASON_COST+REASON_DISCARD,nil,rtype)
end
-- 效果①的发动准备：设置效果分类为“无效发动”
function c64454614.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为“使该发动无效”
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果①的效果处理：使发动无效
function c64454614.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 使当前连锁的发动无效
	Duel.NegateActivation(ev)
end
-- 效果②的发动条件判定：连接召唤的这张卡被战斗破坏送去墓地时
function c64454614.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤出卡组中可以特殊召唤的战士族·4星通常怪兽，且卡组中还存在另一张可检索的战士族·4星怪兽
function c64454614.spfilter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevel(4) and c:IsRace(RACE_WARRIOR) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查卡组中是否存在除该特召怪兽以外的、可加入手牌的战士族·4星怪兽
		and Duel.IsExistingMatchingCard(c64454614.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 过滤出卡组中可以加入手牌的战士族·4星怪兽
function c64454614.thfilter(c)
	return c:IsLevel(4) and c:IsRace(RACE_WARRIOR) and c:IsAbleToHand()
end
-- 效果②的发动准备：检查怪兽区域空位并设置效果分类
function c64454614.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的特殊召唤怪兽（且能同时满足检索条件）
		and Duel.IsExistingMatchingCard(c64454614.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置当前连锁的操作信息为“从卡组特殊召唤1只怪兽”
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组特殊召唤1只战士族·4星通常怪兽，并从卡组检索1只战士族·4星怪兽
function c64454614.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从卡组选择1只满足条件的战士族·4星通常怪兽
	local g1=Duel.SelectMatchingCard(tp,c64454614.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 若成功将选中的怪兽特殊召唤
	if g1:GetCount()>0 and Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 给对方确认特殊召唤的卡
		Duel.ConfirmCards(1-tp,g1)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家从卡组选择1只战士族·4星怪兽
		local g2=Duel.SelectMatchingCard(tp,c64454614.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 将选中的怪兽加入玩家手牌
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
		end
	end
end
