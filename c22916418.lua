--超人伝－マントマン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：原本持有者是自己的表侧表示卡在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡只要在怪兽区域存在，不能解放，不会被战斗破坏。
-- ③：这张卡召唤·特殊召唤的回合的结束阶段才能发动。这张卡回到卡组最下面。那之后，可以让原本持有者是自己的场上1张表侧表示卡回到手卡。
local s,id,o=GetID()
-- 注册②效果（不能解放、不会被战斗破坏）、①效果（手卡起动，特殊召唤自己）、③效果（召唤·特殊召唤的回合结束阶段回卡组并可追加回手卡），并注册全局辅助效果用于记录召唤/特殊召唤以实现③的发动条件。
function s.initial_effect(c)
	-- ②：这张卡只要在怪兽区域存在，不能解放，不会被战斗破坏。——此处实现‘不能解放’中上级召唤的解放限制部分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	c:RegisterEffect(e2)
	-- ②：这张卡只要在怪兽区域存在，不能解放，不会被战斗破坏。——此处实现‘不会被战斗破坏’。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ①：原本持有者是自己的表侧表示卡在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_HAND)
	e4:SetCountLimit(1,id)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
	-- ③：这张卡召唤·特殊召唤的回合的结束阶段才能发动。这张卡回到卡组最下面。那之后，可以让原本持有者是自己的场上1张表侧表示卡回到手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"回到卡组"
	e5:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e5:SetRange(LOCATION_MZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetCode(EVENT_PHASE+PHASE_END)
	e5:SetCondition(s.retcon)
	e5:SetTarget(s.rettg)
	e5:SetOperation(s.retop)
	c:RegisterEffect(e5)
	if not s.global_check then
		s.global_check=true
		-- 对应效果原文：这个卡名的①③的效果1回合各能使用1次。①：原本持有者是自己的表侧表示卡在对方场上存在的场合才能发动。这张卡从手卡特殊召唤。③：这张卡召唤·特殊召唤的回合的结束阶段才能发动。这张卡回到卡组最下面。那之后，可以让原本持有者是自己的场上1张表侧表示卡回到手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetLabel(id)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		-- 设置全局辅助操作：当怪兽召唤成功时，给该怪兽记录本回合已召唤（供③效果判断‘召唤·特殊召唤的回合’）。
		ge1:SetOperation(aux.sumreg)
		-- 将全局的『召唤成功记录』效果注册入游戏，使任意通常召唤成功时都触发该记录。
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		-- 将全局的『特殊召唤成功记录』效果注册入游戏，使任意特殊召唤成功时都触发该记录。
		Duel.RegisterEffect(ge2,0)
	end
end
-- 筛选函数：卡片的原本持有者为当前玩家tp，并且是表侧表示。
function s.cfilter(c,tp)
	return c:GetOwner()==tp and c:IsFaceup()
end
-- ①效果的发动条件：对方场上有原本持有者为自己的表侧表示卡存在。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上是否存在至少1张原本持有者是自己的表侧表示卡。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_ONFIELD,1,nil,tp)
end
-- ①效果发动时的目标检查：确认自己场上有空位且这张卡可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息：本次效果将执行特殊召唤（对象是这张卡自身）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关，则将其从手卡特殊召唤到自己的怪兽区域。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ③效果的发动条件：这张卡带有本回合被召唤或特殊召唤的标记。
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(id)~=0
end
-- 筛选可返回手卡的卡：原本持有者为当前玩家、表侧表示，且能够加入手卡。
function s.thfilter(c,tp)
	return c:GetOwner()==tp and c:IsFaceup() and c:IsAbleToHand()
end
-- ③效果发动时检查：这张卡自身能否回到卡组，并设置回卡组的连锁信息。
function s.rettg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToDeck() end
	-- 设置连锁操作信息：本次效果将执行回卡组操作。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,e:GetHandler(),1,0,0)
end
-- ③效果处理：把这张卡送回卡组最下面；若处理成功且场上有符合条件的卡，询问玩家是否将1张原本持有者为自己的表侧表示卡返回手卡。
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果相关，并把它以效果原因送回卡组最下面，判断送卡组是否成功。
	if c:IsRelateToEffect(e) and Duel.SendtoDeck(c,nil,SEQ_DECKBOTTOM,REASON_EFFECT)~=0
		and c:IsLocation(LOCATION_DECK+LOCATION_EXTRA)
		-- 检查场上是否存在至少1张原本持有者为自己的表侧表示且可以加入手卡的卡。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,tp)
		-- 询问玩家是否执行‘那之后’的追加处理：选1张原本持有者为自己的表侧表示卡返回手卡。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否选卡回到手卡？"
		-- 中断当前效果处理，使后续的‘返回手卡’处理与前面的‘回卡组’处理分开结算，避免错过时点。
		Duel.BreakEffect()
		-- 向玩家显示选择提示，要求选择要返回手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
		-- 让当前玩家从双方场上选择1张符合条件的表侧表示卡。
		local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil,tp)
		if #sg>0 then
			-- 手动展示选中的卡，并将其记录为效果处理对象。
			Duel.HintSelection(sg)
			-- 将选中的卡以效果原因返回持有者的手卡。
			Duel.SendtoHand(sg,POS_FACEUP,REASON_EFFECT)
		end
	end
end
