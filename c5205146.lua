--無限起動ロードローラー
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，机械族·地属性怪兽被解放的场合或者被表侧表示除外的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果。
-- ●只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽变成守备表示，守备力下降1000。
function c5205146.initial_effect(c)
	-- 为这张卡注册“已在墓地”的标记检测效果，用于正确判定其存在于手卡·墓地的状态，并防止同一连锁中判定异常。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡在手卡·墓地存在，机械族·地属性怪兽被解放的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
	-- ②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果：●只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽变成守备表示。
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
-- 过滤事件怪兽：若该怪兽位于除外区，且既不是因解放而除外也不是表侧表示除外，则排除，确保只响应符合条件的机械族·地属性怪兽的解放/表侧表示除外。
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
-- ①效果的发动条件：检查触发事件中是否存在至少一只满足cfilter条件的机械族·地属性怪兽，且事件不包含这张卡自身，满足时条件成立。
function c5205146.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c5205146.cfilter,1,nil,se) and not eg:IsContains(c)
end
-- ①效果发动时的合法性检查：确认这张卡能够被特殊召唤，且我方主要怪兽区域有空余空格。
function c5205146.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 确认我方主要怪兽区域存在可用的空格，作为效果发动的必要条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本连锁的操作信息，声明将对这张卡进行特殊召唤，以便后续效果能够正确检测此操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其特殊召唤；成功后被特殊召唤的这张卡离场时改为除外。
function c5205146.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与效果关联，并执行特殊召唤；只有特殊召唤成功（返回值不为0）才继续附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外；②：持有这张卡作为素材中的原本种族是机械族的超量怪兽得到以下效果：●只要这张卡在怪兽区域存在，对方场上的表侧表示怪兽变成守备表示，守备力下降1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的条件判断：只有持有这张卡作为超量素材的怪兽的原本种族为机械族时，才赋予其后续的场地压制效果。
function c5205146.matcheck(e)
	return e:GetHandler():GetOriginalRace()==RACE_MACHINE
end
-- ②效果的适用对象过滤器：选择对方场上表侧表示存在的怪兽作为变更表示形式和降低守备力的对象。
function c5205146.postg(e,c)
	return c:IsFaceup()
end
