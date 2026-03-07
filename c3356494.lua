--銀河眼の煌星竜
-- 效果：
-- 包含攻击力2000以上的怪兽的光属性怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡连接召唤成功的场合，以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能发动。那只怪兽加入手卡。
-- ②：对方主要阶段，把「光子」卡和「银河」卡共2张或者「银河眼光子龙」1只从手卡丢弃，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。
function c3356494.initial_effect(c)
	-- 添加连接召唤手续，要求使用至少2张且至多2张满足光属性条件的怪兽作为连接素材，并且这些怪兽中至少有一只攻击力不低于2000的怪兽
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkAttribute,ATTRIBUTE_LIGHT),2,2,c3356494.lcheck)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合，以自己墓地1只「光子」怪兽或者「银河」怪兽为对象才能发动。那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3356494,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,3356494)
	e1:SetCondition(c3356494.thcon)
	e1:SetTarget(c3356494.thtg)
	e1:SetOperation(c3356494.thop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段，把「光子」卡和「银河」卡共2张或者「银河眼光子龙」1只从手卡丢弃，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3356494,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,3356495)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCondition(c3356494.descon)
	e2:SetCost(c3356494.descost)
	e2:SetTarget(c3356494.destg)
	e2:SetOperation(c3356494.desop)
	c:RegisterEffect(e2)
end
-- 连接素材中必须包含至少一只攻击力不低于2000的怪兽
function c3356494.lcheck(g,lc)
	return g:IsExists(Card.IsAttackAbove,1,nil,2000)
end
-- 效果发动时，确认此卡是否为连接召唤成功
function c3356494.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤满足「光子」或「银河」卡组条件的怪兽，并且是怪兽类型且可以加入手牌
function c3356494.thfilter(c)
	return c:IsSetCard(0x55,0x7b) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果目标为满足条件的墓地怪兽，选择1张加入手牌
function c3356494.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c3356494.thfilter(chkc) end
	-- 检查是否存在满足条件的墓地目标怪兽
	if chk==0 then return Duel.IsExistingTarget(c3356494.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的墓地怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c3356494.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，表示将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 执行效果操作，将目标怪兽加入手牌
function c3356494.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 设置效果发动条件，确认当前为对方主要阶段
function c3356494.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 确认当前回合玩家不是效果使用者，且当前阶段为主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤满足「银河眼光子龙」卡号且可丢弃的卡
function c3356494.cfilter1(c)
	return c:IsCode(93717133) and c:IsDiscardable()
end
-- 过滤满足「光子」卡组且可丢弃的卡，并且对方手牌中存在满足「银河」卡组条件的卡
function c3356494.cfilter2(c,tp)
	return c:IsSetCard(0x55) and c:IsDiscardable()
		-- 检查对方手牌中是否存在满足「银河」卡组条件的卡
		and Duel.IsExistingMatchingCard(c3356494.cfilter3,tp,LOCATION_HAND,0,1,c)
end
-- 过滤满足「银河」卡组且可丢弃的卡
function c3356494.cfilter3(c)
	return c:IsSetCard(0x7b) and c:IsDiscardable()
end
-- 设置效果发动费用，可以选择丢弃「银河眼光子龙」或丢弃「光子」和「银河」各一张
function c3356494.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在「银河眼光子龙」且可丢弃
	local b1=Duel.IsExistingMatchingCard(c3356494.cfilter1,tp,LOCATION_HAND,0,1,nil)
	-- 检查对方手牌中是否存在满足「光子」卡组且可丢弃的卡，并且存在满足「银河」卡组的卡
	local b2=Duel.IsExistingMatchingCard(c3356494.cfilter2,tp,LOCATION_HAND,0,1,nil,tp)
	if chk==0 then return b1 or b2 end
	-- 如果存在「银河眼光子龙」且对方未选择丢弃其他组合，则选择丢弃「银河眼光子龙」
	if b1 and (not b2 or Duel.SelectYesNo(tp,aux.Stringid(3356494,2))) then  --"是否丢弃「银河眼光子龙」？"
		-- 丢弃一张「银河眼光子龙」作为效果发动费用
		Duel.DiscardHand(tp,c3356494.cfilter1,1,1,REASON_COST+REASON_DISCARD,nil)
	else
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择满足「光子」卡组且可丢弃的手牌
		local g1=Duel.SelectMatchingCard(tp,c3356494.cfilter2,tp,LOCATION_HAND,0,1,1,nil,tp)
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择满足「银河」卡组且可丢弃的手牌
		local g2=Duel.SelectMatchingCard(tp,c3356494.cfilter3,tp,LOCATION_HAND,0,1,1,g1)
		g1:Merge(g2)
		-- 将选择的卡丢入墓地作为效果发动费用
		Duel.SendtoGrave(g1,REASON_COST+REASON_DISCARD)
	end
end
-- 设置效果目标为对方场上的特殊召唤怪兽，选择1只破坏
function c3356494.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsSummonType(SUMMON_TYPE_SPECIAL) end
	-- 检查是否存在满足条件的对方场上的特殊召唤怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsSummonType,tp,0,LOCATION_MZONE,1,nil,SUMMON_TYPE_SPECIAL) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的对方场上的特殊召唤怪兽作为效果目标
	local g=Duel.SelectTarget(tp,Card.IsSummonType,tp,0,LOCATION_MZONE,1,1,nil,SUMMON_TYPE_SPECIAL)
	-- 设置效果操作信息，表示将目标怪兽破坏
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行效果操作，破坏目标怪兽
function c3356494.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
