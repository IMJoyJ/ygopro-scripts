--超量要請アルファンコール
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
function c15721392.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的「超级量子」怪兽被战斗破坏时才能发动。从额外卡组把1只「超级量子机兽」超量怪兽特殊召唤。那之后，可以从自己的手卡·卡组·墓地选在那张超量怪兽卡有卡名记述的1只「超级量子战士」怪兽效果无效特殊召唤。
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
-- 筛选被战斗破坏的怪兽中，属于「超级量子」字段且上一控制者为自己的怪兽，用于判定是否满足发动条件。
function c15721392.cfilter(c,tp)
	return c:IsSetCard(0xdc) and c:IsPreviousControler(tp)
end
-- 检查战斗破坏送入墓地的怪兽组中是否存在至少1只满足cfilter的怪兽，即“自己的「超级量子」怪兽被战斗破坏时”的触发条件。
function c15721392.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c15721392.cfilter,1,nil,tp)
end
-- 定义额外卡组中可特殊召唤的「超级量子机兽」超量怪兽的筛选条件，包括字段、特殊召唤合法性以及额外卡组怪兽区域是否可用。
function c15721392.spfilter(c,e,tp)
	-- 返回该怪兽是否为「超级量子机兽」字段、能否被效果特殊召唤，且当前玩家有足够从额外卡组特殊召唤的空位。
	return c:IsSetCard(0x20dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标判定与操作信息设置：检查能否从额外卡组特殊召唤1只「超级量子机兽」，并设置特殊召唤的操作信息。
function c15721392.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，确认额外卡组中是否存在满足spfilter的「超级量子机兽」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c15721392.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	-- 设置本次效果处理时将进行特殊召唤的操作信息：从额外卡组特殊召唤1只怪兽，归属玩家为tp。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义从手卡·卡组·墓地选择「超级量子战士」怪兽的筛选条件，要求其为「超级量子战士」字段、可被特殊召唤，且卡名被所超量怪兽卡记载。
function c15721392.spfilter2(c,e,tp,mc)
	-- 返回该怪兽是否为「超级量子战士」字段、能否被效果特殊召唤，并且其卡名是否被所超量怪兽卡（mc）的卡名记述。
	return c:IsSetCard(0x10dc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and aux.IsCodeListed(mc,c:GetCode())
end
-- 效果处理函数：先从额外卡组选择1只「超级量子机兽」特殊召唤，成功后询问是否从手卡·卡组·墓地选1只记述的「超级量子战士」效果无效特殊召唤。
function c15721392.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取额外卡组中所有满足spfilter的「超级量子机兽」怪兽的集合。
	local g=Duel.GetMatchingGroup(c15721392.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的「超级量子机兽」以表侧攻击表示特殊召唤；若特殊召唤成功则继续后续处理。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 获取手卡·卡组·墓地中满足spfilter2且不受王家长眠之谷影响的「超级量子战士」怪兽集合。
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(c15721392.spfilter2),tp,LOCATION_HAND+LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,tc)
		-- 若没有符合条件的可特殊召唤怪兽，或玩家选择“否”，则直接结束效果处理。
		if #g2<=0 or not Duel.SelectYesNo(tp,aux.Stringid(15721392,0)) then return end  --"是否特殊召唤记述的怪兽？"
		-- 中断当前效果处理，使后续特殊召唤视为不同时处理，避免引起错误时点。
		Duel.BreakEffect()
		-- 向玩家显示“请选择要特殊召唤的卡”的选择提示，用于选择「超级量子战士」。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc2=g2:Select(tp,1,1,nil):GetFirst()
		-- 将选中的「超级量子战士」通过特殊召唤步骤进行处理；若成功则为后续附加效果无效状态做准备。
		if tc2 and Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP) then
			-- 效果无效特殊召唤中的“效果无效”——使该怪兽的场上效果无效化（EFFECT_DISABLE）。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e1)
			-- 效果无效特殊召唤中的“效果无效”——使该怪兽已发动的效果处理无效化（EFFECT_DISABLE_EFFECT）。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
		end
		-- 完成整个特殊召唤过程，正式处理所有通过特殊召唤步骤召唤的怪兽。
		Duel.SpecialSummonComplete()
	end
end
