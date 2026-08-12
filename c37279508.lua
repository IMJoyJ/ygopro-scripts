--No.37 希望織竜スパイダー・シャーク
-- 效果：
-- 水属性4星怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时，把这张卡1个超量素材取除才能发动。对方场上的全部怪兽的攻击力直到回合结束时下降1000。
-- ②：这张卡被战斗·效果破坏送去墓地时，以这张卡以外的自己墓地1只怪兽为对象才能发动。那只怪兽特殊召唤。
function c37279508.initial_effect(c)
	-- 为卡片添加水属性4星怪兽叠放条件的XYZ召唤手续
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
-- 设置该卡的XYZ编号为37
aux.xyz_number[37279508]=37
-- 检查并移除自身1个超量素材作为发动代价
function c37279508.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否对方场上存在表侧表示的怪兽
function c37279508.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否对方场上存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 将对方场上所有表侧表示怪兽的攻击力下降1000
function c37279508.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 为对方场上的怪兽设置攻击力下降1000的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-1000)
		tc:RegisterEffect(e1)
		tc=g:GetNext()
	end
end
-- 判断该卡是否因战斗或效果破坏而进入墓地
function c37279508.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 判断墓地中的怪兽是否可以特殊召唤
function c37279508.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置特殊召唤效果的目标选择条件
function c37279508.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c37279508.spfilter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 判断己方场上是否有足够的特殊召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断己方墓地是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c37279508.spfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为特殊召唤对象
	local g=Duel.SelectTarget(tp,c37279508.spfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置连锁操作信息，表明将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行特殊召唤操作
function c37279508.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
