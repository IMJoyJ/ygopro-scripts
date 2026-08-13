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
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，以自己场上1只炎属性怪兽为对象才能发动。那只怪兽破坏，这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- ①效果的处理函数：这张卡召唤成功时，为手牌或场上的「熔岩」怪兽附加1次额外通常召唤机会，并登记本回合已使用标志，效果持续到回合结束。
function c30303854.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方已存在本回合使用过①效果的标志，则直接结束处理，防止该效果重复适用。
	if Duel.GetFlagEffect(tp,30303854)~=0 then return end
	-- ①：这个回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只「熔岩」怪兽召唤。②：这张卡在墓地存在的场合，以自己场上1只炎属性怪兽为对象才能发动。那只怪兽破坏，这张卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(30303854,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 将该额外召唤次数效果的对象限定为属于「熔岩」系列的怪兽（0x39是「熔岩」的系列编号）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x39))
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把该额外召唤次数效果注册给当前玩家tp，使己方在本回合内获得额外的「熔岩」怪兽召唤次数。
	Duel.RegisterEffect(e1,tp)
	-- 为当前玩家tp注册一个到回合结束阶段重置的标志，标记①效果本回合已经使用，避免同一回合再次触发。
	Duel.RegisterFlagEffect(tp,30303854,RESET_PHASE+PHASE_END,0,1)
end
-- 定义②效果的选对象筛选函数：对象必须是己方场上表侧表示的炎属性怪兽，且将其破坏后己方仍有可用的怪兽区域。
function c30303854.cfilter(c,tp)
	-- 筛选条件：对象表侧表示、炎属性，并且在对象离开场上后己方怪兽区有空位（用于特殊召唤熔岩弓手）。
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_FIRE) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果发动时的处理：连锁确认对象时校验对象是否在己方怪兽区且满足筛选条件；发动时还要确认存在符合条件的对象且熔岩弓手可被特殊召唤。
function c30303854.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c30303854.cfilter(chkc,tp) end
	local c=e:GetHandler()
	-- 效果发动时检查己方怪兽区是否存在1只符合条件的炎属性怪兽，以及墓地中的熔岩弓手是否满足特殊召唤条件。
	if chk==0 then return Duel.IsExistingTarget(c30303854.cfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 弹出选择提示框，提示玩家选择1只自己要破坏的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从己方怪兽区选择1只符合条件的炎属性怪兽，并将其登记为效果对象。
	local g=Duel.SelectTarget(tp,c30303854.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 向系统登记本次连锁将进行破坏处理，对象为已选择的怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 向系统登记本次连锁将进行特殊召唤处理，对象为墓地的熔岩弓手，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理时：先取得对象怪兽，若其仍与效果关联则将其破坏；若破坏成功且熔岩弓手仍与效果关联，则将其表侧守备表示特殊召唤，并给其附加一个不可被无效的离场除外效果。
function c30303854.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得②效果发动时选择的1只对象怪兽。
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 确认对象怪兽仍与当前效果关联后，用效果将其破坏，并检查是否破坏成功。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		-- 确认熔岩弓手仍与当前效果关联后，将其以表侧守备表示特殊召唤到己方场上，并确认是否成功。
		and c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		c:RegisterEffect(e1,true)
	end
	-- 这个回合，自己不是炎属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c30303854.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册给当前玩家tp：本回合内不能特殊召唤非炎属性怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定条件：被特殊召唤的怪兽不是炎属性时禁止特殊召唤。
function c30303854.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_FIRE)
end
