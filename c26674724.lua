--ブリューナクの影霊衣
-- 效果：
-- 「影灵衣」仪式魔法卡降临
-- 这张卡若非以只使用除「光枪龙之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。这个卡名的①②的效果1回合各能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把「光枪龙之影灵衣」以外的1只「影灵衣」怪兽加入手卡。
-- ②：以从额外卡组特殊召唤的场上最多2只怪兽为对象才能发动。那些怪兽回到卡组。
function c26674724.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡若非以只使用除「光枪龙之影灵衣」以外的怪兽来作的仪式召唤则不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置此卡的特殊召唤条件为必须通过仪式召唤方式特殊召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把「光枪龙之影灵衣」以外的1只「影灵衣」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26674724,0))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,26674724)
	e2:SetCost(c26674724.thcost)
	e2:SetTarget(c26674724.thtg)
	e2:SetOperation(c26674724.thop)
	c:RegisterEffect(e2)
	-- ②：以从额外卡组特殊召唤的场上最多2只怪兽为对象才能发动。那些怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26674724,1))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,26674725)
	e3:SetTarget(c26674724.tdtg)
	e3:SetOperation(c26674724.tdop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断仪式召唤中使用的怪兽是否包含此卡本身。
function c26674724.mat_filter(c)
	return not c:IsCode(26674724)
end
-- 效果发动时的费用处理，将此卡丢入墓地作为费用。
function c26674724.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将此卡从手牌丢入墓地作为发动效果的费用。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 检索效果的过滤函数，用于筛选「影灵衣」族的怪兽。
function c26674724.thfilter(c)
	return c:IsSetCard(0xb4) and not c:IsCode(26674724) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果发动时的处理信息，表示会从卡组检索一张卡。
function c26674724.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否在卡组中存在满足条件的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(c26674724.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将要从卡组检索一张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，选择并把符合条件的卡加入手牌。
function c26674724.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,c26674724.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认送入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 取对象效果的过滤函数，用于筛选从额外卡组特殊召唤的怪兽。
function c26674724.tdfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA) and c:IsAbleToDeck()
end
-- 设置效果发动时的处理信息，表示会将目标怪兽送回卡组。
function c26674724.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c26674724.tdfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c26674724.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送回卡组的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择场上满足条件的怪兽作为对象。
	local g=Duel.SelectTarget(tp,c26674724.tdfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,2,nil)
	-- 设置连锁处理信息，表示将要将怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果发动时的处理函数，将选中的怪兽送回卡组。
function c26674724.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中被选定的目标卡片，并筛选出与当前效果相关的卡片。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 将符合条件的怪兽送回卡组并洗牌。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
