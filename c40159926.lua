--ミラー・リゾネーター
-- 效果：
-- 「镜子共鸣者」的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。这张卡在这个回合作为同调素材的场合，当作和作为对象的怪兽的原本等级相同等级使用。
function c40159926.initial_effect(c)
	-- ①：这张卡在手卡·墓地存在，从额外卡组特殊召唤的怪兽只有对方场上才存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40159926,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,40159926)
	e1:SetCondition(c40159926.condition)
	e1:SetTarget(c40159926.target)
	e1:SetOperation(c40159926.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以对方场上1只表侧表示怪兽为对象才能发动。这张卡在这个回合作为同调素材的场合，当作和作为对象的怪兽的原本等级相同等级使用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(40159926,1))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c40159926.lvtg)
	e2:SetOperation(c40159926.lvop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断怪兽是否从额外卡组召唤
function c40159926.cfilter(c)
	return c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果条件：检查是否存在从额外卡组召唤的怪兽，且对方场上不存在从额外卡组召唤的怪兽
function c40159926.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在从额外卡组召唤的怪兽
	return Duel.IsExistingMatchingCard(c40159926.cfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查对方场上不存在从额外卡组召唤的怪兽
		and not Duel.IsExistingMatchingCard(c40159926.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 效果目标：判断是否满足特殊召唤条件
function c40159926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的空间进行特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：将卡片特殊召唤到场上，并设置其离场时的去向
function c40159926.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置效果：当此卡离开场时，将其移至除外区
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 过滤函数，用于判断怪兽是否为表侧表示且等级大于0
function c40159926.lvfilter(c)
	return c:IsFaceup() and c:GetOriginalLevel()>0
end
-- 效果目标：选择对方场上一只表侧表示的怪兽作为对象
function c40159926.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c40159926.lvfilter(chkc) end
	-- 检查是否存在对方场上的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(c40159926.lvfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上的表侧表示怪兽作为对象
	Duel.SelectTarget(tp,c40159926.lvfilter,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：将此卡的同调等级设定为对象怪兽的原本等级
function c40159926.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 设置效果：使此卡在作为同调素材时，等级等同于目标怪兽的原本等级
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SYNCHRO_LEVEL)
		e1:SetValue(tc:GetOriginalLevel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		c:SetHint(CHINT_NUMBER,tc:GetOriginalLevel())
	end
end
