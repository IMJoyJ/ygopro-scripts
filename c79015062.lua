--繋がり－Ai－
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把手卡1只电子界族怪兽给对方观看才能发动。给人观看的怪兽属性的以下效果适用。这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ●暗：给人观看的怪兽特殊召唤，从卡组把1只暗属性以外而4星以下的电子界族怪兽加入手卡。
-- ●暗以外：给人观看的怪兽回到卡组，和回去的怪兽属性不同的1只「@火灵天星」怪兽从卡组加入手卡。
local s,id,o=GetID()
-- 定义并注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：把手卡1只电子界族怪兽给对方观看才能发动。给人观看的怪兽属性的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TODECK|CATEGORY_SEARCH|CATEGORY_SPECIAL_SUMMON|CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 效果发动的Cost处理，设置Label为1以标记该效果在发动时需要进行手牌展示
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(1)
	if chk==0 then return true end
end
-- 过滤条件：可加入手牌、非暗属性、4星以下的电子界族怪兽
function s.thdfilter(c)
	return c:IsAbleToHand() and not c:IsAttribute(ATTRIBUTE_DARK)
		and c:IsLevelBelow(4) and c:IsRace(RACE_CYBERS)
end
-- 过滤条件：可加入手牌、与指定属性不同且属于「@火灵天星」字段的怪兽
function s.thndfilter(c,att)
	return c:IsAbleToHand() and not c:IsAttribute(att) and c:IsSetCard(0x135)
end
-- 过滤手牌中可展示的电子界族怪兽：若是暗属性，则须能特殊召唤且卡组有符合条件的非暗属性4星以下电子界族怪兽；若是非暗属性，则须能回到卡组且卡组有符合条件的不同属性「@火灵天星」怪兽
function s.cfilter(c,e,tp)
	return c:IsRace(RACE_CYBERSE) and not c:IsPublic()
		and (c:IsAttribute(ATTRIBUTE_DARK)
		-- 检查该怪兽是否可以特殊召唤，且自己场上有可用的怪兽区域
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少1只满足条件的非暗属性4星以下电子界族怪兽
		and Duel.IsExistingMatchingCard(s.thdfilter,tp,LOCATION_DECK,0,1,nil)
		or not c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToDeck()
		-- 检查卡组中是否存在至少1只与展示怪兽属性不同的「@火灵天星」怪兽
		and Duel.IsExistingMatchingCard(s.thndfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute()))
end
-- 效果发动的Target处理，让玩家选择并展示手牌中的1只电子界族怪兽，根据其属性设置对应的操作信息和效果分类，并将其设为效果处理的目标
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()==0 then return false end
		e:SetLabel(0)
		-- 检查手牌中是否存在满足展示条件的电子界族怪兽
		return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家从手牌选择1只满足条件的电子界族怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 将选择的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切玩家的手牌
	Duel.ShuffleHand(tp)
	local gc=g:GetFirst()
	if gc:IsAttribute(ATTRIBUTE_DARK) then
		-- 设置特殊召唤的操作信息，包含要特殊召唤的怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,gc,1,0,0)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_SEARCH|CATEGORY_TOHAND)
	else
		-- 设置送回卡组的操作信息，包含要送回卡组的怪兽
		Duel.SetOperationInfo(0,CATEGORY_TODECK,gc,1,0,0)
		e:SetCategory(CATEGORY_TODECK|CATEGORY_SEARCH|CATEGORY_TOHAND)
	end
	-- 将展示的怪兽设置为当前连锁的目标卡片
	Duel.SetTargetCard(g)
end
-- 效果运行的处理，根据展示怪兽的属性执行对应的效果（暗属性则特召并检索，非暗属性则回卡组并检索），并在发动后注册“只能特殊召唤电子界族怪兽”的限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时作为目标展示的怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		if tc:IsAttribute(ATTRIBUTE_DARK) then
			-- 尝试将目标怪兽以表侧表示特殊召唤到自己场上，并检查是否特殊召唤成功
			if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0
				-- 检查卡组中是否存在可检索的非暗属性4星以下电子界族怪兽
				and Duel.IsExistingMatchingCard(s.thdfilter,tp,LOCATION_DECK,0,1,nil) then
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 让玩家从卡组选择1只满足条件的非暗属性4星以下电子界族怪兽
				local g=Duel.SelectMatchingCard(tp,s.thdfilter,tp,LOCATION_DECK,0,1,1,nil)
				if g:GetCount()>0 then
					-- 将选择的怪兽加入玩家手牌
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					-- 将加入手牌的卡给对方确认
					Duel.ConfirmCards(1-tp,g)
				end
			end
		else
			local att=tc:GetAttribute()
			-- 将目标怪兽送回卡组并洗牌，并检查其是否成功回到卡组
			if Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_DECK)
				-- 检查卡组中是否存在可检索的与该怪兽属性不同的「@火灵天星」怪兽
				and Duel.IsExistingMatchingCard(s.thndfilter,tp,LOCATION_DECK,0,1,nil,att) then
				-- 提示玩家选择要加入手牌的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
				-- 让玩家从卡组选择1只与展示怪兽属性不同的「@火灵天星」怪兽
				local g=Duel.SelectMatchingCard(tp,s.thndfilter,tp,LOCATION_DECK,0,1,1,nil,att)
				if g:GetCount()>0 then
					-- 将选择的「@火灵天星」怪兽加入玩家手牌
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					-- 将加入手牌的卡给对方确认
					Duel.ConfirmCards(1-tp,g)
				end
			end
		end
	end
	-- 这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.splimit)
	-- 向玩家注册该特殊召唤限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制非电子界族怪兽的特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
