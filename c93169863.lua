--クリスタル・ガール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1只5星以上的水属性怪兽加入手卡。
-- ②：这张卡在墓地存在，自己场上有5星以上的水属性怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c93169863.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1只5星以上的水属性怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93169863,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,93169863)
	e1:SetOperation(c93169863.regop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡在墓地存在，自己场上有5星以上的水属性怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(93169863,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,93169864)
	e3:SetCondition(c93169863.spcon)
	e3:SetTarget(c93169863.sptg)
	e3:SetOperation(c93169863.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中5星以上的水属性怪兽且能加入手卡
function c93169863.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 注册在回合结束阶段发动检索效果的延迟效果
function c93169863.regop(e,tp,eg,ep,ev,re,r,rp)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。这个回合的结束阶段，从卡组把1只5星以上的水属性怪兽加入手卡。②：这张卡在墓地存在，自己场上有5星以上的水属性怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetCondition(c93169863.thcon)
	e1:SetOperation(c93169863.thop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将延迟效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 延迟效果的发动条件：卡组中存在满足条件的怪兽
function c93169863.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在5星以上的水属性怪兽
	return Duel.IsExistingMatchingCard(c93169863.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 延迟效果的处理：从卡组选择1只5星以上的水属性怪兽加入手卡
function c93169863.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 展示卡片发动提示
	Duel.Hint(HINT_CARD,0,93169863)
	-- 设置选择卡片时的提示信息为加入手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c93169863.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：自己场上表侧表示的5星以上的水属性怪兽
function c93169863.cfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 特殊召唤效果的发动条件：自己场上存在5星以上的水属性怪兽
function c93169863.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的5星以上的水属性怪兽
	return Duel.IsExistingMatchingCard(c93169863.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 特殊召唤效果的靶向/检测：检查怪兽区域空格并设置特殊召唤的操作信息
function c93169863.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 在发动检测阶段，检查自己场上是否有空位且自身能否特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的处理：将自身特殊召唤，并添加离场时除外的效果
function c93169863.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则尝试将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1)
	end
	-- 完成特殊召唤的流程
	Duel.SpecialSummonComplete()
end
