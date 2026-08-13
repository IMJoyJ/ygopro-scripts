--No.37 希望織竜スパイダー・シャーク
-- 效果：
-- 水属性4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
-- ②：这张卡被战斗·效果破坏送去墓地时，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c37279508.initial_effect(c)
	-- 为这张卡添加XYZ召唤手续：以水属性4星怪兽2只为素材进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,2)
	c:EnableReviveLimit()
	-- ①：自己或者对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37279508,0))  --"攻击力下降"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCountLimit(1,37279508)
	e1:SetCost(c37279508.atkcost)
	e1:SetTarget(c37279508.atktg)
	e1:SetOperation(c37279508.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡被战斗·效果破坏送去墓地时，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(37279508,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,37279509)
	e2:SetCondition(c37279508.spcon)
	e2:SetTarget(c37279508.sptg)
	e2:SetOperation(c37279508.spop)
	c:RegisterEffect(e2)
end
-- 设置这张卡的XYZ编号为37。
aux.xyz_number[37279508]=37
-- ①效果的发动代价：检查能否从这张卡上取除1个超量素材作为代价，若能则实际取除1个超量素材。
function c37279508.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动条件：确认对方场上有表侧表示怪兽存在（攻击宣言时必然存在），满足才能发动。
function c37279508.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少1只表侧表示怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- ①效果处理：获取对方场上的全部表侧表示怪兽，给它们各赋予攻击力下降1000的效果，直到回合结束时适用。
function c37279508.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上全部表侧表示怪兽，存入组g。
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 对方场上的全部怪兽的攻击力直到回合结束时下降1000。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- ②效果的发动条件：这张卡因战斗或效果被破坏并送去墓地。
function c37279508.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 特殊召唤的过滤条件：目标是墓地中能够被当前效果特殊召唤的怪兽。
function c37279508.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的Target函数：定义可选择的合法对象（这张卡以外的自己墓地可特殊召唤的怪兽），并检查发动条件（有空格且存在合法对象）。
function c37279508.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37279508.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 检查自己场上是否有空余的怪兽区域，以进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查自己墓地是否存在满足特殊召唤条件且不是这张卡本身的怪兽。
		and Duel.IsExistingTarget(c37279508.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家显示选择提示信息，提示选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地的可特殊召唤怪兽中选择1只（不能选这张卡）作为对象。
	local g=Duel.SelectTarget(tp,c37279508.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁处理信息，声明这次处理将进行1只怪兽的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：取回选择的特殊召唤对象，如果仍在墓地且与效果关联，将其表侧攻击表示特殊召唤到自己场上。
function c37279508.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取②效果选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
