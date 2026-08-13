--海皇子 ネプトアビス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从卡组把「海皇子 尼普深渊王」以外的1只「海皇」怪兽送去墓地才能发动。从卡组把「海皇子 尼普深渊王」以外的1张「海皇」卡加入手卡。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以「海皇子 尼普深渊王」以外的自己墓地1只「海皇」怪兽为对象发动。那只怪兽特殊召唤。
function c21565445.initial_effect(c)
	-- ①：从卡组把「海皇子 尼普深渊王」以外的1只「海皇」怪兽送去墓地才能发动。从卡组把「海皇子 尼普深渊王」以外的1张「海皇」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21565445,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,21565445)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c21565445.cost)
	e1:SetTarget(c21565445.target)
	e1:SetOperation(c21565445.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合，以「海皇子 尼普深渊王」以外的自己墓地1只「海皇」怪兽为对象发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21565445,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,21565446)
	e2:SetCondition(c21565445.spcon)
	e2:SetTarget(c21565445.sptg)
	e2:SetOperation(c21565445.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断卡组中的候选cost卡是否为「海皇」怪兽且不是「海皇子 尼普深渊王」，可作为cost送去墓地，同时卡组中存在满足检索条件的「海皇」卡时才满足。
function c21565445.cfilter(c,tp)
	return c:IsSetCard(0x77) and c:IsType(TYPE_MONSTER) and not c:IsCode(21565445) and c:IsAbleToGraveAsCost()
		-- 额外条件：确认卡组中存在1张可加入手牌的「海皇」卡（非本卡名），以保证cost后检索处理可行。
		and Duel.IsExistingMatchingCard(c21565445.filter,tp,LOCATION_DECK,0,1,c)
end
-- 代价处理：从卡组选择1只满足条件的「海皇」怪兽（非本卡名）作为cost送去墓地。
function c21565445.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：卡组中是否存在可作为cost送去墓地且能保证后续检索可行的「海皇」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(c21565445.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 给玩家显示提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足cfilter条件的「海皇」怪兽作为cost。
	local g=Duel.SelectMatchingCard(tp,c21565445.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 将选择的卡以cost原因送去墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 检索过滤：选择卡组中「海皇」卡（非本卡名）且能够加入手卡的卡。
function c21565445.filter(c)
	return c:IsSetCard(0x77) and not c:IsCode(21565445) and c:IsAbleToHand()
end
-- ①效果发动时的目标处理：无其他条件，登记从卡组将1张「海皇」卡加入手牌的操作信息。
function c21565445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：本效果处理时会将1张卡从卡组加入手牌，处理时再选择具体卡片。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张符合条件的「海皇」卡（非本卡名）加入手牌，并向对方展示。
function c21565445.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家显示提示，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足filter条件的「海皇」卡加入手牌。
	local g=Duel.SelectMatchingCard(tp,c21565445.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方展示加入手牌的那张卡，以确认检索内容。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ②的发动条件：这张卡是作为cost被送去墓地，且该cost是为了发动水属性怪兽的效果而支付的，即发动者必须是水属性怪兽且效果已经实际发动。
function c21565445.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 特殊召唤候选过滤：墓地中的「海皇」怪兽，不是「海皇子 尼普深渊王」，且能够被当前效果特殊召唤。
function c21565445.spfilter(c,e,tp)
	return c:IsSetCard(0x77) and not c:IsCode(21565445) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②的取对象处理：选择自己墓地1只符合条件的「海皇」怪兽作为特殊召唤对象，并登记特殊召唤操作信息。
function c21565445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21565445.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 给玩家显示提示，要求选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足spfilter条件的「海皇」怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,c21565445.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：将选择的怪兽特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若对象仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c21565445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
