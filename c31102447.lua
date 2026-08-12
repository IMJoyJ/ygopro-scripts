--アマゾネスの斥候
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡以外的手卡1只「亚马逊」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被战斗破坏送去墓地时，以「亚马逊斥候」以外的自己墓地1只「亚马逊」怪兽为对象才能发动。那只怪兽加入手卡或回到卡组。
function c31102447.initial_effect(c)
	-- ①：把这张卡以外的手卡1只「亚马逊」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31102447,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,31102447)
	e1:SetCost(c31102447.spcost)
	e1:SetTarget(c31102447.sptg)
	e1:SetOperation(c31102447.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗破坏送去墓地时，以「亚马逊斥候」以外的自己墓地1只「亚马逊」怪兽为对象才能发动。那只怪兽加入手卡或回到卡组。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(31102447,1))  --"怪兽回到手卡或者卡组"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c31102447.thcon)
	e2:SetTarget(c31102447.thtg)
	e2:SetOperation(c31102447.thop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断手卡中是否包含满足条件的「亚马逊」怪兽（未公开）
function c31102447.cfilter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 效果发动时的费用处理，需要确认手卡中存在符合条件的「亚马逊」怪兽并展示给对方
function c31102447.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在满足条件的「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c31102447.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择满足条件的「亚马逊」怪兽
	local g=Duel.SelectMatchingCard(tp,c31102447.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 向对方确认所选的卡
	Duel.ConfirmCards(1-tp,g)
	-- 将玩家的手卡洗牌
	Duel.ShuffleHand(tp)
end
-- 特殊召唤效果的发动条件判断，检查场上是否有空位且自身可以被特殊召唤
function c31102447.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可以特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理，将自身特殊召唤到场上
function c31102447.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果发动条件判断，确认自身是否在墓地
function c31102447.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- 过滤函数，用于判断墓地中是否包含满足条件的「亚马逊」怪兽（非本卡）
function c31102447.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4) and not c:IsCode(31102447) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
-- 效果发动时的目标选择处理，选择墓地中符合条件的「亚马逊」怪兽
function c31102447.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c31102447.thfilter(chkc) end
	-- 检查墓地中是否存在满足条件的「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingTarget(c31102447.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择满足条件的「亚马逊」怪兽作为目标
	local g=Duel.SelectTarget(tp,c31102447.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if not g:GetFirst():IsAbleToHand() then
		-- 设置将目标怪兽送回卡组的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	elseif not g:GetFirst():IsAbleToDeck() then
		-- 设置将目标怪兽送回手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- 效果处理，根据选择将目标怪兽送回手牌或卡组
function c31102447.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且可以送回手牌，若不能则询问是否送回卡组
	if tc:IsRelateToEffect(e) and tc:IsAbleToHand() and (not tc:IsAbleToDeck() or Duel.SelectYesNo(tp,aux.Stringid(31102447,2))) then  --"是否回到手卡？"
		-- 将目标怪兽送回手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方确认目标怪兽被送回手牌
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将目标怪兽送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
