--重機貨列車デリックレーン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有机械族·地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的原本的攻击力·守备力变成一半。
-- ②：超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合，以对方场上1张卡为对象才能发动。那张卡破坏。
function c13647631.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：自己场上有机械族·地属性怪兽召唤·特殊召唤的场合才能发动。这张卡从手卡特殊召唤。这个效果特殊召唤的这张卡的原本的攻击力·守备力变成一半。
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
-- 过滤函数：判断怪兽是否是表侧表示、由发动玩家控制、机械族且地属性，用于确认是否出现‘自己场上的机械族·地属性怪兽’被召唤/特殊召唤。
function c13647631.spfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
end
-- ①效果的发动条件：本次召唤或特殊召唤成功的怪兽组中存在至少1只满足spfilter条件的怪兽，即自己场上有机械族·地属性怪兽被召唤/特殊召唤。
function c13647631.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c13647631.spfilter,1,nil,tp)
end
-- 效果发动时合法性检查：自己的主要怪兽区有空位，且这张卡能够被当前效果特殊召唤，满足这两个条件才允许发动。
function c13647631.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区域是否有空位，作为能否进行特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记操作信息：本连锁将把这张卡特殊召唤，类别为特殊召唤，数量1，供其他卡片响应判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：确认这张卡仍与效果关联后，将其表侧表示特殊召唤；若特殊召唤成功，则生成持续效果将其原本攻击力、守备力减半；最后完成特殊召唤流程。
function c13647631.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 分步特殊召唤：尝试将这张卡以表侧表示特殊召唤到自己场上，成功后再处理攻击力守备力减半效果。
	if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		local atk=c:GetBaseAttack()
		local def=c:GetBaseDefense()
		-- 这个效果特殊召唤的这张卡的原本的攻击力·守备力变成一半。
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
	-- 完成分步特殊召唤处理，使本次特殊召唤正式生效，并触发相应召唤成功时点。
	Duel.SpecialSummonComplete()
end
-- ②效果的发动条件：这张卡作为超量素材，为发动超量怪兽的效果而被取除并作为代价送去墓地，且该效果确为超量怪兽效果的发动（对应‘超量素材的这张卡为让超量怪兽的效果发动而被取除送去墓地的场合’）。
function c13647631.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_XYZ)
		and c:IsPreviousLocation(LOCATION_OVERLAY)
end
-- ②效果的目标处理：若指定对象则须是对方场上存在的卡；发动时需确认对方场上有可选对象，然后提示玩家选择1张对方场上的卡，登记为取对象目标，并设置破坏的操作信息。
function c13647631.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() end
	-- 合法性检查：确认对方场上有至少1张卡可以作为效果对象，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 发送选择提示，提示玩家接下来要选择被破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1张卡作为效果对象，并通过Duel.SelectTarget将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：本效果将破坏所选对象，破坏分类为CATEGORY_DESTROY，数量1，供连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：获取所选的目标卡，若目标仍与该效果保持关联，则将其破坏。
function c13647631.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中本效果选择的目标卡（唯一对象），即要破坏的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将目标卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
