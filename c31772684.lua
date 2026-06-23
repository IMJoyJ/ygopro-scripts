--ヴェンデット・レヴナント
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡被对方破坏送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。
-- ●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
function c31772684.initial_effect(c)
	-- ①：这张卡被对方破坏送去墓地的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31772684,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(c31772684.spcon)
	e1:SetTarget(c31772684.sptg)
	e1:SetOperation(c31772684.spop)
	c:RegisterEffect(e1)
	-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,31772684)
	e2:SetCondition(c31772684.mtcon)
	e2:SetOperation(c31772684.mtop)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的发动条件：卡片因战斗或效果被破坏、且破坏者为对方、且破坏前控制者为自身。
function c31772684.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- 判断①效果的发动是否满足基本条件：场上是否有空位、自身是否能特殊召唤。
function c31772684.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理信息：将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身特殊召唤到场上，并设置其离场时除外的效果。
function c31772684.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否能特殊召唤到场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 设置①效果处理后，自身离场时除外的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断是否满足②效果的发动条件：卡片因仪式召唤成为素材、且作为素材的怪兽中存在复仇死者卡组的怪兽。
function c31772684.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- ②效果的处理：为使用该卡仪式召唤的怪兽添加1回合1次除外对方场上特殊召唤怪兽的效果。
function c31772684.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- 为仪式召唤的怪兽添加1回合1次除外对方场上特殊召唤怪兽的效果。
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(31772684,1))  --"对方怪兽除外（复仇死者·归来者）"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c31772684.rmtg)
	e1:SetOperation(c31772684.rmop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		-- 若仪式召唤的怪兽不具有效果类型，则为其添加效果类型。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31772684,2))  --"「复仇死者·归来者」效果适用中"
end
-- 判断目标怪兽是否为特殊召唤、且能除外。
function c31772684.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
-- ②效果的处理：选择对方场上1只特殊召唤的怪兽作为对象。
function c31772684.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31772684.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 判断对方场上是否存在满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c31772684.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择对方场上1只满足条件的怪兽作为对象。
	local g=Duel.SelectTarget(tp,c31772684.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理信息：将目标怪兽除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- ②效果的处理：将对方场上1只特殊召唤的怪兽除外。
function c31772684.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
