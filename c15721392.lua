--超量要請アルファンコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
function c15721392.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,15721392+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15721392.condition)
	e1:SetTarget(c15721392.target)
	e1:SetOperation(c15721392.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：检查被战斗破坏的怪兽是否为「超级量子」怪兽且为我方控制者。
function c15721392.cfilter(c,tp)
	return c:IsSetCard(0xdc) and c:IsPreviousControler(tp)
end
-- 效果作用：判断是否有我方的「超级量子」怪兽被战斗破坏。
function c15721392.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721392.cfilter,1,nil,tp)
end
-- 效果作用：过滤满足条件的额外卡组中的「超级量子机兽」超量怪兽。
function c15721392.spfilter(c,e,tp)
	-- 效果原文内容：从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。
	return c:IsSetCard(0x20dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果作用：设置连锁处理中要特殊召唤的怪兽数量和位置。
function c15721392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：判断是否满足发动条件，即额外卡组中是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15721392.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 效果原文内容：从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果作用：过滤满足条件的我方手卡·卡组·墓地中的「超级量子战士」怪兽。
function c15721392.spfilter2(c,e,tp,mc)
	-- 效果原文内容：那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
	return c:IsSetCard(0x10dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果作用：主处理函数，执行效果的完整流程。
function c15721392.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果作用：获取满足条件的额外卡组中的「超级量子机兽」超量怪兽。
	local g=Duel.GetMatchingGroup(c15721392.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 效果作用：提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 效果作用：将选中的怪兽特殊召唤到场上。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 效果作用：获取满足条件的我方手卡·卡组·墓地中的「超级量子战士」怪兽。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c15721392.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc)
		-- 效果作用：判断是否选择特殊召唤记述的怪兽。
		if #g2<=0 or not Duel.SelectYesNo(tp,aux.Stringid(15721392,0)) then return end  --"是否特殊召唤记述的怪兽？"
		-- 效果作用：中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 效果作用：提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		-- 效果作用：将选中的怪兽以特殊召唤步骤的形式特殊召唤。
		if tc2 and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果原文内容：效果无效特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			-- 效果原文内容：效果无效特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
		-- 效果作用：完成特殊召唤步骤的处理。
		Duel.SpecialSummonComplete()
	end
end
