--夢魔鏡の天魔－ネイロス
-- 效果：
-- 属性不同的「梦魔镜」怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
-- ②：这张卡以外的自己场上的怪兽被解放的场合，以场上1张卡为对象才能发动。那张卡破坏。
-- ③：这张卡被对方破坏的场合才能发动。从自己墓地选「梦魔镜的天魔-涅伊洛斯」以外的1只「梦魔镜」怪兽特殊召唤。
function c35187185.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加融合召唤手续：需要2只满足ffilter条件的怪兽作为融合素材，即2只属性各不相同的「梦魔镜」怪兽。
	aux.AddFusionProcFunRep(c,c35187185.ffilter,2,true)
	-- ①：只要这张卡在怪兽区域存在，这张卡的属性也当作「暗」使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_ADD_ATTRIBUTE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(ATTRIBUTE_DARK)
	c:RegisterEffect(e1)
	-- 这个卡名的②③的效果1回合各能使用1次。②：这张卡以外的自己场上的怪兽被解放的场合，以场上1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35187185,0))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_RELEASE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,35187185)
	e2:SetCondition(c35187185.descon)
	e2:SetTarget(c35187185.destg)
	e2:SetOperation(c35187185.desop)
	c:RegisterEffect(e2)
	-- ③：这张卡被对方破坏的场合才能发动。从自己墓地选「梦魔镜的天魔-涅伊洛斯」以外的1只「梦魔镜」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35187185,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,35187186)
	e3:SetCondition(c35187185.spcon)
	e3:SetTarget(c35187185.sptg)
	e3:SetOperation(c35187185.spop)
	c:RegisterEffect(e3)
end
-- 融合素材过滤器：判断怪兽是否为「梦魔镜」怪兽，并且与已选素材属性不同，以保证融合素材为属性不同的「梦魔镜」怪兽。
function c35187185.ffilter(c,fc,sub,mg,sg)
	return c:IsFusionSetCard(0x131) and (not sg or not sg:IsExists(Card.IsFusionAttribute,1,c,c:GetFusionAttribute()))
end
-- 被解放怪兽的过滤器：要求该怪兽之前处于主要怪兽区域且控制者是这张卡的控制者，用于判断是否为本卡以外的自己场上的怪兽被解放。
function c35187185.cfilter(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
-- ②效果的发动条件：当被解放的怪兽中存在至少1只满足cfilter的怪兽时，即这张卡以外的自己场上的怪兽被解放，允许发动。
function c35187185.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c35187185.cfilter,1,e:GetHandler(),tp)
end
-- ②效果发动时选择场上1张卡为对象，并设置破坏的操作信息。包括对象合法性检查、选择提示、选择目标、设置破坏信息。
function c35187185.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 若尚未检查（chk==0），则确认场上是否存在至少1张可以成为效果对象的卡，作为发动前提。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 给玩家发送请选择要破坏的卡的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张卡作为②效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置本连锁的操作信息：将破坏所选对象（1张卡）。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若其仍与该效果关联，则将其破坏。
function c35187185.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时所选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果为理由破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ③效果的特殊召唤对象过滤器：墓地中的「梦魔镜」怪兽，卡名不是「梦魔镜的天魔-涅伊洛斯」，且可以被当前特殊召唤。
function c35187185.spfilter(c,e,tp)
	return c:IsSetCard(0x131) and not c:IsCode(35187185) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动条件：这张卡被对方破坏（其上一次控制者为tp，且破坏者是对方玩家）。
function c35187185.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousControler(tp) and rp==1-tp
end
-- ③效果的发动目标判定：自己场上有可用怪兽区域，且墓地存在符合条件的「梦魔镜」怪兽。
function c35187185.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上是否有可用的主要怪兽区域（空位）作为发动③的前提。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时确认墓地是否存在至少1只符合特殊召唤条件的「梦魔镜」怪兽（且不是本卡）。
		and Duel.IsExistingMatchingCard(c35187185.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从墓地特殊召唤1只怪兽到自己场上。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ③效果处理：若仍存在空位，则从墓地选1只符合条件的「梦魔镜」怪兽特殊召唤。
function c35187185.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上没有可用主怪兽区域，则不处理特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送请选择要特殊召唤的卡的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只满足条件且不受王家长眠之谷影响的「梦魔镜」怪兽（排除本卡）作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c35187185.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧攻击表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
