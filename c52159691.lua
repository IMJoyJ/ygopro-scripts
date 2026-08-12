--レイダーズ・ウィング
-- 效果：
-- 这个卡名在规则上也当作「幻影骑士团」卡、「急袭猛禽」卡使用。这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在的场合，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：持有这张卡作为素材中的原本属性是暗属性的超量怪兽得到以下效果。
-- ●这张卡不会成为对方的效果的对象。
function c52159691.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在的场合，把自己场上的暗属性超量怪兽1个超量素材取除才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(52159691,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,52159691)
	e1:SetCost(c52159691.spcost)
	e1:SetTarget(c52159691.sptg)
	e1:SetOperation(c52159691.spop)
	c:RegisterEffect(e1)
	-- ②：持有这张卡作为素材中的原本属性是暗属性的超量怪兽得到以下效果。●这张卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetCondition(c52159691.xmatcon)
	-- 设置效果值为过滤函数aux.tgoval，用于判断是否不会成为对方效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在正面表示、暗属性、超量类型的怪兽，并且可以取除1个超量素材
function c52159691.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_XYZ)
		and c:CheckRemoveOverlayCard(tp,1,REASON_COST)
end
-- 费用处理函数：检查场上是否存在满足条件的怪兽，若存在则提示选择并取除其1个超量素材
function c52159691.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1张满足cfilter条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c52159691.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向玩家提示“请选择要取除超量素材的怪兽”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DEATTACHFROM)  --"请选择要取除超量素材的怪兽"
	-- 选择满足条件的怪兽并获取该怪兽对象
	local c=Duel.SelectMatchingCard(tp,c52159691.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	c:RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 特殊召唤的发动时点处理函数：判断是否可以将此卡特殊召唤
function c52159691.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查玩家场上是否有足够的位置进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息为特殊召唤类别，用于连锁检测和效果处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤的效果处理函数：若满足条件则将此卡特殊召唤并设置其离场时除外的效果
function c52159691.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否与当前效果相关联且成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 创建一个永续效果，使该卡从场上离开时被除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
end
-- 条件函数：判断此卡作为超量素材时其原本属性是否为暗属性
function c52159691.xmatcon(e)
	return e:GetHandler():GetOriginalAttribute()==ATTRIBUTE_DARK
end
