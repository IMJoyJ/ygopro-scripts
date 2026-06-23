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
-- 设置该卡不能被作为同调素材，除非是兽战士族怪兽。
function c1662004.synlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_BEASTWARRIOR)
end
-- 筛选墓地符合条件的炎属性3星怪兽（守备力200以下且可特殊召唤）。
function c1662004.spfilter(c,e,tp)
	return c:IsDefenseBelow(200) and c:IsAttribute(ATTRIBUTE_FIRE) and c:IsLevel(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 处理效果的发动条件判断，检查是否有满足条件的怪兽可特殊召唤。
function c1662004.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c1662004.spfilter(chkc,e,tp) end
	-- 判断场上是否有足够的空间进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断自己墓地是否存在符合条件的怪兽。
		and Duel.IsExistingTarget(c1662004.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择目标怪兽并设置为效果对象。
	local g=Duel.SelectTarget(tp,c1662004.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果操作信息，表明将要特殊召唤怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动后操作，特殊召唤目标怪兽并设置不能攻击效果。
function c1662004.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽有效且属性为炎，并执行特殊召唤。
	if tc:IsRelateToEffect(e) and tc:IsAttribute(ATTRIBUTE_FIRE) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 设置一个永续效果，使非兽战士族怪兽不能攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(c1662004.atktg)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 将该不能攻击效果注册到场上。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 定义不能攻击效果的目标筛选函数，排除兽战士族怪兽。
function c1662004.atktg(e,c)
	return not c:IsRace(RACE_BEASTWARRIOR)
end
