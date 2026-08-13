--夜刀蛇巳
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c20295753.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡被效果送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 发动条件判定：检查该卡是否因效果（REASON_EFFECT）而送去墓地，即满足“被效果送去墓地”的发动条件。
function c20295753.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 发动时的目标处理：确认满足发动条件后，检查场上是否有空位且该卡能否被特殊召唤，并设置本次连锁的特殊召唤操作信息。
function c20295753.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 效果发动的合法性检查：自己主要怪兽区域有空位，且这张卡可以被特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本次效果将执行特殊召唤，对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理时的操作：若场上仍有可用怪兽区域，则将这张卡特殊召唤；特殊召唤成功时，给它附加“从场上离开时改为除外”的永续效果（不可被无效）。
function c20295753.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理中的检查：若自己场上没有可用的主要怪兽区域，则特殊召唤失败，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认这张卡仍与本效果关联（没有被中途离场导致关系重置），并尝试以表侧攻击表示特殊召唤；若特殊召唤成功，则继续执行后续除外置换效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 对应原文：“这个效果特殊召唤的这张卡从场上离开的场合除外。”
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
