--GMX Researcher Selande
-- 效果：
-- 这张卡召唤的场合：可以从卡组把战士族以外的1只「GMX」怪兽，或者1只3星以下的恐龙族怪兽特殊召唤。
-- 这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1张「GMX」魔法·陷阱卡加入手卡。
-- 场上有恐龙族融合怪兽存在的场合：可以让场上的这张卡回到卡组，把场上1张表侧表示卡的效果直到回合结束时无效。
-- 「GMX研究员 塞兰特」的每个效果1回合各能使用1次。
local s,id,o=GetID()
-- 创建3个效果，分别对应召唤时特殊召唤、特殊召唤成功时检索、场上存在恐龙族融合怪兽时无效效果。
function s.initial_effect(c)
	-- 这张卡召唤的场合：可以从卡组把战士族以外的1只「GMX」怪兽，或者1只3星以下的恐龙族怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 这张卡用怪兽的效果特殊召唤的场合：可以从卡组把1张「GMX」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 场上有恐龙族融合怪兽存在的场合：可以让场上的这张卡回到卡组，把场上1张表侧表示卡的效果直到回合结束时无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"无效效果"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
end
-- 特殊召唤的过滤条件：非战士族的GMX怪兽或3星以下的恐龙族怪兽。
function s.spfilter(c,e,tp)
	return (not c:IsRace(RACE_WARRIOR) and c:IsSetCard(0x1dd)
		or c:IsLevelBelow(3) and c:IsRace(RACE_DINOSAUR))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足特殊召唤的条件：场上存在空位且卡组存在符合条件的怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件：场上存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足特殊召唤的条件：卡组存在符合条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方提示发动了特殊召唤效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：选择符合条件的怪兽并特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足特殊召唤的条件：场上存在空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足检索效果的条件：发动效果的卡是怪兽类型。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 检索的过滤条件：GMX魔法或陷阱卡。
function s.thfilter(c)
	return c:IsSetCard(0x1dd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 判断是否满足检索的条件：卡组存在符合条件的魔法或陷阱卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索的条件：卡组存在符合条件的魔法或陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示发动了检索效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置检索效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作：选择符合条件的魔法或陷阱卡并加入手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择符合条件的魔法或陷阱卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的魔法或陷阱卡加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方手牌。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断场上是否存在恐龙族融合怪兽的过滤条件。
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION) and c:IsRace(RACE_DINOSAUR)
end
-- 判断是否满足无效效果的条件：场上存在恐龙族融合怪兽。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在恐龙族融合怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,1,nil)
end
-- 判断是否满足无效效果的条件：场上存在符合条件的卡且该卡可回到卡组。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足无效效果的条件：场上存在符合条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
		and c:IsAbleToDeck() end
	-- 向对方提示发动了无效效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 获取符合条件的场上卡组。
	local g=Duel.GetMatchingGroup(aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置无效效果的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置将该卡送回卡组的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,c,1,0,0)
end
-- 执行无效效果操作：将该卡送回卡组并选择场上一张卡使其效果无效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsOnField() and c:IsRelateToChain()
		-- 判断是否成功将该卡送回卡组。
		and Duel.SendtoDeck(c,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA) then
		-- 提示玩家选择要无效的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 选择符合条件的场上卡。
		local tg=Duel.SelectMatchingCard(tp,aux.NegateAnyFilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
		if tg:GetCount()>0 then
			-- 显示选中的卡作为对象。
			Duel.HintSelection(tg)
			local tc=tg:GetFirst()
			-- 使该卡相关的连锁无效。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 使选中的卡效果无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使选中的卡效果无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 使选中的陷阱怪兽效果无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
