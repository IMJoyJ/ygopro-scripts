--魔術師の再演
-- 效果：
-- ①：只在这张卡在场上表侧表示存在才有1次，以自己墓地1只3星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔术师的再演」以外的1张「魔术师」永续魔法卡加入手卡。
function c40252269.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只在这张卡在场上表侧表示存在才有1次，以自己墓地1只3星以下的魔法师族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40252269,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_NO_TURN_RESET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c40252269.sptg)
	e2:SetOperation(c40252269.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。从卡组把「魔术师的再演」以外的1张「魔术师」永续魔法卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(40252269,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetTarget(c40252269.thtg)
	e3:SetOperation(c40252269.thop)
	c:RegisterEffect(e3)
end
-- 筛选自己墓地中满足条件的魔法师族怪兽：种族为魔法师族、等级3以下，且满足特殊召唤条件（可被此次效果特殊召唤）。
function c40252269.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动时点处理：检查自己场上是否有空位、墓地是否存在可特殊召唤的对象；若为取对象场合，校验对象是否为自己墓地中符合筛选的魔法师族怪兽。
function c40252269.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c40252269.spfilter(chkc,e,tp) end
	-- 发动条件检查：自己的主要怪兽区必须有至少1个可用空格，用于后续特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件检查：自己墓地存在至少1只满足筛选条件的魔法师族怪兽，且该怪兽能够成为此效果的对象。
		and Duel.IsExistingTarget(c40252269.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向操作者显示选择提示信息：选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足筛选条件的魔法师族怪兽，将其设为效果的处理对象（取对象）。
	local g=Duel.SelectTarget(tp,c40252269.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息：本次效果包含特殊召唤，预定处理1只对象怪兽，使其被特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若选择的对象仍与此效果关联，则那只怪兽特殊召唤。
function c40252269.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象卡（发动时选择的墓地怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索筛选条件：卡片属于「魔术师」字段的永续魔法卡，卡名不是「魔术师的再演」，且能够加入手卡。
function c40252269.thfilter(c)
	return c:IsSetCard(0x98) and c:GetType()==TYPE_SPELL+TYPE_CONTINUOUS and not c:IsCode(40252269) and c:IsAbleToHand()
end
-- ②效果的发动条件判断与操作信息设置：卡组存在符合条件的检索对象时，登记“从卡组将1张卡加入手卡”的操作信息。
function c40252269.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：卡组中存在至少1张满足检索条件的「魔术师」永续魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c40252269.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果为检索并加入手卡，预定从卡组处理1张卡加入持有者手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选1张符合条件的「魔术师」永续魔法卡加入手卡，并让对方确认。
function c40252269.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作者显示选择提示信息：选择要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足检索条件的卡片（不取对象，效果处理时选择）。
	local g=Duel.SelectMatchingCard(tp,c40252269.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（原因：效果）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的那张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
