--デスピアの大導劇神
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：融合·同调·超量·连接怪兽特殊召唤的场合，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
-- ②：手卡·场上的这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。这张卡特殊召唤。
function c99456344.initial_effect(c)
	-- ①：融合·同调·超量·连接怪兽特殊召唤的场合，以场上1只效果怪兽为对象才能发动。那只怪兽的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99456344,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,99456344)
	e1:SetCondition(c99456344.discon)
	e1:SetTarget(c99456344.distg)
	e1:SetOperation(c99456344.disop)
	c:RegisterEffect(e1)
	-- ②：手卡·场上的这张卡成为融合召唤的素材，被送去墓地的场合或者被除外的场合才能发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99456344,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,99456345)
	e2:SetCondition(c99456344.spcon)
	e2:SetTarget(c99456344.sptg)
	e2:SetOperation(c99456344.spop)
	c:RegisterEffect(e2)
end
-- 筛选场上表侧表示的融合、同调、超量、连接怪兽的过滤函数
function c99456344.cfilter(c)
	return c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ+TYPE_LINK) and c:IsFaceup()
end
-- 判断特殊召唤成功的怪兽中是否存在表侧表示的融合、同调、超量、连接怪兽
function c99456344.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c99456344.cfilter,1,nil)
end
-- 效果①的发动靶向和操作信息设置，选择场上1只表侧表示的可无效的效果怪兽作为对象
function c99456344.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对指向的卡片进行对象有效性检查（须在场且是表侧可无效的效果怪兽）
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and aux.NegateEffectMonsterFilter(chkc) end
	-- 检查场上是否存在可以作为效果无效化对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给当前玩家发送选择要无效的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择场上1只表侧表示且可无效的效果怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,aux.NegateEffectMonsterFilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，表示此效果将要使选中的怪兽效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- 效果①的操作处理，使选中的怪兽的效果直到回合结束时无效
function c99456344.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果无效对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e) then
		-- 无效化与目标怪兽相关的连锁，若目标变里侧则重置
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那只怪兽的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 那只怪兽的效果直到回合结束时无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 检查这张卡是否从手卡·场上作为融合素材送去墓地或被除外
function c99456344.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_HAND+LOCATION_ONFIELD)
		and c:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 检查场上是否有怪兽格且该卡是否能够被特殊召唤
function c99456344.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查怪兽区域是否还有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果②的操作处理，将这张卡在自己场上表侧表示特殊召唤
function c99456344.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
