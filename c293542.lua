--TG ワーウルフ
-- 效果：
-- ①：4星以下的怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 狼人」以外的1只「科技属」怪兽加入手卡。
function c293542.initial_effect(c)
	-- ①：4星以下的怪兽特殊召唤时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(293542,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c293542.spcon)
	e1:SetTarget(c293542.sptg)
	e1:SetOperation(c293542.spop)
	c:RegisterEffect(e1)
	-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 狼人」以外的1只「科技属」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c293542.regop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在正面表示且等级不超过4的怪兽。
function c293542.cfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(4)
end
-- 效果条件函数，判断是否有满足过滤条件的怪兽被特殊召唤成功。
function c293542.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c293542.cfilter,1,nil)
end
-- 特殊召唤效果的发动时点处理函数，检查是否满足特殊召唤的条件。
function c293542.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息，告知连锁处理中将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的发动处理函数，执行将此卡特殊召唤到场上的操作。
function c293542.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行将此卡以正面表示形式特殊召唤到玩家场上的操作。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 当此卡因破坏而进入墓地时触发的效果处理函数，注册一个在结束阶段发动的检索效果。
function c293542.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsReason(REASON_DESTROY) then
		-- ②：场上的这张卡被破坏送去墓地的回合的结束阶段才能发动。从卡组把「科技属 狼人」以外的1只「科技属」怪兽加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(293542,1))  --"检索"
		e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetRange(LOCATION_GRAVE)
		e1:SetTarget(c293542.thtg)
		e1:SetOperation(c293542.thop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，用于筛选卡组中「科技属」且不是此卡的怪兽。
function c293542.filter(c)
	return c:IsSetCard(0x27) and not c:IsCode(293542) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 检索效果的发动时点处理函数，检查卡组中是否存在满足条件的怪兽。
function c293542.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家卡组中是否存在至少一张满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c293542.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索效果的操作信息，告知连锁处理中将要从卡组将一张怪兽加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的发动处理函数，执行选择并加入手牌的操作。
function c293542.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从玩家卡组中选择一张满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c293542.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的怪兽以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认被送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
