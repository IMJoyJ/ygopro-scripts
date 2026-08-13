--ラヴァルバル・エクスロード
-- 效果：
-- 调整＋调整以外的炎属性怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：手卡·场上的怪兽的效果由对方发动时才能发动。那只怪兽破坏，给与对方1000伤害。
-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己墓地选同调怪兽以外的最多3只守备力200的炎属性怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c12018201.initial_effect(c)
	-- 为这张卡添加同调召唤手续：必须以1只调整怪兽＋1只以上调整以外的炎属性怪兽作为素材。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(Card.IsAttribute,ATTRIBUTE_FIRE),1)
	c:EnableReviveLimit()
	-- ①：手卡·场上的怪兽的效果由对方发动时才能发动。那只怪兽破坏，给与对方1000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,12018201)
	e1:SetCondition(c12018201.descon)
	e1:SetTarget(c12018201.destg)
	e1:SetOperation(c12018201.desop)
	c:RegisterEffect(e1)
	-- ②：同调召唤的这张卡被对方破坏的场合才能发动。从自己墓地选同调怪兽以外的最多3只守备力200的炎属性怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCountLimit(1,12018202)
	e2:SetCondition(c12018201.spcon)
	e2:SetTarget(c12018201.sptg)
	e2:SetOperation(c12018201.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：对方发动怪兽效果，且该效果发动位置在手卡或场上，发动怪兽仍与效果关联，且发动玩家为对方。
function c12018201.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁（对方发动的效果）的发生位置，用于判断该效果是否在手卡或场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return ep==1-tp and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsRelateToEffect(re) and (LOCATION_HAND+LOCATION_ONFIELD)&loc~=0
end
-- 效果①的发动目标判定：确认对方发动的那只怪兽可被破坏；然后设置破坏对象为那只怪兽，并记录对对方造成1000点伤害的信息。
function c12018201.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置破坏操作信息：将对方发动的怪兽作为破坏对象，数量为1，破坏后送墓。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	-- 设置伤害对象玩家为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值参数为1000，供后续伤害处理使用。
	Duel.SetTargetParam(1000)
	-- 设置伤害操作信息：对对方玩家造成1000点伤害，目标玩家为对方，参数1000。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1000)
end
-- 效果①处理：若对方发动的怪兽仍与效果关联，则将其破坏；若破坏成功，则对之前记录的伤害对象造成伤害。
function c12018201.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方发动的怪兽是否仍有效果关联，若是则将其破坏，并检查是否破坏成功。
	if re:GetHandler():IsRelateToEffect(re) and Duel.Destroy(eg,REASON_EFFECT)~=0 then
		-- 从当前连锁读取之前设置的伤害对象玩家和伤害数值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对玩家p造成d点效果伤害（给与对方1000伤害的处理）。
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
-- 效果②的发动条件：同调召唤的这张卡原本由我方控制，在怪兽区被对方破坏的场合，可以发动。
function c12018201.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 墓地特殊召唤对象的筛选条件：不是同调怪兽、守备力为200、炎属性，且可以被我方以表侧守备表示特殊召唤。
function c12018201.spfilter(c,e,tp)
	return not c:IsType(TYPE_SYNCHRO) and c:IsDefense(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动目标判定：我方怪兽区有空位，且墓地存在至少1只满足特殊召唤条件的怪兽；满足则设置从墓地特殊召唤的操作信息。
function c12018201.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时确认我方怪兽区是否有可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认墓地是否存在至少1只满足条件（非同步、守备力200、炎属性、可特殊召唤）的怪兽。
		and Duel.IsExistingMatchingCard(c12018201.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置特殊召唤操作信息：预计从我方墓地特殊召唤1只怪兽（实际数量可在1~3之间，故不指定具体卡片）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②处理：计算可用怪兽区空格数并限制为最多3只；若青眼精灵龙的效果适用中则最多1只；选择墓地中符合条件的怪兽，以表侧守备表示逐个特殊召唤，并使其效果无效化，最后完成特殊召唤。
function c12018201.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取我方当前可用怪兽区数量，作为本次可特殊召唤的最大数量上限。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>3 then ft=3 end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 弹出选择提示，要求我方选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从我方墓地选择1至ft只满足条件的怪兽（不取对象，在效果处理时选择），返回选择的怪兽组。
	local g=Duel.SelectMatchingCard(tp,c12018201.spfilter,tp,LOCATION_GRAVE,0,1,ft,nil,e,tp)
	-- 遍历所有选中的怪兽，逐个进行处理。
	for tc in aux.Next(g) do
		-- 将当前怪兽以表侧守备表示特殊召唤到我方场上（特殊召唤分解步骤，不检查召唤条件和苏生限制）。
		Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
	end
	-- 完成所有特殊召唤步骤，触发特殊召唤成功时点。
	Duel.SpecialSummonComplete()
end
