--異次元の哨戒機
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被除外的回合的结束阶段才能发动。选自己的手卡·场上·墓地1张卡除外，这张卡攻击表示特殊召唤。
function c75991479.initial_effect(c)
	-- 这张卡被除外的回合
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_REMOVE)
	e0:SetOperation(c75991479.rmop)
	c:RegisterEffect(e0)
	-- ①：这张卡被除外的回合的结束阶段才能发动。选自己的手卡·场上·墓地1张卡除外，这张卡攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetRange(LOCATION_REMOVED)
	e1:SetCountLimit(1,75991479)
	e1:SetCondition(c75991479.spcon)
	e1:SetTarget(c75991479.sptg)
	e1:SetOperation(c75991479.spop)
	c:RegisterEffect(e1)
end
-- 在自身被除外时，注册一个在回合结束时重置的Flag，用于标记该卡在此回合被除外过
function c75991479.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(75991479,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 检查自身是否带有被除外回合的Flag标记，作为效果发动的条件
function c75991479.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(75991479)~=0
end
-- 过滤可以被除外，且除外后能腾出足够的怪兽区域用于特殊召唤的卡片
function c75991479.rmfilter(c,tp)
	-- 判断卡片是否可以被除外，且该卡离开场上后（如果是场上的卡）是否能留出至少1个怪兽区域
	return c:IsAbleToRemove() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果发动的目标检查：手卡、场上、墓地存在可除外的卡，且自身可以攻击表示特殊召唤
function c75991479.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查手卡、场上、墓地是否存在至少1张满足除外条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c75991479.rmfilter,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil,tp)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置除外操作的信息：预计从手卡、场上或墓地除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE)
	-- 设置特殊召唤操作的信息：预计特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：选择并除外1张卡，然后将自身攻击表示特殊召唤
function c75991479.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 向玩家发送提示信息，要求选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从手卡、场上或墓地选择1张满足除外条件且不受王家之谷影响的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c75991479.rmfilter),tp,LOCATION_HAND+LOCATION_ONFIELD+LOCATION_GRAVE,0,1,1,nil,tp)
	local tc=g:GetFirst()
	-- 如果成功除外了选择的卡，且自身仍与效果相关联，则继续处理
	if tc and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and c:IsRelateToEffect(e) then
		-- 将自身以表侧攻击表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
