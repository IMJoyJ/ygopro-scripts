--夜刀蛇巳
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c20295753.initial_effect(c)
	-- 创建效果1，用于处理卡名效果，为诱发选发效果，触发条件为送去墓地，且只能发动1次
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20295753,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,20295753)
	e1:SetCondition(c20295753.spcon)
	e1:SetTarget(c20295753.sptg)
	e1:SetOperation(c20295753.spop)
	c:RegisterEffect(e1)
end
-- 效果条件：这张卡被效果送去墓地的场合
function c20295753.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 效果处理：将此卡特殊召唤，设置操作信息为特殊召唤类别
function c20295753.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件：场上存在空位且此卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁操作信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：检查是否有空位并特殊召唤此卡，若成功则注册离场除外效果
function c20295753.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否还有空位，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 判断此卡是否仍存在于场上且能被特殊召唤，若满足则执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 此效果特殊召唤的这张卡从场上离开的场合除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
