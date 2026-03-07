--ラヴァル・アーチャー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡召唤成功的场合发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「熔岩」怪兽召唤。
-- ②：这张卡在墓地存在的场合，以自己场上1只炎属性怪兽为对象才能发动。那只怪兽破坏，这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是炎属性怪兽不能特殊召唤。
function c30303854.initial_effect(c)
	-- ①：这张卡召唤成功的场合发动。这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「熔岩」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(30303854,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(c30303854.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的场合，以自己场上1只炎属性怪兽为对象才能发动。那只怪兽破坏，这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。这个回合，自己不是炎属性怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(30303854,1))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,30303854)
	e2:SetTarget(c30303854.sptg)
	e2:SetOperation(c30303854.spop)
	c:RegisterEffect(e2)
end
-- 在通常召唤成功时发动，为玩家注册一个效果，使该玩家在本回合可以额外进行一次通常召唤，且只能召唤「熔岩」怪兽。
function c30303854.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查该玩家是否已经发动过②效果，若已发动则不重复发动。
	if Duel.GetFlagEffect(tp,30303854)~=0 then return end
	-- 创建一个影响全场的永续效果，使玩家在本回合可以额外进行一次通常召唤，且只能召唤「熔岩」怪兽。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(30303854,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置该效果的目标为「熔岩」属性的怪兽。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x39))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到全局环境，使该效果生效。
	Duel.RegisterEffect(e1,tp)
	-- 为该玩家注册一个标识效果，用于记录②效果是否已发动。
	Duel.RegisterFlagEffect(tp,30303854,RESET_PHASE+PHASE_END,0,1)
end
-- 定义一个过滤函数，用于判断目标怪兽是否为炎属性且场上存在可用怪兽区。
function c30303854.cfilter(c,tp)
	-- 判断目标怪兽是否为表侧表示、炎属性且场上存在可用怪兽区。
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- 设置效果的目标为己方场上的炎属性怪兽，且该怪兽必须满足存在可用怪兽区的条件。
function c30303854.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30303854.cfilter(chkc,tp) end
	local c=e:GetHandler()
	-- 检查是否存在满足条件的炎属性怪兽作为目标，且该卡可以被特殊召唤。
	if chk==0 then return Duel.IsExistingTarget(c30303854.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择满足条件的炎属性怪兽作为目标。
	local g=Duel.SelectTarget(tp,c30303854.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息，表示将要破坏目标怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息，表示将要特殊召唤此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行效果处理，先破坏目标怪兽，再将此卡特殊召唤。
function c30303854.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 判断目标怪兽是否仍然存在于场上且未被无效化，然后将其破坏。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 判断此卡是否仍然存在于场上且未被无效化，然后将其守备表示特殊召唤。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 为特殊召唤的此卡注册一个效果，使其离开场上时被移除。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 为玩家注册一个效果，使该玩家在本回合不能特殊召唤非炎属性怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30303854.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该效果注册到全局环境，使该效果生效。
	Duel.RegisterEffect(e1,tp)
end
-- 定义一个过滤函数，用于判断目标怪兽是否为炎属性。
function c30303854.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
