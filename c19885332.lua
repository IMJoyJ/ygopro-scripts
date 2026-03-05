--白の水鏡
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只4星以下的鱼族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把原本卡名和这个效果特殊召唤的怪兽相同的1只怪兽从卡组加入手卡。
function c19885332.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,19885332+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c19885332.target)
	e1:SetOperation(c19885332.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：过滤满足条件的怪兽（4星以下鱼族且可特殊召唤）
function c19885332.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_FISH) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果作用：设置效果目标为己方墓地满足条件的怪兽
function c19885332.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c19885332.filter(chkc,e,tp) end
	-- 效果作用：判断己方场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 效果作用：判断己方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c19885332.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 效果作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 效果作用：选择满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c19885332.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 效果作用：设置效果处理信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：过滤满足条件的卡（同名且可加入手牌）
function c19885332.thfilter(c,code)
	return c:IsOriginalCodeRule(code) and c:IsAbleToHand()
end
-- 效果原文内容：①：以自己墓地1只4星以下的鱼族怪兽为对象才能发动。那只怪兽特殊召唤。那之后，可以把原本卡名和这个效果特殊召唤的怪兽相同的1只怪兽从卡组加入手卡。
function c19885332.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 效果作用：确认目标怪兽有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 效果作用：检索满足条件的卡组卡片
		local g=Duel.GetMatchingGroup(c19885332.thfilter,tp,LOCATION_DECK,0,nil,tc:GetOriginalCodeRule())
		-- 效果作用：判断是否选择将同名卡加入手牌
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(19885332,0)) then  --"是否从卡组把同名卡加入手卡？"
			-- 效果作用：中断当前效果处理
			Duel.BreakEffect()
			-- 效果作用：提示玩家选择要加入手牌的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 效果作用：将选中的卡加入手牌
			Duel.SendtoHand(sg,tp,REASON_EFFECT)
			-- 效果作用：确认对方查看加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
