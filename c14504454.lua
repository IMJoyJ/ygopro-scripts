--悪魔嬢アリス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：从自己的手卡·墓地把1张陷阱卡除外才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤成功时，以自己墓地1只「恶魔娘」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ③：这张卡被解放的场合或者被对方破坏的场合才能发动。从卡组把「恶魔娘 爱莉丝」以外的1只攻击力·守备力的合计是2000的恶魔族怪兽加入手卡。
function c14504454.initial_effect(c)
	-- ①：从自己的手卡·墓地把1张陷阱卡除外才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,14504454)
	e1:SetCost(c14504454.sscost)
	e1:SetTarget(c14504454.sstg)
	e1:SetOperation(c14504454.ssop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤成功时，以自己墓地1只「恶魔娘」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c14504454.sptg)
	e2:SetOperation(c14504454.spop)
	c:RegisterEffect(e2)
	-- ③：这张卡被解放的场合或者被对方破坏的场合才能发动。从卡组把「恶魔娘 爱莉丝」以外的1只攻击力·守备力的合计是2000的恶魔族怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_RELEASE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,14504455)
	e3:SetTarget(c14504454.thtg)
	e3:SetOperation(c14504454.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(c14504454.thcon)
	c:RegisterEffect(e4)
end
-- 定义①效果的代价过滤器：候选卡必须是陷阱卡且可以作为代价除外。
function c14504454.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ①效果的代价处理：检查手卡·墓地是否存在可除外的陷阱卡，存在则让玩家选择1张，并将其表侧表示除外作为发动代价。
function c14504454.sscost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时合法性检查：确认手卡·墓地存在1张以上可作为代价除外的陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c14504454.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发出选择提示，提示内容为“请选择要除外的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡·墓地选择1张符合条件的陷阱卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c14504454.costfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的陷阱卡以表侧表示除外，处理为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ①效果发动条件判定：自己场上存在可用的主要怪兽区空格，且这张卡自身可以被特殊召唤。
function c14504454.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格，以保证特殊召唤位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设定效果处理信息：本次效果将特殊召唤这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，则将自身从手卡特殊召唤到场上。
function c14504454.ssop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到发动者场上。
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的对象过滤器：必须是「恶魔娘」怪兽，且可以被当前效果特殊召唤。
function c14504454.spfilter(c,e,tp)
	return c:IsSetCard(0x174) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时的取对象处理：检查场上空位和墓地可选对象，并让玩家选择1只「恶魔娘」怪兽作为特殊召唤对象。
function c14504454.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c14504454.spfilter(chkc,e,tp) end
	-- 检查自己场上是否有可用的主要怪兽区空格，用于特殊召唤对象怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在1只以上满足过滤条件且能成为效果对象的「恶魔娘」怪兽。
		and Duel.IsExistingTarget(c14504454.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发出选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从墓地选择1只符合条件的「恶魔娘」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c14504454.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设定效果处理信息：本次效果将特殊召唤所选的对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取得效果对象，若对象仍与效果关联，则将其特殊召唤到自己的场上。
function c14504454.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得本效果连锁中记录的第一张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到发动者场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义③效果的检索过滤器：恶魔族、卡名不为「恶魔娘 爱莉丝」、可加入手卡，且攻击力·守备力的合计为2000。
function c14504454.thfilter(c)
	return c:IsRace(RACE_FIEND) and not c:IsCode(14504454) and c:IsAbleToHand()
		and c:IsAttackAbove(0) and c:IsDefenseAbove(0) and c:GetAttack()+c:GetDefense()==2000
end
-- ③效果发动条件判定：卡组存在满足检索条件的怪兽，并设定效果处理信息为从卡组检索加入手卡。
function c14504454.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：卡组中存在1张以上满足检索条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c14504454.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设定效果处理信息：本次效果将从卡组把1张卡加入手卡，检索区域为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ③效果处理：从卡组选择1张符合条件的怪兽加入手卡，并展示给对方确认。
function c14504454.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发出选择提示，提示内容为“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c14504454.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将所选怪兽加入其持有者的手卡，原因为效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义③效果中“被对方破坏”的触发条件：破坏效果的控制者是对方，且这张卡之前由自己控制。
function c14504454.thcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp and e:GetHandler():IsPreviousControler(tp)
end
