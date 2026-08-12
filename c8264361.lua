--暗影の闇霊使いダルク
-- 效果：
-- 包含暗属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只暗属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的暗属性怪兽加入手卡。
function c8264361.initial_effect(c)
	-- 设置连接召唤手续，需要2只怪兽，且包含至少1只暗属性怪兽
	aux.AddLinkProcedure(c,nil,2,2,c8264361.lcheck)
	c:EnableReviveLimit()
	-- ①：以对方墓地1只暗属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(8264361,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,8264361)
	e1:SetTarget(c8264361.sptg)
	e1:SetOperation(c8264361.spop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的暗属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(8264361,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,8264362)
	e2:SetCondition(c8264361.thcon)
	e2:SetTarget(c8264361.thtg)
	e2:SetOperation(c8264361.thop)
	c:RegisterEffect(e2)
end
-- 检查连接素材中是否包含至少1只暗属性怪兽
function c8264361.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_DARK)
end
-- 过滤对方墓地中可以特殊召唤到这张卡所连接区的暗属性怪兽
function c8264361.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- 效果①的发动判定与对象选择
function c8264361.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c8264361.spfilter(chkc,e,tp,zone) end
	-- 判定自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定对方墓地是否存在可以特殊召唤到连接区的暗属性怪兽
		and Duel.IsExistingTarget(c8264361.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择对方墓地1只满足条件的暗属性怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c8264361.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置特殊召唤的操作信息，包含选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的处理，将目标怪兽特殊召唤到这张卡的连接区
function c8264361.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取效果发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将目标怪兽以表侧表示特殊召唤到指定的连接区域
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- 判定效果②的发动条件：连接召唤的这张卡被战斗或对方的效果破坏
function c8264361.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 过滤卡组中守备力1500以下的暗属性怪兽
function c8264361.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
-- 效果②的发动判定与检索信息设置
function c8264361.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定卡组中是否存在守备力1500以下的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c8264361.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置加入手牌的操作信息，包含从卡组检索1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的处理，从卡组将1只守备力1500以下的暗属性怪兽加入手牌
function c8264361.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张守备力1500以下的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c8264361.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
