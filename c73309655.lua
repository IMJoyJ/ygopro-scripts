--清冽の水霊使いエリア
-- 效果：
-- 包含水属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只水属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的水属性怪兽加入手卡。
function c73309655.initial_effect(c)
	-- 为卡片添加连接召唤手续：需要2只怪兽，且必须包含水属性怪兽
	aux.AddLinkProcedure(c,nil,2,2,c73309655.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方墓地1只水属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(73309655,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,73309655)
	e1:SetTarget(c73309655.sptg)
	e1:SetOperation(c73309655.spop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的水属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(73309655,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,73309656)
	e2:SetCondition(c73309655.thcon)
	e2:SetTarget(c73309655.thtg)
	e2:SetOperation(c73309655.thop)
	c:RegisterEffect(e2)
end
-- 连接素材的过滤条件：素材组中必须存在至少1只水属性怪兽
function c73309655.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WATER)
end
-- 过滤对方墓地中可以特殊召唤到这张卡连接区的水属性怪兽
function c73309655.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①号效果（特殊召唤）的发动准备与目标选择
function c73309655.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c73309655.spfilter(chkc,e,tp,zone) end
	-- 在发动效果前，检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查对方墓地是否存在至少1只可以特殊召唤到这张卡连接区的水属性怪兽
		and Duel.IsExistingTarget(c73309655.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 向发动效果的玩家发送提示信息：选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择对方墓地1只满足条件的水属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c73309655.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置效果处理信息：将选中的1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①号效果（特殊召唤）的效果处理
function c73309655.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取在发动时选择的作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽以表侧表示特殊召唤到这张卡所连接的自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ②号效果（检索）的发动条件：连接召唤的这张卡被战斗或对方的效果破坏
function c73309655.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中守备力1500以下的水属性怪兽
function c73309655.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- ②号效果（检索）的发动准备
function c73309655.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1只守备力1500以下的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c73309655.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②号效果（检索）的效果处理
function c73309655.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向发动效果的玩家发送提示信息：选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只守备力1500以下的水属性怪兽
	local g=Duel.SelectMatchingCard(tp,c73309655.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的怪兽
		Duel.ConfirmCards(1-tp,g)
	end
end
