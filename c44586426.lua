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
-- 检索满足条件的雷族怪兽（可送去墓地）
function c44586426.tgfilter(c)
	return c:IsRace(RACE_THUNDER) and c:IsAbleToGrave()
end
-- 设置效果处理时要送去墓地的卡
function c44586426.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足条件：场上存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c44586426.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要送去墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 选择并把满足条件的卡送去墓地
function c44586426.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c44586426.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 过滤满足条件的雷族怪兽（在场上）
function c44586426.tkcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 判断是否满足条件：有雷族怪兽被召唤或特殊召唤
function c44586426.tkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c44586426.tkcfilter,1,nil) and not eg:IsContains(e:GetHandler())
end
-- 设置效果处理时要特殊召唤的衍生物
function c44586426.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理时要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	-- 设置效果处理时要特殊召唤的衍生物
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
-- 判断是否满足条件：场上是否有空位且可以特殊召唤衍生物
function c44586426.tkop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足条件：场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0
		-- 判断是否满足条件：玩家是否可以特殊召唤衍生物
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,44586427,0,TYPES_TOKEN_MONSTER,0,0,1,RACE_THUNDER,ATTRIBUTE_LIGHT) then return end
	-- 创建一个电池人衍生物
	local token=Duel.CreateToken(tp,44586427)
	-- 将创建的衍生物特殊召唤到场上
	Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤满足条件的电池人效果怪兽（在场上或墓地）
function c44586426.nmfilter(c,cd)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_EFFECT)
		and c:IsSetCard(0x28) and not c:IsCode(cd)
end
-- 设置效果处理时要选择的对象
function c44586426.nmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local cd=e:GetHandler():GetCode()
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) and c44586426.nmfilter(chkc,cd) end
	-- 检查是否满足条件：场上或墓地存在满足过滤条件的卡
	if chk==0 then return Duel.IsExistingTarget(c44586426.nmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil,cd) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的卡作为效果对象
	Duel.SelectTarget(tp,c44586426.nmfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil,cd)
end
-- 将自身变成目标卡的同名卡
function c44586426.nmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前效果处理的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and c:IsFaceup() and tc:IsRelateToEffect(e) and (tc:IsLocation(LOCATION_GRAVE) or tc:IsFaceup()) then
		-- 使自身变成目标卡的同名卡
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_CODE)
		e1:SetValue(tc:GetOriginalCode())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
