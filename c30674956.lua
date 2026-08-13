--蒼翠の風霊使いウィン
-- 效果：
-- 包含风属性怪兽的怪兽2只
-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：以对方墓地1只风属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的风属性怪兽加入手卡。
function c30674956.initial_effect(c)
	-- 为这张卡添加连接召唤手续：必须用2只怪兽作为连接素材，且其中至少1只为风属性怪兽（由lcheck判定）。
	aux.AddLinkProcedure(c,nil,2,2,c30674956.lcheck)
	c:EnableReviveLimit()
	-- 这个卡名在规则上也当作「凭依装着」卡使用。这个卡名的①②的效果1回合各能使用1次。①：以对方墓地1只风属性怪兽为对象才能发动。那只怪兽在作为这张卡所连接区的自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30674956,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,30674956)
	e1:SetTarget(c30674956.sptg)
	e1:SetOperation(c30674956.spop)
	c:RegisterEffect(e1)
	-- ②：连接召唤的这张卡被战斗或者对方的效果破坏的场合才能发动。从卡组把1只守备力1500以下的风属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30674956,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,30674957)
	e2:SetCondition(c30674956.thcon)
	e2:SetTarget(c30674956.thtg)
	e2:SetOperation(c30674956.thop)
	c:RegisterEffect(e2)
end
-- 连接素材校验函数：检查所选素材组中是否存在至少1只风属性怪兽，以满足召唤条件“包含风属性怪兽的怪兽2只”。
function c30674956.lcheck(g)
	return g:IsExists(Card.IsLinkAttribute,1,nil,ATTRIBUTE_WIND)
end
-- 特殊召唤对象的筛选函数：对象必须是风属性怪兽，且可以被玩家tp以表侧表示特殊召唤到指定区域zone。
function c30674956.spfilter(c,e,tp,zone)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP,tp,zone)
end
-- ①效果的目标选择与发动合法性判定：计算这张卡的连接区；若为对象选择阶段则确认对象是对方墓地的风属性怪兽且可特殊召唤；若为发动判定则确认我方主要怪兽区有空位且对方墓地存在可行对象。
function c30674956.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c30674956.spfilter(chkc,e,tp,zone) end
	-- 发动条件之一：我方主要怪兽区存在可用空格，用于容纳特殊召唤的怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之二：对方墓地存在至少1只满足spfilter条件且能成为效果对象的风属性怪兽。
		and Duel.IsExistingTarget(c30674956.spfilter,tp,0,LOCATION_GRAVE,1,nil,e,tp,zone) end
	-- 弹出提示消息，要求玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从对方墓地选择1只满足条件的风属性怪兽作为对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c30674956.spfilter,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,zone)
	-- 设置本次连锁的操作信息：效果将执行特殊召唤，对象为已选择的卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联且对象仍存在，则将对象怪兽特殊召唤到这张卡当前连接区对应的我方场上。
function c30674956.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	local zone=bit.band(e:GetHandler():GetLinkedZone(tp),0x1f)
	if tc:IsRelateToEffect(e) and zone~=0 then
		-- 将对象怪兽以表侧表示特殊召唤到玩家tp场上，召唤区域限制为这张卡的连接区（zone）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
-- ②效果的发动条件：这张卡被战斗破坏，或被对方的效果破坏，且破坏前在我方怪兽区，并且是以连接召唤方式出场。
function c30674956.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and c:GetReasonPlayer()==1-tp and c:IsPreviousControler(tp)))
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索卡的筛选函数：对象必须是守备力1500以下、风属性，且能够加入手牌。
function c30674956.thfilter(c)
	return c:IsDefenseBelow(1500) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsAbleToHand()
end
-- ②效果发动判定：检查卡组中是否存在1只满足检索条件的风属性怪兽，并设置操作信息。
function c30674956.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在至少1只符合条件的风属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c30674956.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果将把1张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只守备力1500以下的风属性怪兽加入手牌，并展示给对方玩家确认。
function c30674956.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足thfilter条件的卡。
	local g=Duel.SelectMatchingCard(tp,c30674956.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选卡加入其持有者的手牌，原因记为效果（REASON_EFFECT）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手牌的那张卡展示给对方玩家确认，以验证检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
