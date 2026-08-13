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
	-- 这个卡名的②的效果1回合只能使用1次。②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_EVENT_PLAYER)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,31772684)
	e2:SetCondition(c31772684.mtcon)
	e2:SetOperation(c31772684.mtop)
	c:RegisterEffect(e2)
end
-- 判断①效果的发动条件：这张卡被对方（战斗或效果）破坏并送去墓地，且破坏前由自己控制。
function c31772684.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_DESTROY) and c:IsReason(REASON_BATTLE+REASON_EFFECT)
		and rp==1-tp and c:IsPreviousControler(tp)
end
-- ①效果发动时的条件检查：自己场上存在可用的主要怪兽区空格，且这张卡自身可以被特殊召唤。
function c31772684.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区空格（数量大于0）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本次连锁的操作信息：效果处理时会将这张卡特殊召唤，供星尘龙等卡进行发动判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与发动效果关联，则将其表侧特殊召唤；若召唤成功，再给它附加离场时改为除外的效果。
function c31772684.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与效果关联后，将其以表侧表示特殊召唤到自己场上，并判断是否召唤成功。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- 判断②效果触发条件：这张卡作为场上怪兽被用于仪式召唤，且仪式召唤出的怪兽是「复仇死者」系列（0x106）。
function c31772684.mtcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_RITUAL and e:GetHandler():IsPreviousLocation(LOCATION_MZONE)
		and eg:IsExists(Card.IsSetCard,1,nil,0x106)
end
-- ②效果处理：从仪式素材中选出仪式召唤的「复仇死者」怪兽，给它赋予‘1回合1次，取对象除外对方场上1只特殊召唤的怪兽，对方回合也能发动’的诱发即时效果；若它不是效果怪兽则补上效果类型，并添加适用中提示。
function c31772684.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=eg:Filter(Card.IsSetCard,nil,0x106)
	local rc=g:GetFirst()
	if not rc then return end
	-- ●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
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
		-- ②：使用场上的这张卡仪式召唤的「复仇死者」怪兽得到以下效果。●1回合1次，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽除外。这个效果在对方回合也能发动。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ADD_TYPE)
		e3:SetValue(TYPE_EFFECT)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		rc:RegisterEffect(e3,true)
	end
	rc:RegisterFlagEffect(0,RESET_EVENT+RESETS_STANDARD,EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(31772684,2))  --"「复仇死者·归来者」效果适用中"
end
-- 定义选择对象的过滤条件：对方场上的怪兽必须是特殊召唤成功的，且可以被除外。
function c31772684.rmfilter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToRemove()
end
-- 该取对象效果的目标选择：从对方场上选择1只特殊召唤且可除外的怪兽作为对象，并设置除外处理的操作信息。
function c31772684.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c31772684.rmfilter(chkc) and chkc:IsControler(1-tp) end
	-- 效果发动合法性检查：确认对方场上存在至少1只特殊召唤且可除外的怪兽可供选择。
	if chk==0 then return Duel.IsExistingTarget(c31772684.rmfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示‘请选择要除外的卡’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择1张符合条件的对方怪兽作为效果对象，并与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,c31772684.rmfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：效果处理时将除外所选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果处理：取回发动时选择的对象，若它仍与效果关联，则将其表侧表示除外。
function c31772684.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果发动时选择的对象卡（此效果为取1个对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以表侧表示形式通过效果将对象怪兽除外。
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
