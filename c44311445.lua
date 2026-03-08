--マドルチェ・プディンセス・ショコ・ア・ラ・モード
-- 效果：
-- 地属性5星怪兽×2
-- 这张卡也能在自己场上的4阶以下的「魔偶甜点」超量怪兽上面重叠来超量召唤。
-- ①：1回合1次，以自己墓地1张「魔偶甜点」卡为对象才能发动。那张卡回到卡组。
-- ②：这张卡有「魔偶甜点·布丁公主」在作为超量素材的状态，自己墓地的「魔偶甜点」卡回到卡组时，把这张卡1个超量素材取除才能发动。从卡组把1只「魔偶甜点」怪兽表侧攻击表示或里侧守备表示特殊召唤。
function c44311445.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),5,2,c44311445.ovfilter,aux.Stringid(44311445,0))  --"是否在「魔偶甜点」超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：1回合1次，以自己墓地1张「魔偶甜点」卡为对象才能发动。那张卡回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44311445,1))  --"回到卡组"
	e1:SetCategory(CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c44311445.tdtg)
	e1:SetOperation(c44311445.tdop)
	c:RegisterEffect(e1)
	-- ②：这张卡有「魔偶甜点·布丁公主」在作为超量素材的状态，自己墓地的「魔偶甜点」卡回到卡组时，把这张卡1个超量素材取除才能发动。从卡组把1只「魔偶甜点」怪兽表侧攻击表示或里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(44311445,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c44311445.spcon)
	e2:SetCost(c44311445.spcost)
	e2:SetTarget(c44311445.sptg)
	e2:SetOperation(c44311445.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的怪兽，用于XYZ召唤时判断是否可以作为超量素材的「魔偶甜点」怪兽（等级4以下且表侧表示）
function c44311445.ovfilter(c)
	return c:IsFaceup() and c:IsRankBelow(4) and c:IsSetCard(0x71)
end
-- 过滤满足条件的「魔偶甜点」卡，用于选择返回卡组的卡
function c44311445.tdfilter(c)
	return c:IsSetCard(0x71) and c:IsAbleToDeck()
end
-- 设置效果目标，选择墓地中的「魔偶甜点」卡作为目标
function c44311445.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c44311445.tdfilter(chkc) end
	-- 检查是否有满足条件的墓地「魔偶甜点」卡作为目标
	if chk==0 then return Duel.IsExistingTarget(c44311445.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择墓地中的「魔偶甜点」卡作为目标
	local g=Duel.SelectTarget(tp,c44311445.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果操作信息，确定将目标卡返回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 处理效果的发动，将目标卡返回卡组
function c44311445.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡返回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 过滤满足条件的卡，用于判断是否为从墓地回到卡组的「魔偶甜点」卡
function c44311445.cfilter(c,tp)
	return c:IsSetCard(0x71) and c:IsLocation(LOCATION_DECK)
		and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_GRAVE)
end
-- 判断是否满足触发效果的条件，即本卡有「魔偶甜点·布丁公主」作为超量素材且有「魔偶甜点」卡从墓地回到卡组
function c44311445.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetOverlayGroup():IsExists(Card.IsCode,1,nil,74641045) and eg:IsExists(c44311445.cfilter,1,nil,tp)
end
-- 设置效果发动的费用，移除本卡的一个超量素材
function c44311445.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_COST) end
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 过滤满足条件的「魔偶甜点」怪兽，用于特殊召唤
function c44311445.spfilter(c,e,tp)
	return c:IsSetCard(0x71) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)
end
-- 设置特殊召唤效果的目标，检查是否有满足条件的「魔偶甜点」怪兽可特殊召唤
function c44311445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否有满足条件的「魔偶甜点」怪兽
		and Duel.IsExistingMatchingCard(c44311445.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果操作信息，确定将从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理效果的发动，从卡组特殊召唤怪兽
function c44311445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有足够的位置进行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择卡组中满足条件的「魔偶甜点」怪兽作为特殊召唤目标
	local g=Duel.SelectMatchingCard(tp,c44311445.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 执行特殊召唤操作，并确认对方是否能看到里侧表示的怪兽
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK+POS_FACEDOWN_DEFENSE)~=0 and tc:IsFacedown() then
			-- 确认对方能看到特殊召唤的里侧表示怪兽
			Duel.ConfirmCards(1-tp,tc)
		end
	end
end
