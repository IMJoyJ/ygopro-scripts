--廻る罪宝
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：从卡组选1只5星以上的幻想魔族怪兽加入手卡或特殊召唤。这个回合的主要阶段内，自己不能把这个效果特殊召唤的怪兽的效果发动。
-- ②：把墓地的这张卡除外，以自己场上1张里侧表示卡为对象才能发动。那张卡回到手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。
local s,id,o=GetID()
-- 注册两个效果：①检索或特殊召唤一只5星以上幻想魔族怪兽；②将墓地的这张卡除外，将自己场上1张里侧表示卡回到手卡，然后可从手卡盖放1张魔法·陷阱卡。
function s.initial_effect(c)
	-- ①：从卡组选1只5星以上的幻想魔族怪兽加入手卡或特殊召唤。这个回合的主要阶段内，自己不能把这个效果特殊召唤的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1张里侧表示卡为对象才能发动。那张卡回到手卡。那之后，可以从手卡把1张魔法·陷阱卡盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id)
	-- 将墓地的这张卡除外作为效果的发动费用。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.thtg2)
	e2:SetOperation(s.thop2)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于筛选满足条件的5星以上幻想魔族怪兽，可以加入手卡或特殊召唤。
function s.sfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION) and c:IsLevelAbove(5) and (c:IsAbleToHand()
		-- 判断是否可以特殊召唤该怪兽。
		or (Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
-- 效果处理时检查是否满足条件，即卡组中是否存在符合条件的怪兽。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.sfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
end
-- 处理效果①：选择从卡组检索或特殊召唤一只符合条件的怪兽，并根据选择执行相应操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一只符合条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,s.sfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		local th=tc:IsAbleToHand()
		-- 判断该怪兽是否可以特殊召唤。
		local sp=Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and tc:IsCanBeSpecialSummoned(e,0,tp,false,false)
		local op=0
		-- 如果该怪兽既可以加入手卡也可以特殊召唤，则让玩家选择操作方式。
		if th and sp then op=Duel.SelectOption(tp,1190,1152)
		elseif th then op=0
		else op=1 end
		if op==0 then
			-- 将该怪兽加入手卡。
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方确认该怪兽加入手卡。
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 尝试特殊召唤该怪兽。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
				-- 为特殊召唤的怪兽设置效果，使其在主要阶段内不能发动效果。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_TRIGGER)
				e1:SetCondition(s.condition)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			-- 完成特殊召唤流程。
			Duel.SpecialSummonComplete()
		end
	end
end
-- 判断当前阶段是否为主要阶段。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数，用于筛选自己场上的里侧表示卡。
function s.thfilter(c)
	return c:IsFacedown() and c:IsAbleToHand()
end
-- 设置效果②的目标选择逻辑。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_ONFIELD) and s.thfilter(chkc) end
	-- 检查自己场上是否存在符合条件的里侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 提示玩家选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己场上的1张里侧表示卡作为目标。
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	-- 设置效果②的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 处理效果②：将目标卡回到手卡，然后可从手卡盖放1张魔法·陷阱卡。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡。
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效，并将其送回手卡。
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_HAND) then
		-- 获取玩家手卡中可盖放的魔法·陷阱卡。
		local g=Duel.GetMatchingGroup(Card.IsSSetable,tp,LOCATION_HAND,0,nil)
		-- 询问玩家是否要盖放魔法·陷阱卡。
		if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否盖放？"
			-- 手动洗切玩家的手卡。
			Duel.ShuffleHand(tp)
			-- 中断当前效果处理。
			Duel.BreakEffect()
			-- 提示玩家选择要盖放的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
			local sg=g:Select(tp,1,1,nil)
			-- 将选中的卡盖放。
			Duel.SSet(tp,sg,tp,false)
		end
	end
end
