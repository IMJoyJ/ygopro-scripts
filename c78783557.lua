--滅亡龍 ヴェイドス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以场地区域1张卡为对象才能发动。这张卡在对方场上特殊召唤，作为对象的卡破坏。那之后，可以从卡组选1张「灰灭」永续陷阱卡加入手卡或在自己场上盖放。
-- ②：这张卡从对方场上送去墓地的场合才能发动。场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册卡片效果：①手卡主要阶段特召到对方场上并破坏场地区域卡片，之后检索或盖放「灰灭」永续陷阱；②从对方场上送墓时破坏场上所有怪兽。
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，自己·对方的主要阶段，以场地区域1张卡为对象才能发动。这张卡在对方场上特殊召唤，作为对象的卡破坏。那之后，可以从卡组选1张「灰灭」永续陷阱卡加入手卡或在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从对方场上送去墓地的场合才能发动。场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏怪兽"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己或对方的主要阶段。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 效果①的发动准备（检查与选择对象）：检查场地区域是否有卡，自身能否在对方场上特召，并选择场地区域的1张卡作为对象。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsOnField() and chkc:IsLocation(LOCATION_FZONE) end
	-- 检查可行性：双方场地区域存在至少1张卡，且自身能以表侧表示特殊召唤到对方场上（对方怪兽区域有空位）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择双方场地区域的1张卡作为效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil)
	-- 设置操作信息：包含破坏选定卡片的操作。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 过滤条件：卡组中的「灰灭」永续陷阱卡，且能加入手卡。
function s.thfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x1ad) and c:IsAbleToHand()
end
-- 过滤条件：卡组中的「灰灭」永续陷阱卡，且能在自己场上盖放。
function s.setfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsType(TYPE_CONTINUOUS) and c:IsSetCard(0x1ad) and c:IsSSetable()
end
-- 效果①的处理：将自身特殊召唤到对方场上，破坏作为对象的卡，之后可选择从卡组将1张「灰灭」永续陷阱卡加入手卡或在自己场上盖放。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于手卡，则将其表侧表示特殊召唤到对方场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEUP)>0 then
		-- 获取作为效果对象的场地区域卡片。
		local tc=Duel.GetFirstTarget()
		-- 若对象卡片仍存在于场上，则将其破坏。
		if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 then
			-- 检查卡组中是否存在可加入手卡的「灰灭」永续陷阱卡。
			local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
			-- 检查卡组中是否存在可盖放的「灰灭」永续陷阱卡。
			local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil)
			if not b1 and not b2 then return end
			-- 让玩家选择后续操作：加入手卡、盖放或什么都不做。
			local op=aux.SelectFromOptions(tp,
				{b1,1190},
				{b2,1153},
				{true,aux.Stringid(id,2)})  --"什么都不做"
			-- 若选择加入手卡或盖放，则中断效果处理，使后续处理不与特召、破坏同时进行。
			if op<3 then Duel.BreakEffect() end
			if op==1 then
				-- 从卡组选择1张满足条件的「灰灭」永续陷阱卡。
				local thc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
				-- 将选择的卡加入手卡。
				Duel.SendtoHand(thc,tp,REASON_EFFECT)
				-- 给对方玩家确认加入手卡的卡片。
				Duel.ConfirmCards(1-tp,thc)
			elseif op==2 then
				-- 从卡组选择1张满足条件的「灰灭」永续陷阱卡。
				local stc=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
				-- 将选择的卡在自己场上盖放。
				Duel.SSet(tp,stc)
			end
		end
	end
end
-- 效果②的发动条件：此卡从对方场上送去墓地。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousControler(1-tp)
end
-- 效果②的发动准备：检查场上是否存在怪兽，并设置破坏所有怪兽的操作信息。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查可行性：场上是否存在至少1只怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上的所有怪兽。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息：破坏场上的所有怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果②的处理：获取场上的所有怪兽并将其全部破坏。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上的所有怪兽。
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏获取到的所有怪兽。
	Duel.Destroy(sg,REASON_EFFECT)
end
