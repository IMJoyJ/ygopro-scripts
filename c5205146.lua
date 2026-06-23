--無限起動ロードローラー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，机械族·地属性怪兽被解放的场合或者被表侧表示除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。
-- ●只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽变成守备表示，守备力下降1000。
function c5205146.initial_effect(c)
	-- 为卡片注册一个监听送入墓地事件的单次持续效果，用于记录卡片是否已从场上离开进入墓地的状态。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ①：这张卡在手卡·墓地存在，机械族·地属性怪兽被解放的场合或者被表侧表示除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5205146,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_RELEASE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,5205146)
	e1:SetLabelObject(e0)
	e1:SetCondition(c5205146.spcon)
	e1:SetTarget(c5205146.sptg)
	e1:SetOperation(c5205146.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e2)
	-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。●只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽变成守备表示，守备力下降1000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL+EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_SET_POSITION)
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(c5205146.matcheck)
	e3:SetTarget(c5205146.postg)
	e3:SetValue(POS_FACEUP_DEFENSE)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(-1000)
	c:RegisterEffect(e4)
end
-- 用于筛选满足条件的被解放或除外的怪兽，确保其为地属性且种族为机械族，并排除非正面表示的除外状态。
function c5205146.cfilter(c,se)
	if c:IsLocation(LOCATION_REMOVED)
		and not (c:IsReason(REASON_RELEASE) or c:IsFaceup()) then return false end
	if not (se==nil or c:GetReasonEffect()~=se) then return false end
	if c:IsPreviousLocation(LOCATION_MZONE) then
		return c:GetPreviousAttributeOnField()&ATTRIBUTE_EARTH>0 and c:GetPreviousRaceOnField()&RACE_MACHINE>0
	else
		return c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_MACHINE)
	end
end
-- 判断是否有符合条件的怪兽被解放或除外，同时确保该卡本身不在触发列表中以避免自触发。
function c5205146.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c5205146.cfilter,1,nil,se) and not eg:IsContains(c)
end
-- 检查是否满足特殊召唤条件，包括场上是否有空位以及该卡是否可以被特殊召唤。
function c5205146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测场上是否有足够的怪兽区域用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表示将要进行特殊召唤操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作，并为特殊召唤的卡片注册一个效果，使其在离开场上时被除外。
function c5205146.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否与效果相关联且成功特殊召唤，若成功则为其添加离开场上的除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 创建并注册一个效果，使特殊召唤的此卡在从场上离开时自动被移至除外区。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 检查持有此卡作为超量素材的怪兽是否原本种族为机械族。
function c5205146.matcheck(e)
	return e:GetHandler():GetOriginalRace()==RACE_MACHINE
end
-- 判断目标怪兽是否处于正面表示状态。
function c5205146.postg(e,c)
	return c:IsFaceup()
end
