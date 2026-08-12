--蘇生の蜂玉
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己墓地1只「蜂军」怪兽为对象才能发动。那只怪兽特殊召唤。
-- ②：把墓地的这张卡除外，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽直到下个回合的结束时不会被战斗·效果破坏。
function c89226534.initial_effect(c)
	-- ①：以自己墓地1只「蜂军」怪兽为对象才能发动。那只怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(89226534,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c89226534.target)
	e1:SetOperation(c89226534.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己场上1只昆虫族怪兽为对象才能发动。那只怪兽直到下个回合的结束时不会被战斗·效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(89226534,1))  --"破坏抗性"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,89226534)
	-- 将墓地的这张卡除外作为发动代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c89226534.indtg)
	e2:SetOperation(c89226534.indop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己墓地可以特殊召唤的「蜂军」怪兽
function c89226534.filter(c,e,tp)
	return c:IsSetCard(0x12f) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与目标选择
function c89226534.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c89226534.filter(chkc,e,tp) end
	-- 检测自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检测自己墓地是否存在可以特殊召唤的「蜂军」怪兽
		and Duel.IsExistingTarget(c89226534.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只「蜂军」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c89226534.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果①的效果处理（特殊召唤）
function c89226534.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：自己场上表侧表示且未适用过此效果的昆虫族怪兽
function c89226534.indfilter(c)
	return c:GetFlagEffect(89226534)==0 and c:IsRace(RACE_INSECT) and c:IsFaceup()
end
-- 效果②的发动准备与目标选择
function c89226534.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c89226534.indfilter(chkc) end
	-- 检测自己场上是否存在符合条件的昆虫族怪兽
	if chk==0 then return Duel.IsExistingTarget(c89226534.indfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只昆虫族怪兽作为效果对象
	Duel.SelectTarget(tp,c89226534.indfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果②的效果处理（赋予破坏抗性）
function c89226534.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	if tc:IsRelateToEffect(e) then
		-- 不会被效果破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		tc:RegisterEffect(e2)
		tc:RegisterFlagEffect(89226534,RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET+RESET_PHASE+PHASE_END,0,0)
	end
end
