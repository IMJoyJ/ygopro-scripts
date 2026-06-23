--モンスターアソート
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：从卡组选种族·属性·等级是相同的1只通常怪兽和1只效果怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余回到卡组。
function c23270035.initial_effect(c)
	-- ①：从卡组选种族·属性·等级是相同的1只通常怪兽和1只效果怪兽给对方观看，对方从那之中随机选1只。那1只怪兽加入自己手卡，剩余回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,23270035+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c23270035.target)
	e1:SetOperation(c23270035.activate)
	c:RegisterEffect(e1)
end
-- 筛选函数：检查g中是否存在满足filter2条件的怪兽，并且当前怪兽为通常怪兽
function c23270035.filter(c,g)
	return g:IsExists(c23270035.filter2,1,c,c) and c:IsType(TYPE_NORMAL)
end
-- 筛选函数：检查当前怪兽是否与cc怪兽种族、属性、等级相同，并且为效果怪兽
function c23270035.filter2(c,cc)
	return c:IsRace(cc:GetRace()) and c:IsAttribute(cc:GetAttribute()) and c:IsLevel(cc:GetLevel()) and c:IsType(TYPE_EFFECT)
end
-- 筛选函数：检查g中是否存在至少1个满足filter条件的怪兽
function c23270035.fselect(g)
	return g:IsExists(c23270035.filter,1,nil,g)
end
-- 筛选函数：检查当前卡是否为怪兽且可以加入手牌
function c23270035.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动时的处理函数，检查是否满足条件并设置操作信息
function c23270035.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足thfilter条件的卡组中的卡
	local g=Duel.GetMatchingGroup(c23270035.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(c23270035.fselect,2,2) end
	-- 设置操作信息，表示效果处理时会将1张卡从卡组加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理函数，执行实际效果处理
function c23270035.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足thfilter条件的卡组中的卡
	local g=Duel.GetMatchingGroup(c23270035.thfilter,tp,LOCATION_DECK,0,nil)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	local sg=g:SelectSubGroup(tp,c23270035.fselect,false,2,2)
	if sg and #sg==2 then
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,sg)
		local tg=sg:RandomSelect(1-tp,1)
		-- 将卡组洗切
		Duel.ShuffleDeck(tp)
		tg:GetFirst():SetStatus(STATUS_TO_HAND_WITHOUT_CONFIRM,true)
		-- 将选中的卡加入手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
