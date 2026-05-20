--現世離レ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1张卡和对方墓地1张卡为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的卡在对方场上盖放。
function c63086455.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1张卡和对方墓地1张卡为对象才能发动。作为对象的场上的卡送去墓地，作为对象的墓地的卡在对方场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,63086455+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c63086455.target)
	e1:SetOperation(c63086455.activate)
	c:RegisterEffect(e1)
end
-- 过滤对方场上可以送去墓地、且对方墓地存在可盖放卡片的卡片。
function c63086455.tgfilter(c,e,tp)
	-- 判定卡片是否能送去墓地，且对方墓地是否存在满足盖放条件的卡。
	return c:IsAbleToGrave() and Duel.IsExistingTarget(c63086455.setfilter,tp,0,LOCATION_GRAVE,1,nil,c,e,tp)
end
-- 过滤对方墓地中，在作为对象的场上卡片离开后，可以盖放到对方场上的怪兽卡或魔陷卡。
function c63086455.setfilter(c,cc,e,tp)
	-- 检查在作为对象的场上卡片离开后，对方场上是否有可用于特殊召唤的怪兽区域。
	local b1=Duel.GetMZoneCount(1-tp,cc,tp)>0
	-- 检查在作为对象的场上卡片离开后，对方场上是否有可用于盖放魔法·陷阱的魔法与陷阱区域。
	local b2=Duel.GetSZoneCount(1-tp,cc,tp)>0
	return b1 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp)
		or (b2 or c:IsType(TYPE_FIELD)) and c:IsSSetable(true)
end
-- 效果发动的准备阶段，进行发动条件检查、选择对方场上和墓地的卡片作为对象，并设置操作信息。
function c63086455.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查对方场上是否存在满足条件的卡片作为第一对象。
	if chk==0 then return Duel.IsExistingTarget(c63086455.tgfilter,tp,0,LOCATION_ONFIELD,1,nil,e,tp) end
	-- 提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择对方场上1张卡作为送去墓地的对象。
	local g1=Duel.SelectTarget(tp,c63086455.tgfilter,tp,0,LOCATION_ONFIELD,1,1,nil,e,tp)
	-- 提示玩家选择要盖放的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 玩家选择对方墓地1张卡作为盖放的对象。
	local g2=Duel.SelectTarget(tp,c63086455.setfilter,tp,0,LOCATION_GRAVE,1,1,nil,g1:GetFirst(),e,tp)
	-- 设置送去墓地的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g1,1,0,0)
	if g2:GetFirst():IsType(TYPE_MONSTER) then
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
		-- 若盖放对象为怪兽，设置特殊召唤的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
	else
		e:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SSET)
		-- 若盖放对象为魔陷，设置卡片离开墓地的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g2,1,0,0)
	end
end
-- 效果处理阶段，将作为对象的场上卡片送去墓地，若成功送墓，则将作为对象的墓地卡片在对方场上盖放。
function c63086455.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡片。
	local tg=Duel.GetTargetsRelateToChain()
	local tc1=tg:Filter(Card.IsLocation,nil,LOCATION_ONFIELD):GetFirst()
	local tc2=tg:Filter(Card.IsLocation,nil,LOCATION_GRAVE):GetFirst()
	-- 检查场上的对象卡片是否存在，将其送去墓地，并确认其成功送去墓地且墓地的对象卡片依然存在。
	if tc1 and Duel.SendtoGrave(tc1,REASON_EFFECT)~=0 and tc1:IsLocation(LOCATION_GRAVE) and tc2 then
		if tc2:IsType(TYPE_MONSTER) then
			-- 将作为对象的墓地怪兽卡在对方场上里侧守备表示特殊召唤（盖放）。
			Duel.SpecialSummon(tc2,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)
		else
			-- 将作为对象的墓地魔法·陷阱卡在对方场上盖放。
			Duel.SSet(tp,tc2,1-tp)
		end
	end
end
