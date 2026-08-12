--重機貨列車デリックレーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有机械族·地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的原本的攻击力·守备力变成一半。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
function c13647631.initial_effect(c)
	-- ①：自己场上有机械族·地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的原本的攻击力·守备力变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(13647631,0))  --"从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,13647631)
	e1:SetCondition(c13647631.spcon)
	e1:SetTarget(c13647631.sptg)
	e1:SetOperation(c13647631.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(13647631,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCondition(c13647631.descon)
	e3:SetTarget(c13647631.destg)
	e3:SetOperation(c13647631.desop)
	c:RegisterEffect(e3)
end
-- 过滤器函数，用于判断场上是否存在我方的机械族地属性怪兽
function c13647631.spfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- 条件函数，判断是否满足①效果的发动条件
function c13647631.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13647631.spfilter,1,nil,tp)
end
-- 目标设置函数，设置①效果的特殊召唤目标
function c13647631.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查阶段，判断是否满足特殊召唤的条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，确定特殊召唤的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行①效果的特殊召唤操作
function c13647631.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤步骤，将卡特殊召唤到场上
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetBaseAttack()
		local def=c:GetBaseDefense()
		-- 设置自身原本攻击力为一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK)
		e1:SetValue(math.ceil(atk/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_BASE_DEFENSE)
		e2:SetValue(math.ceil(def/2))
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
-- 条件函数，判断是否满足②效果的发动条件
function c13647631.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- 目标设置函数，设置②效果的破坏目标
function c13647631.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 检查阶段，判断是否满足破坏目标的选择条件
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	-- 选择对方场上的1张卡作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，确定破坏的卡和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数，执行②效果的破坏操作
function c13647631.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏目标
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
