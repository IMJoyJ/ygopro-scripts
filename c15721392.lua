--超量要請アルファンコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
function c15721392.initial_effect(c)
	-- 效果发动条件：自己的「超级量子」怪兽被战斗破坏时才能发动。
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
-- 过滤条件：判断是否为「超级量子」怪兽且之前在自己的控制下。
function c15721392.cfilter(c,tp)
	return c:IsSetCard(0xdc) and c:IsPreviousControler(tp)
end
-- 效果发动条件：确认是否有满足过滤条件的怪兽被战斗破坏。
function c15721392.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721392.cfilter,1,nil,tp)
end
-- 过滤条件：额外卡组中是否存在「超级量子机兽」超量怪兽且能特殊召唤。
function c15721392.spfilter(c,e,tp)
	-- 满足条件：为「超级量子机兽」超量怪兽且能特殊召唤且场上存在召唤空间。
	return c:IsSetCard(0x20dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果处理目标：确认额外卡组中是否存在满足条件的怪兽。
function c15721392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：额外卡组中是否存在至少1只「超级量子机兽」超量怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15721392.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤1只额外卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤条件：手卡·卡组·墓地中是否存在「超级量子战士」怪兽且其卡名被记述。
function c15721392.spfilter2(c,e,tp,mc)
	-- 满足条件：为「超级量子战士」怪兽且能特殊召唤且其卡名被记述。
	return c:IsSetCard(0x10dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果处理流程：从额外卡组特殊召唤1只「超级量子机兽」超量怪兽。
function c15721392.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取满足条件的额外卡组怪兽组。
	local g=Duel.GetMatchingGroup(c15721392.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 执行特殊召唤操作：将选中的怪兽特殊召唤到场上。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取满足条件的手卡·卡组·墓地怪兽组。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c15721392.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc)
		-- 判断是否选择特殊召唤记述的怪兽。
		if #g2<=0 or not Duel.SelectYesNo(tp,aux.Stringid(15721392,0)) then return end  --"是否特殊召唤记述的怪兽？"
		-- 中断当前效果处理，使后续处理视为错时点。
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的记述怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		-- 执行第二步特殊召唤操作：将选中的怪兽特殊召唤到场上。
		if tc2 and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效化：使该怪兽效果无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			-- 效果无效化：使该怪兽效果无效化。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
		-- 完成特殊召唤流程：结束特殊召唤处理。
		Duel.SpecialSummonComplete()
	end
end
