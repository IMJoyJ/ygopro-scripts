--レフトハンド・シャーク
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡在手卡·墓地存在，自己场上有「右手鲨」存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡从墓地的特殊召唤成功的场合发动。这张卡的等级变成4星。
-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。
-- ●这张卡不会被效果破坏。
function c47840168.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，自己场上有「右手鲨」存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(47840168,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,47840168)
	e1:SetCondition(c47840168.spcon)
	e1:SetTarget(c47840168.sptg)
	e1:SetOperation(c47840168.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地的特殊召唤成功的场合发动。这张卡的等级变成4星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(47840168,1))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c47840168.lvcon)
	e2:SetOperation(c47840168.lvop)
	c:RegisterEffect(e2)
	-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。●这张卡不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetProperty(EFFECT_FLAG_EVENT_PLAYER)
	e3:SetCountLimit(1,47840169)
	e3:SetCondition(c47840168.effcon)
	e3:SetOperation(c47840168.effop)
	c:RegisterEffect(e3)
end
-- 检查卡是否为表侧表示且卡号为11845050（「右手鲨」），用于筛选场上是否存在右手鲨。
function c47840168.cfilter(c)
	return c:IsFaceup() and c:IsCode(11845050)
end
-- ①的发动条件：自己场上有表侧表示的「右手鲨」存在。
function c47840168.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体检查自己场上是否存在至少1张满足条件的「右手鲨」。
	return Duel.IsExistingMatchingCard(c47840168.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①的发动条件确认：自己主要怪兽区有空位，且这张卡可以被特殊召唤。
function c47840168.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空余位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本次效果处理将特殊召唤这张卡，供连锁处理及其他效果检测参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其表侧特殊召唤；若特殊召唤成功，给这张卡附加“从场上离开时除外”的持续效果。
function c47840168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果关联，且特殊召唤是否成功（返回非0表示成功）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡从墓地的特殊召唤成功的场合发动。这张卡的等级变成4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- ②的发动条件：这张卡从墓地特殊召唤成功（特殊召唤的位置为墓地）。
function c47840168.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- ②效果处理：若这张卡仍与效果关联且表侧表示，则赋予其等级变为4的效果。
function c47840168.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- ②：这张卡从墓地的特殊召唤成功的场合发动。这张卡的等级变成4星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 筛选素材中不是水属性的怪兽，用于判断超量素材是否全部为水属性。
function c47840168.cfilter2(c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- ③的发动条件：这张卡作为超量素材从场上离开，且素材中没有非水属性怪兽，同时素材全部为超量怪兽。
function c47840168.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetReasonCard():GetMaterial()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and not mg:IsExists(c47840168.cfilter2,1,nil)
		and mg:FilterCount(Card.IsXyzType,nil,TYPE_MONSTER)==mg:GetCount()
end
-- ③效果处理：给超量召唤成功的怪兽附加“不会被效果破坏”的永续效果；若该怪兽不是效果怪兽，则将其变为效果怪兽以正确显示效果。
function c47840168.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。●这张卡不会被效果破坏。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(47840168,2))  --"「左手鲨」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- ③：只用包含场上的这张卡的水属性怪兽为素材作超量召唤的怪兽得到以下效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
