--炎星師－チョウテン
-- 效果：
-- 这个卡名的效果1回合只能使用1次。把这张卡作为同调素材的场合，不是兽战士族怪兽的同调召唤不能使用。
-- ①：这张卡召唤成功时，以自己墓地1只守备力200以下的炎属性·3星怪兽为对象才能发动。那只炎属性怪兽守备表示特殊召唤。这个效果特殊召唤成功的回合，兽战士族以外的自己怪兽不能攻击。
function c1662004.initial_effect(c)
	-- 把这张卡作为同调素材的场合，不是兽战士族怪兽的同调召唤不能使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_BE_SYNCHRO_MATERIAL)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetValue(c1662004.synlimit)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以自己墓地1只守备力200以下的炎属性·3星怪兽为对象才能发动。那只炎属性怪兽守备表示特殊召唤。这个效果特殊召唤成功的回合，兽战士族以外的自己怪兽不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1662004,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,1662004)
	e2:SetTarget(c1662004.sptg)
	e2:SetOperation(c1662004.spop)
	c:RegisterEffect(e2)
end
-- 作为同调素材限制判定：若候选怪兽不是兽战士族则返回 true，使其不能作为这张卡的同调素材。
function c1662004.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_BEASTWARRIOR)
end
-- 筛选可特殊召唤的墓地怪兽：需守备力200以下、炎属性、3星，且能被当前效果以表侧守备表示特殊召唤。
function c1662004.spfilter(c,e,tp)
	return c:IsDefenseBelow(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件与取对象处理：确认己方主要怪兽区有空位，且墓地存在符合条件的炎属性·3星·守备力200以下的怪兽，然后选择其中1只为对象。
function c1662004.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1662004.spfilter(chkc,e,tp) end
	-- 判断己方主要怪兽区是否有至少1个可用空格，作为特殊召唤的前提条件。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地是否存在1只满足筛选条件且能被当前效果取对象的炎属性·3星·守备力200以下怪兽。
		and Duel.IsExistingTarget(c1662004.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家弹出选择提示消息，提示内容是“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方墓地选择1只符合条件的怪兽作为对象，并登记为该连锁的对象。
	local g=Duel.SelectTarget(tp,c1662004.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将本次操作信息登记为特殊召唤1只怪兽（对象为已选怪兽），供后续效果处理及连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ①效果处理：若对象怪兽仍与效果相关且仍为炎属性，则将其表侧守备特殊召唤；召唤成功后给己方场上非兽战士族怪兽附加本回合不能攻击的制约效果。
function c1662004.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍与效果关联且仍为炎属性，并尝试将其表侧守备特殊召唤；若特殊召唤成功则执行后续处理。
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_FIRE) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 这个效果特殊召唤成功的回合，兽战士族以外的自己怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c1662004.atktg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将不能攻击的制约效果注册到场上，持续至回合结束，影响己方所有非兽战士族怪兽。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 攻击限制的判定：若怪兽不是兽战士族，则返回 true，使其不能进行攻击。
function c1662004.atktg(e,c)
	return not c:IsRace(RACE_BEASTWARRIOR)
end
