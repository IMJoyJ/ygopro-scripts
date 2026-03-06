--聖なる影 ケイウス
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从手卡把1只「影依」怪兽表侧守备表示或者里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。从手卡把1只「影依」怪兽送去墓地。这个回合中，以下效果适用。
-- ●自己场上的怪兽的攻击力·守备力上升这个效果送去墓地的怪兽的原本等级×100。
function c24635329.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。从手卡把1只「影依」怪兽表侧守备表示或者里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24635329,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,24635329)
	e1:SetTarget(c24635329.target)
	e1:SetOperation(c24635329.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。从手卡把1只「影依」怪兽送去墓地。这个回合中，以下效果适用。●自己场上的怪兽的攻击力·守备力上升这个效果送去墓地的怪兽的原本等级×100。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24635329,1))
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,24635329)
	e2:SetCondition(c24635329.tgcon)
	e2:SetTarget(c24635329.tgtg)
	e2:SetOperation(c24635329.tgop)
	c:RegisterEffect(e2)
	c24635329.shadoll_flip_effect=e1
end
-- 过滤函数，用于筛选手牌中满足条件的「影依」怪兽，可特殊召唤且为守备表示。
function c24635329.filter(c,e,tp)
	return c:IsSetCard(0x9d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位和手牌中是否存在符合条件的怪兽。
function c24635329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区域（主怪兽区）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查玩家手牌中是否存在至少一张符合条件的「影依」怪兽。
		and Duel.IsExistingMatchingCard(c24635329.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理函数，包括选择目标怪兽并执行特殊召唤。
function c24635329.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的怪兽区域，若无则返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择一张符合条件的「影依」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c24635329.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 执行特殊召唤操作，并在怪兽为里侧表示时确认其信息。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 向对方玩家确认被特殊召唤的怪兽信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 判断该卡是否因效果被送去墓地。
function c24635329.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选手牌中满足条件的「影依」怪兽，可送去墓地。
function c24635329.tgfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 设置操作信息，表示将要送去墓地一张怪兽。
function c24635329.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在至少一张符合条件的「影依」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c24635329.tgfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息，表示将要送去墓地一张怪兽。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
end
-- 送去墓地效果的处理函数，包括选择目标怪兽并执行送去墓地操作。
function c24635329.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌中选择一张符合条件的「影依」怪兽。
	local tc=Duel.SelectMatchingCard(tp,c24635329.tgfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	-- 执行送去墓地操作，并在成功送去墓地后设置攻击力和守备力提升效果。
	if tc and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		local lv=tc:GetOriginalLevel()
		-- 创建并注册攻击力和守备力提升效果，提升值为被送去墓地怪兽的原本等级乘以100。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetValue(lv*100)
		e1:SetTargetRange(LOCATION_MZONE,0)
		-- 将攻击力提升效果注册到场上。
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		-- 将守备力提升效果注册到场上。
		Duel.RegisterEffect(e2,tp)
	end
end
