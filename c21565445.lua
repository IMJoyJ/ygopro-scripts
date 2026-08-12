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
-- 过滤函数，用于检查卡组中是否存在满足条件的「海皇」怪兽（不包括自身），并且卡组中存在满足条件的「海皇」卡（用于检索）
function c21565445.cfilter(c,tp)
	return c:IsSetCard(0x77) and c:IsType(TYPE_MONSTER) and not c:IsCode(21565445) and c:IsAbleToGraveAsCost()
		-- 检查卡组中是否存在满足条件的「海皇」卡（用于检索）
		and Duel.IsExistingMatchingCard(c21565445.filter,tp,LOCATION_DECK,0,1,c)
end
-- 效果发动时的费用支付处理，选择1只满足条件的「海皇」怪兽送去墓地作为费用
function c21565445.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足费用支付条件，即卡组中是否存在满足条件的「海皇」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21565445.cfilter,tp,LOCATION_DECK,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的「海皇」怪兽送去墓地
	local g=Duel.SelectMatchingCard(tp,c21565445.cfilter,tp,LOCATION_DECK,0,1,1,nil,tp)
	-- 将选中的怪兽送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤函数，用于检索卡组中满足条件的「海皇」卡（不包括自身）
function c21565445.filter(c)
	return c:IsSetCard(0x77) and not c:IsCode(21565445) and c:IsAbleToHand()
end
-- 设置效果处理时的操作信息，准备检索1张「海皇」卡加入手牌
function c21565445.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时的操作信息，准备检索1张「海皇」卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果发动时的处理，从卡组检索1张满足条件的「海皇」卡加入手牌
function c21565445.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「海皇」卡
	local g=Duel.SelectMatchingCard(tp,c21565445.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否满足特殊召唤条件，即自身因水属性怪兽效果被送去墓地
function c21565445.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤函数，用于检查墓地中满足条件的「海皇」怪兽（不包括自身）
function c21565445.spfilter(c,e,tp)
	return c:IsSetCard(0x77) and not c:IsCode(21565445) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择处理，选择1只满足条件的「海皇」怪兽作为特殊召唤对象
function c21565445.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21565445.spfilter(chkc,e,tp) end
	if chk==0 then return true end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「海皇」怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c21565445.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理时的操作信息，准备特殊召唤1只「海皇」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理，将选中的怪兽特殊召唤到场上
function c21565445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
