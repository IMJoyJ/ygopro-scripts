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
-- 过滤函数，检查场上是否存在「右手鲨」
function c47840168.cfilter(c)
	return c:IsFaceup() and c:IsCode(11845050)
end
-- 判断是否满足①效果的发动条件：自己场上有「右手鲨」存在
function c47840168.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家来看的自己的位置是否存在至少1张满足过滤条件f并且不等于ex的卡
	return Duel.IsExistingMatchingCard(c47840168.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 设置特殊召唤的处理目标和数量
function c47840168.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，用于确定要处理的效果分类
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行①效果的处理：将此卡特殊召唤到场上，并设置其离场时除外的效果
function c47840168.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否能被特殊召唤并进行特殊召唤操作
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 设置特殊召唤的这张卡从场上离开时被除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 判断此卡是否是从墓地特殊召唤成功
function c47840168.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonLocation(LOCATION_GRAVE)
end
-- 将此卡的等级变为4星
function c47840168.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 设置此卡等级改变效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(4)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤函数，检查是否存在非水属性怪兽
function c47840168.cfilter2(c)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 判断是否满足③效果的发动条件：作为超量素材的怪兽全部为水属性且为怪兽类型
function c47840168.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetReasonCard():GetMaterial()
	return r==REASON_XYZ and c:IsPreviousLocation(LOCATION_ONFIELD) and not mg:IsExists(c47840168.cfilter2,1,nil)
		and mg:FilterCount(Card.IsXyzType,nil,TYPE_MONSTER)==mg:GetCount()
end
-- 执行③效果的处理：使使用此卡为素材的超量怪兽不会被效果破坏，并为其添加效果怪兽类型
function c47840168.effop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	-- 设置使用此卡为素材的超量怪兽不会被效果破坏的效果
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(47840168,2))  --"「左手鲨」效果适用中"
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若使用此卡为素材的超量怪兽不是效果怪兽，则为其添加效果怪兽类型
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
