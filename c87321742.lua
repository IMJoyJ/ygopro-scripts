--RR－ストラングル・レイニアス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有暗属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
-- ②：自己场上有用暗属性超量怪兽在作为超量素材中的超量怪兽存在的场合，以自己墓地1只4星以下的「急袭猛禽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c87321742.initial_effect(c)
	-- ①：自己场上有暗属性怪兽存在的场合才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87321742,1))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,87321742)
	e1:SetCondition(c87321742.sscon)
	e1:SetTarget(c87321742.sstg)
	e1:SetOperation(c87321742.ssop)
	c:RegisterEffect(e1)
	-- ②：自己场上有用暗属性超量怪兽在作为超量素材中的超量怪兽存在的场合，以自己墓地1只4星以下的「急袭猛禽」怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(87321742,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,87321743)
	e2:SetCondition(c87321742.spcon)
	e2:SetTarget(c87321742.sptg)
	e2:SetOperation(c87321742.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：场上表侧表示的暗属性怪兽
function c87321742.ssfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup()
end
-- ①号效果的发动条件函数
function c87321742.sscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的暗属性怪兽
	return Duel.IsExistingMatchingCard(c87321742.ssfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ①号效果的发动准备与合法性检测函数
function c87321742.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①号效果的处理函数
function c87321742.ssop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个效果的发动后，直到回合结束时自己不是暗属性怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c87321742.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤暗属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤非暗属性的怪兽
function c87321742.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：墓地中4星以下的「急袭猛禽」怪兽且可以特殊召唤
function c87321742.tgfilter(c,e,tp)
	return c:IsSetCard(0xba) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤条件：暗属性超量怪兽
function c87321742.mfilter(c)
	return c:IsType(TYPE_XYZ) and c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤条件：场上表侧表示的、拥有暗属性超量怪兽作为超量素材的超量怪兽
function c87321742.ffilter(c)
	return c:IsType(TYPE_XYZ) and c:GetOverlayGroup():IsExists(c87321742.mfilter,1,nil) and c:IsFaceup()
end
-- ②号效果的发动条件函数
function c87321742.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在满足条件的超量怪兽
	return Duel.IsExistingMatchingCard(c87321742.ffilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②号效果的发动准备、对象选择与合法性检测函数
function c87321742.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c87321742.tgfilter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件的「急袭猛禽」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87321742.tgfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 且自己场上有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只4星以下的「急袭猛禽」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c87321742.tgfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁处理中的操作信息：特殊召唤目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②号效果的处理函数
function c87321742.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍符合效果条件，则将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的最终处理
	Duel.SpecialSummonComplete()
end
