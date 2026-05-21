--妖醒龍ラルバウール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上的怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。选自己1张手卡丢弃，和作为对象的怪兽相同种族·属性而卡名不同的1只怪兽从卡组加入手卡。
function c8972398.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上的怪兽被战斗或者对方的效果破坏的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8972398,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,8972398)
	e1:SetCondition(c8972398.spcon)
	e1:SetTarget(c8972398.sptg)
	e1:SetOperation(c8972398.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。选自己1张手卡丢弃，和作为对象的怪兽相同种族·属性而卡名不同的1只怪兽从卡组加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8972398,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,8972399)
	e2:SetTarget(c8972398.thtg)
	e2:SetOperation(c8972398.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上的怪兽被战斗或者对方的效果破坏
function c8972398.cfilter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and (c:IsReason(REASON_BATTLE) or c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp)
end
-- ①号效果发动条件：检查是否有满足条件的自己场上的怪兽被破坏
function c8972398.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c8972398.cfilter,1,e:GetHandler(),tp)
end
-- ①号效果发动准备：检查怪兽区域空位以及自身是否能特殊召唤
function c8972398.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果处理：将这张卡特殊召唤，并添加离开场上时除外的效果
function c8972398.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并将其以表侧表示特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡特殊召唤成功的场合，以场上1只表侧表示怪兽为对象才能发动。选自己1张手卡丢弃，和作为对象的怪兽相同种族·属性而卡名不同的1只怪兽从卡组加入手卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤条件：场上表侧表示存在，且卡组中存在与其相同种族·属性且卡名不同的怪兽
function c8972398.tgfilter(c,tp)
	-- 检查怪兽是否表侧表示，且卡组中是否存在满足检索条件的怪兽
	return c:IsFaceup() and Duel.IsExistingMatchingCard(c8972398.thfilter,tp,LOCATION_DECK,0,1,nil,c)
end
-- 过滤条件：卡组中与作为对象的怪兽相同种族·属性且卡名不同的怪兽
function c8972398.thfilter(c,tc)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
		and c:IsRace(tc:GetRace()) and c:IsAttribute(tc:GetAttribute()) and not c:IsCode(tc:GetCode())
end
-- ②号效果发动准备：检查手牌数量，选择场上1只表侧表示怪兽作为对象，并设置丢弃手牌和检索的操作信息
function c8972398.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c8972398.tgfilter(chkc,tp) end
	-- 检查自己手牌数量是否大于0
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0
		-- 检查场上是否存在可以作为对象的表侧表示怪兽
		and Duel.IsExistingTarget(c8972398.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	Duel.SelectTarget(tp,c8972398.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,tp)
	-- 设置丢弃手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	-- 设置从卡组将卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果处理：丢弃1张手牌，将与对象怪兽相同种族·属性且卡名不同的1只怪兽从卡组加入手牌
function c8972398.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 选自己1张手牌丢弃，并检查作为对象的怪兽是否仍表侧表示存在于场上
	if Duel.DiscardHand(tp,nil,1,1,REASON_DISCARD+REASON_EFFECT,nil)>0 and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1只与对象怪兽相同种族·属性且卡名不同的怪兽
		local g=Duel.SelectMatchingCard(tp,c8972398.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc)
		if g:GetCount()>0 then
			-- 将选中的怪兽加入手牌
			Duel.SendtoHand(g,tp,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡片
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
