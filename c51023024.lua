--影霊の翼 ウェンディ
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡反转的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽表侧守备表示或里侧守备表示特殊召唤。
-- ②：这张卡被效果送去墓地的场合才能发动。从卡组把「影灵之翼 文蒂」以外的1只「影依」怪兽里侧守备表示特殊召唤。
function c51023024.initial_effect(c)
	-- ①：这张卡反转的场合才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(51023024,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,51023024)
	e1:SetTarget(c51023024.target)
	e1:SetOperation(c51023024.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被效果送去墓地的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51023024,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,51023024)
	e2:SetCondition(c51023024.spcon)
	e2:SetTarget(c51023024.sptg)
	e2:SetOperation(c51023024.spop)
	c:RegisterEffect(e2)
	c51023024.shadoll_flip_effect=e1
end
-- 过滤函数，用于筛选满足条件的「影依」怪兽（不包括文蒂自身），且可以特殊召唤到场上（守备表示）。
function c51023024.filter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(51023024) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_DEFENSE)
end
-- 效果处理时的判断条件，检查是否满足发动条件：场上存在空位，并且卡组中存在符合条件的怪兽。
function c51023024.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「影依」怪兽。
		and Duel.IsExistingMatchingCard(c51023024.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张来自卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行反转时的效果：从卡组选择一只符合条件的怪兽特殊召唤到场上。
function c51023024.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，如果没有则不继续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,c51023024.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if not tc then return end
	-- 将选中的怪兽以守备表示特殊召唤到场上，并确认其为里侧守备表示时向对方展示该怪兽。
	if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_DEFENSE)~=0 and tc:IsFacedown() then
		-- 向对方玩家确认该怪兽的卡片信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 条件函数，判断此效果是否因「效果」原因被送去墓地。
function c51023024.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选满足条件的「影依」怪兽（不包括文蒂自身），且可以特殊召唤到场上（里侧守备表示）。
function c51023024.spfilter(c,e,tp)
	return c:IsSetCard(0x9d) and not c:IsCode(51023024) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果处理时的判断条件，检查是否满足发动条件：场上存在空位，并且卡组中存在符合条件的怪兽。
function c51023024.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「影依」怪兽。
		and Duel.IsExistingMatchingCard(c51023024.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张来自卡组的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数，执行被送去墓地时的效果：从卡组选择一只符合条件的怪兽以里侧守备表示特殊召唤到场上。
function c51023024.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有空位，如果没有则不继续处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的怪兽。
	local tc=Duel.SelectMatchingCard(tp,c51023024.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp):GetFirst()
	if tc then
		-- 将选中的怪兽以里侧守备表示特殊召唤到场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 向对方玩家确认该怪兽的卡片信息。
		Duel.ConfirmCards(1-tp,tc)
	end
end
