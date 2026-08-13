--太陽電池メン
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只雷族怪兽送去墓地。
-- ②：这张卡已在怪兽区域存在的状态，雷族怪兽召唤·特殊召唤的场合发动。在自己场上把1只「电池人衍生物」（雷族·光·1星·攻/守0）特殊召唤。
-- ③：以自己的场上·墓地1只「电池人」效果怪兽为对象才能发动。直到结束阶段，这张卡当作那同名卡使用。
function c44586426.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1只雷族怪兽送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44586426,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,44586426)
	e1:SetTarget(c44586426.tgtg)
	e1:SetOperation(c44586426.tgop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡已在怪兽区域存在的状态，雷族怪兽召唤·特殊召唤的场合发动。在自己场上把1只「电池人衍生物」（雷族·光·1星·攻/守0）特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44586426,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetCountLimit(1,44586427)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c44586426.tkcon)
	e3:SetTarget(c44586426.tktg)
	e3:SetOperation(c44586426.tkop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e4)
	-- ③：以自己的场上·墓地1只「电池人」效果怪兽为对象才能发动。直到结束阶段，这张卡当作那同名卡使用。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(44586426,2))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_MZONE)
	e5:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e5:SetCountLimit(1,44586428)
	e5:SetTarget(c44586426.nmtg)
	e5:SetOperation(c44586426.nmop)
	c:RegisterEffect(e5)
end
-- 过滤出卡组中雷族且可以送去墓地的怪兽。
function c44586426.tgfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToGrave()
end
-- 效果发动时的目标判定：检查卡组是否存在满足条件的雷族怪兽，并设置送去墓地的操作信息。
function c44586426.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若发动时存在满足条件的卡，则效果可以发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c44586426.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次效果处理为从卡组把1张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，从卡组选择1只雷族怪兽送去墓地。
function c44586426.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张符合条件的雷族怪兽。
	local g=Duel.SelectMatchingCard(tp,c44586426.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 判断怪兽是否为表侧表示的雷族怪兽。
function c44586426.tkcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- ②效果的发动条件：雷族怪兽召唤·特殊召唤成功时，且该怪兽不是这张卡自身。
function c44586426.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44586426.tkcfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- ②效果的目标判定：没有取对象需求，同时设置衍生物特殊召唤的操作信息。
function c44586426.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将衍生物特殊召唤到场的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- ②效果处理：检查能否特殊召唤衍生物，能则生成衍生物并特殊召唤。
function c44586426.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方主要怪兽区是否有空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 检查我方是否能特殊召唤「电池人衍生物」（雷族·光·1星·攻/守0）。
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,44586427,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT) then return end
	-- 在场上生成「电池人衍生物」（雷族·光·1星·攻/守0）。
	local token=Duel.CreateToken(tp,44586427)
	-- 将衍生物以表侧攻击表示特殊召唤到我方场上。
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- ③效果的对象筛选：选择我方场上表侧表示或墓地的「电池人」效果怪兽，且不能是这张卡自身。
function c44586426.nmfilter(c,cd)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_EFFECT)
		and c:IsSetCard(0x28) and not c:IsCode(cd)
end
-- ③效果的目标选择：从我方场上·墓地选择1只符合条件的「电池人」效果怪兽作为对象。
function c44586426.nmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cd=e:GetHandler():GetCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c44586426.nmfilter(chkc,cd) end
	-- 若存在符合条件的对象，则效果可以发动。
	if chk==0 then return Duel.IsExistingTarget(c44586426.nmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,cd) end
	-- 向玩家提示选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择对象并将其登记为效果对象。
	Duel.SelectTarget(tp,c44586426.nmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,cd)
end
-- ③效果处理：让这张卡获得复制对象卡名的效果，直到结束阶段。
function c44586426.nmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) then
		-- 直到结束阶段，这张卡当作那同名卡使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
