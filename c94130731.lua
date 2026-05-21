--超越竜グレイスザウルス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：这张卡不会被战斗破坏。
-- ②：只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的恐龙族怪兽不会成为对方的效果的对象，不会被对方的效果破坏。
-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
function c94130731.initial_effect(c)
	-- 添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，从墓地特殊召唤的自己场上的恐龙族怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c94130731.indestg)
	-- 设置不会被对方的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	-- 设置不会成为对方的效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
	-- ③：这张卡被破坏的场合才能发动。从自己墓地选1只通常怪兽回到卡组。那之后，可以把这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(94130731,0))
	e4:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,94130731)
	e4:SetTarget(c94130731.tdtg)
	e4:SetOperation(c94130731.tdop)
	c:RegisterEffect(e4)
end
-- 过滤自身场上表侧表示且从墓地特殊召唤的恐龙族怪兽
function c94130731.indestg(e,c)
	return c:IsRace(RACE_DINOSAUR) and c:IsFaceup() and c:IsSummonLocation(LOCATION_GRAVE)
end
-- 过滤墓地中可以回到卡组的通常怪兽
function c94130731.tdfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToDeck()
end
-- 效果③的发动准备与效果分类设置
function c94130731.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己墓地是否存在可以回到卡组的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c94130731.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息：将自己墓地的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_GRAVE)
	if e:GetActivateLocation()==LOCATION_GRAVE then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	else
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SPECIAL_SUMMON)
	end
end
-- 效果③的处理：将墓地的通常怪兽送回卡组，并可以特殊召唤这张卡
function c94130731.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要返回卡组的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己墓地选择1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,c94130731.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		local c=e:GetHandler()
		-- 若成功将选择的怪兽送回卡组并洗牌
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0
			and g:FilterCount(Card.IsLocation,nil,LOCATION_DECK)>0
			-- 且这张卡仍存在于原本区域、自己场上有空余的怪兽区域
			and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 且玩家选择进行特殊召唤
			and Duel.SelectYesNo(tp,aux.Stringid(94130731,1)) then  --"是否把这张卡特殊召唤？"
			-- 中断当前效果处理，使后续的特殊召唤处理视为不同时处理
			Duel.BreakEffect()
			-- 将这张卡表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
