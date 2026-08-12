--悦楽の堕天使
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组选除「悦乐之堕天使」外的2只等级不同的「堕天使」怪兽，那之内的1只在对方场上守备表示特殊召唤，另1只加入自己手卡。这个效果的发动后，直到回合结束时自己不能把天使族以外的怪兽的效果发动。
function c82773292.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从手卡·卡组选除「悦乐之堕天使」外的2只等级不同的「堕天使」怪兽，那之内的1只在对方场上守备表示特殊召唤，另1只加入自己手卡。这个效果的发动后，直到回合结束时自己不能把天使族以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82773292,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,82773292)
	e1:SetTarget(c82773292.sptg)
	e1:SetOperation(c82773292.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤手卡·卡组中除「悦乐之堕天使」以外的等级1以上的「堕天使」怪兽
function c82773292.filter(c)
	return c:IsSetCard(0xef) and not c:IsCode(82773292) and c:IsType(TYPE_MONSTER) and c:IsLevelAbove(1)
end
-- 检查选出的卡片组合是否等级不同，且其中至少有1张卡满足特殊召唤到对方场上、另1张加入手卡的条件
function c82773292.fselect(g,e,tp)
	-- 判定选出的卡片等级是否互不相同，且其中至少存在1张卡满足特殊召唤到对方场上、另1张加入手卡的条件
	return aux.dlvcheck(g) and g:IsExists(c82773292.fcheck,1,nil,g,e,tp)
end
-- 检查卡片是否能从手卡或卡组在对方场上守备表示特殊召唤，且卡组中存在另一张可以加入手卡的卡
function c82773292.fcheck(c,g,e,tp)
	return c:IsLocation(LOCATION_HAND+LOCATION_DECK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		and g:IsExists(c82773292.fcheck2,1,c)
end
-- 检查卡片是否在卡组中且可以加入手卡
function c82773292.fcheck2(c)
	return c:IsLocation(LOCATION_DECK) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与可行性检查
function c82773292.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己手卡·卡组中所有满足过滤条件的「堕天使」怪兽
	local g=Duel.GetMatchingGroup(c82773292.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
	-- 检查对方场上是否有可用的怪兽区域空格，并检查手卡·卡组中是否存在满足条件的卡片组合
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0
		and g:CheckSubGroup(c82773292.fselect,2,2,e,tp) end
	-- 设置特殊召唤的操作信息（从手卡·卡组特殊召唤1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	-- 设置加入手卡的操作信息（从卡组将1张卡加入手卡）
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤出只能被特殊召唤（在手卡，或者在卡组但不能加入手卡）的卡片
function c82773292.cfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		and (c:IsLocation(LOCATION_HAND) or not c:IsAbleToHand())
end
-- 过滤出只能加入手卡（不能被特殊召唤，且在卡组中）的卡片
function c82773292.cfilter2(c,e,tp)
	return not c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
		and c:IsLocation(LOCATION_DECK) and c:IsAbleToHand()
end
-- 效果处理的核心逻辑：从手卡·卡组选择2只等级不同的「堕天使」怪兽，将其中1只在对方场上守备表示特殊召唤，另1只加入自己手卡，并适用后续的不能发动天使族以外怪兽效果的限制
function c82773292.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp)>0 then
		-- 获取自己手卡·卡组中所有满足过滤条件的「堕天使」怪兽
		local g=Duel.GetMatchingGroup(c82773292.filter,tp,LOCATION_HAND+LOCATION_DECK,0,nil)
		local sc=nil
		local hc=nil
		-- 提示玩家选择要操作的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
		local sg=g:SelectSubGroup(tp,c82773292.fselect,false,2,2,e,tp)
		if sg and sg:GetCount()==2 then
			if sg:IsExists(c82773292.cfilter,1,nil,e,tp) then
				sc=sg:Filter(c82773292.cfilter,nil,e,tp):GetFirst()
				hc=sg:GetFirst()
				if hc==sc then hc=sg:GetNext() end
			elseif sg:IsExists(c82773292.cfilter2,1,nil,e,tp) then
				hc=sg:Filter(c82773292.cfilter2,nil,e,tp):GetFirst()
				sc=sg:GetFirst()
				if sc==hc then sc=sg:GetNext() end
			else
				-- 提示玩家选择要特殊召唤的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
				sc=sg:FilterSelect(tp,c82773292.fcheck,1,1,nil,sg,e,tp):GetFirst()
				hc=sg:GetFirst()
				if hc==sc then hc=sg:GetNext() end
			end
			-- 将选定的其中1只怪兽在对方场上表侧守备表示特殊召唤，若特殊召唤成功则继续处理另1只
			if sc and Duel.SpecialSummon(sc,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)~=0 and hc then
				-- 将另1只怪兽加入自己手卡
				Duel.SendtoHand(hc,nil,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的卡片
				Duel.ConfirmCards(1-tp,hc)
			end
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不能把天使族以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c82773292.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能发动天使族以外怪兽效果的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动的条件：发动的效果是怪兽效果，且该怪兽不是天使族
function c82773292.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and not re:GetHandler():IsRace(RACE_FAIRY)
end
