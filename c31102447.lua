--アマゾネスの斥候
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：把这张卡以外的手卡1只「亚马逊」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被战斗破坏送去墓地时，以「亚马逊斥候」以外的自己墓地1只「亚马逊」怪兽为对象才能发动。那只怪兽加入手卡或回到卡组。
function c31102447.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：把这张卡以外的手卡1只「亚马逊」怪兽给对方观看才能发动。这张卡从手卡特殊召唤。
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
-- 定义①效果cost的过滤函数：检索手卡中满足「亚马逊」字段、是怪兽且当前不是公开状态的卡，用以选作展示给对方确认的卡。
function c31102447.cfilter(c)
	return c:IsSetCard(0x4) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- ①效果的cost处理：发动前从手卡选择1只除自身以外的「亚马逊」怪兽给对方观看，并洗切手卡。
function c31102447.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足cost条件：自己手卡中是否存在1张满足过滤条件且不是这张卡本身的「亚马逊」怪兽可供展示。
	if chk==0 then return Duel.IsExistingMatchingCard(c31102447.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 弹出选择提示，让玩家选择要展示给对方确认的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡中选出1张符合条件的「亚马逊」怪兽作为展示用卡。
	local g=Duel.SelectMatchingCard(tp,c31102447.cfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	-- 将选择的卡展示给对方玩家确认。
	Duel.ConfirmCards(1-tp,g)
	-- 展示后洗切自己的手卡，避免手卡顺序信息被泄露。
	Duel.ShuffleHand(tp)
end
-- ①效果发动时的目标检查：确认自己场上有可用的怪兽区域，且这张卡能够被特殊召唤。
function c31102447.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域，确保可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息为“特殊召唤这张卡”，供相关卡片的发动时点检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则以表侧表示特殊召唤这张卡到自己场上。
function c31102447.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡从手卡表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡被战斗破坏送去墓地后，确认它位于墓地才能发动。
function c31102447.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE)
end
-- ②效果的对象筛选条件：自己墓地1只「亚马逊」怪兽，且不是「亚马逊斥候」本身，并且该怪兽可加入手卡或回到卡组。
function c31102447.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x4) and not c:IsCode(31102447) and (c:IsAbleToHand() or c:IsAbleToDeck())
end
-- ②效果发动时的目标选择：以墓地的「亚马逊」怪兽为对象，并根据对象可回手/回卡组的情况设置对应的操作信息。
function c31102447.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c31102447.thfilter(chkc) end
	-- 检查墓地是否存在满足条件且能成为效果对象的「亚马逊」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c31102447.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出选择提示，让玩家选择要返回手卡（或卡组）的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 从自己墓地选择1只符合条件的「亚马逊」怪兽作为效果对象，并登记为当前连锁对象。
	local g=Duel.SelectTarget(tp,c31102447.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	if not g:GetFirst():IsAbleToHand() then
		-- 如果对象不能加入手卡但能回到卡组，则设置操作信息为“回到卡组”。
		Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
	elseif not g:GetFirst():IsAbleToDeck() then
		-- 如果对象不能回到卡组但能加入手卡，则设置操作信息为“加入手卡”。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	end
end
-- ②效果处理：将对象怪兽加入手卡或回到卡组；若两者都可行则由玩家选择，否则按可行方式处理。
function c31102447.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果的对象（墓地中选择的那只「亚马逊」怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象是否仍与效果关联且能加入手卡，并且（不能回卡组或玩家选择回手卡时），执行回手卡处理；否则执行回卡组处理。
	if tc:IsRelateToEffect(e) and tc:IsAbleToHand() and (not tc:IsAbleToDeck() or Duel.SelectYesNo(tp,aux.Stringid(31102447,2))) then  --"是否回到手卡？"
		-- 将目标怪兽加入持有者的手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方展示加入手卡的卡，确认处理结果。
		Duel.ConfirmCards(1-tp,tc)
	else
		-- 将目标怪兽送回持有者卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
