--魔轟神獣ペガラサス
-- 效果：
-- 这张卡从手卡丢弃去墓地时，这张卡可以在自己场上盖放。这张卡反转时，可以把手卡1只名字带有「魔轰神」的怪兽给人观看，从自己卡组把1只名字带有「魔轰神」的怪兽送去墓地。
function c90616316.initial_effect(c)
	-- 这张卡从手卡丢弃去墓地时，这张卡可以在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(90616316,0))  --"在自己场上盖放"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(c90616316.spcon)
	e1:SetTarget(c90616316.sptg)
	e1:SetOperation(c90616316.spop)
	c:RegisterEffect(e1)
	-- 这张卡反转时，可以把手卡1只名字带有「魔轰神」的怪兽给人观看，从自己卡组把1只名字带有「魔轰神」的怪兽送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(90616316,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_FLIP)
	e2:SetCost(c90616316.cost2)
	e2:SetTarget(c90616316.tg2)
	e2:SetOperation(c90616316.op2)
	c:RegisterEffect(e2)
end
-- 检查这张卡是否是从手卡被丢弃送去墓地
function c90616316.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND) and bit.band(r,REASON_DISCARD)~=0
end
-- 盖放效果的发动准备与合法性检查
function c90616316.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空怪兽区域，且这张卡是否可以以里侧守备表示特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE) end
	-- 设置连锁信息，表示该效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 盖放效果的处理：将自身里侧守备表示特殊召唤，并给对方确认
function c90616316.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 给对方玩家确认特殊召唤的卡（因为是里侧表示特殊召唤）
		Duel.ConfirmCards(1-tp,c)
	end
end
-- 过滤条件：手卡中未公开的名字带有「魔轰神」的怪兽
function c90616316.cfilter(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 反转效果的Cost处理：展示手卡中1只名字带有「魔轰神」的怪兽
function c90616316.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在可以展示的名字带有「魔轰神」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90616316.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 让玩家选择手卡中1只满足条件的名字带有「魔轰神」的怪兽
	local g=Duel.SelectMatchingCard(tp,c90616316.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选择的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 过滤条件：卡组中可以送去墓地的名字带有「魔轰神」的怪兽
function c90616316.filter2(c)
	return c:IsSetCard(0x35) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 反转效果的发动准备与合法性检查
function c90616316.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的名字带有「魔轰神」的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c90616316.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含从卡组将1张卡送去墓地的操作
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 反转效果的处理：从卡组选择1只名字带有「魔轰神」的怪兽送去墓地
function c90616316.op2(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1只名字带有「魔轰神」的怪兽
	local g=Duel.SelectMatchingCard(tp,c90616316.filter2,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽因效果送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
