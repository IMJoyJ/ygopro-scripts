--リゾネーター・エンジン
-- 效果：
-- ①：以自己墓地2只「共鸣者」怪兽为对象才能发动。从卡组把1只4星怪兽加入手卡，作为对象的怪兽回到卡组。
function c15576074.initial_effect(c)
	-- 效果原文内容：①：以自己墓地2只「共鸣者」怪兽为对象才能发动。从卡组把1只4星怪兽加入手卡，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c15576074.target)
	e1:SetOperation(c15576074.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选自己墓地中的「共鸣者」怪兽，满足条件的怪兽可以被送回卡组。
function c15576074.filter(c)
	return c:IsSetCard(0x57) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- 过滤函数，用于筛选卡组中4星的怪兽，满足条件的怪兽可以被加入手牌。
function c15576074.filter2(c)
	return c:IsLevel(4) and c:IsAbleToHand()
end
-- 效果处理时的条件判断，检查是否满足发动条件，即卡组中存在4星怪兽且自己墓地存在2只「共鸣者」怪兽。
function c15576074.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c15576074.filter(chkc) end
	-- 检查卡组中是否存在至少1只4星怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15576074.filter2,tp,LOCATION_DECK,0,1,nil)
		-- 检查自己墓地中是否存在至少2只「共鸣者」怪兽。
		and Duel.IsExistingTarget(c15576074.filter,tp,LOCATION_GRAVE,0,2,nil) end
	-- 向玩家提示选择要返回卡组的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择2只满足条件的「共鸣者」怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c15576074.filter,tp,LOCATION_GRAVE,0,2,2,nil)
	-- 设置效果操作信息，表示将选择的怪兽送回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
	-- 设置效果操作信息，表示从卡组检索1只4星怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行效果的处理流程，包括检索4星怪兽并送回墓地中的怪兽。
function c15576074.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1只4星怪兽加入手牌。
	local g=Duel.SelectMatchingCard(tp,c15576074.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的4星怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 获取当前连锁中被选择作为对象的卡组，并筛选出与当前效果相关的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()~=0 then
		-- 将筛选出的卡送回卡组顶端。
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end
