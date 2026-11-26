--超量要請アルファンコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
function c15721392.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。 ①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DECKDES+CATEGORY_DECK_SPSUMMON+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,15721392+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c15721392.condition)
	e1:SetTarget(c15721392.target)
	e1:SetOperation(c15721392.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，检查是否为之前由自己控制的「超级量子」怪兽
function c15721392.cfilter(c,tp)
	return c:IsSetCard(0xdc) and c:IsPreviousControler(tp)
end
-- 发动条件检查，确认被战斗破坏的怪兽中包含自己控制的「超级量子」怪兽
function c15721392.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721392.cfilter,1,nil,tp)
end
-- 过滤函数，检查是否为可从额外卡组特殊召唤且场上存在对应可用空位的「超级量子机兽」怪兽
function c15721392.spfilter(c,e,tp)
	-- 判断该卡是否为「超级量子机兽」怪兽、能否特殊召唤且额外卡组出场的怪兽区有可用空位
	return c:IsSetCard(0x20dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 检查额外卡组是否存在可特殊召唤的「超级量子机兽」怪兽并设置特殊召唤操作信息
function c15721392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己额外卡组是否存在至少1只满足条件的「超级量子机兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c15721392.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置从自己额外卡组特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 过滤函数，检查是否为在指定超量怪兽上有卡名记述且可特殊召唤的「超级量子战士」怪兽
function c15721392.spfilter2(c,e,tp,mc)
	-- 判断该卡是否为「超级量子战士」怪兽、能否特殊召唤且其卡名记述在超量怪兽文本中
	return c:IsSetCard(0x10dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果处理，从额外卡组特殊召唤1只「超级量子机兽」怪兽，之后可从手卡·卡组·墓地效果无效特殊召唤其记述的1只「超级量子战士」怪兽
function c15721392.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己额外卡组中所有可特殊召唤的「超级量子机兽」怪兽
	local g=Duel.GetMatchingGroup(c15721392.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示控制者选择要从额外卡组特殊召唤的「超级量子机兽」怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的「超级量子机兽」超量怪兽表侧表示特殊召唤并判断是否成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取手卡·卡组·墓地中（受王家长眠之谷过滤）记述在刚特殊召唤的超量怪兽上的「超级量子战士」怪兽
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c15721392.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc)
		-- 若没有可特殊召唤的怪兽或玩家选择不特殊召唤，则结束处理
		if #g2<=0 or not Duel.SelectYesNo(tp,aux.Stringid(15721392,0)) then return end  --"是否特殊召唤记述的怪兽？"
		-- 中断当前效果处理，使后续「超级量子战士」怪兽的特殊召唤视为不同时处理
		Duel.BreakEffect()
		-- 提示控制者选择要特殊召唤的「超级量子战士」怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		-- 以分步方式开始将选中的「超级量子战士」怪兽表侧表示特殊召唤
		if tc2 and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			-- 效果无效特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
		-- 完成分步特殊召唤处理并正式将其视作特殊召唤成功
		Duel.SpecialSummonComplete()
	end
end
