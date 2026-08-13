--呪眼の眷属 カトブレパス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1张「咒眼」魔法·陷阱卡为对象才能发动。直到下个回合的结束时，那张卡只有1次不会被对方的效果破坏。
-- ②：这张卡在墓地存在，自己场上有「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c45955628.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1张「咒眼」魔法·陷阱卡为对象才能发动。直到下个回合的结束时，那张卡只有1次不会被对方的效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45955628,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,45955628)
	e1:SetTarget(c45955628.indtg)
	e1:SetOperation(c45955628.indop)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上有「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽存在的场合才能发动。这张卡特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45955628,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45955629)
	e2:SetCondition(c45955628.spcon)
	e2:SetTarget(c45955628.sptg)
	e2:SetOperation(c45955628.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断某张卡是否表侧表示且属于「咒眼」魔法·陷阱卡，用于筛选①效果可选的对象。
function c45955628.tgfilter(c)
	return c:IsSetCard(0x129) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsFaceup()
end
-- ①效果的发动时点处理：校验对象合法性、检查是否有可指定的对象，并提示玩家选择1张自己场上的表侧表示「咒眼」魔法·陷阱卡作为对象。
function c45955628.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and c45955628.tgfilter(chkc) end
	-- 效果发动合法性检查：确认自己场上存在至少1张符合条件（表侧表示「咒眼」魔法·陷阱卡）的卡可以作为对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c45955628.tgfilter,tp,LOCATION_ONFIELD,0,1,nil) end
	-- 向玩家发送选择提示，显示“请选择效果的对象”消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让发动者从自己场上选择1张符合条件的「咒眼」魔法·陷阱卡，将其登记为效果对象（取对象效果）。
	Duel.SelectTarget(tp,c45955628.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
end
-- ①效果处理：取得对象卡，若对象仍与效果关联，则给对象卡赋予“1次不会被对方的效果破坏”的耐性效果，持续到下个回合结束。
function c45955628.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中已被选择为对象的卡（即自己场上被指定的「咒眼」魔法·陷阱卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 直到下个回合的结束时，那张卡只有1次不会被对方的效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCountLimit(1)
		e1:SetValue(c45955628.indval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
	end
end
-- 判断破坏是否来自对方的效果：若破坏原因包含效果破坏且破坏方为对方，则返回真，使该次破坏被无效。
function c45955628.indval(e,re,r,rp)
	return bit.band(r,REASON_EFFECT)~=0 and rp~=e:GetHandlerPlayer()
end
-- 过滤函数，用于检查一张怪兽是否为“表侧表示且除「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽”，作为②效果的发动条件。
function c45955628.spcfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x129) and not c:IsCode(45955628)
end
-- ②效果的发动条件判定：自己场上存在至少1只满足条件（表侧表示且除「咒眼之眷属 卡托布莱帕斯」以外的「咒眼」怪兽）时，才可在墓地发动。
function c45955628.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己怪兽区存在至少1只符合条件的「咒眼」怪兽，以满足②效果的发动条件。
	return Duel.IsExistingMatchingCard(c45955628.spcfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②效果的发动目标检查：确认墓地的这张卡可以特殊召唤且自己场上存在可用怪兽区空格，以允许发动。
function c45955628.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 合法性检查：确认自己场上有可用的主要怪兽区空格，以保证特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 登记本效果的操作信息：将特殊召唤这张卡这一操作通知系统（目标为这张卡，数量1）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②效果处理：若这张卡仍与效果关联，则将其表侧表示特殊召唤到己方场上；若召唤成功，则赋予其“从场上离开的场合除外”的效果。
function c45955628.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍在墓地且效果有效，然后将其从墓地表侧表示特殊召唤；成功后才继续设置离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
