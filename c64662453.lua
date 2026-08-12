--アイアンコール
-- 效果：
-- ①：自己场上有机械族怪兽存在的场合，以自己墓地1只4星以下的机械族怪兽为对象才能发动。那只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
function c64662453.initial_effect(c)
	-- ①：自己场上有机械族怪兽存在的场合，以自己墓地1只4星以下的机械族怪兽为对象才能发动。那只机械族怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化，结束阶段破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c64662453.condition)
	e1:SetTarget(c64662453.target)
	e1:SetOperation(c64662453.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：场上表侧表示的机械族怪兽
function c64662453.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE)
end
-- 发动条件：自己场上存在机械族怪兽
function c64662453.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的机械族怪兽
	return Duel.IsExistingMatchingCard(c64662453.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：墓地中4星以下且可以特殊召唤的机械族怪兽
function c64662453.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的对象选择与合法性检查
function c64662453.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64662453.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足条件的机械族怪兽
		and Duel.IsExistingTarget(c64662453.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择墓地1只满足条件的机械族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c64662453.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：包含特殊召唤分类，数量为1，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并使其效果无效化，在结束阶段破坏
function c64662453.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否仍有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍存在于墓地且为机械族，则尝试将其以表侧表示特殊召唤
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_MACHINE) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
		-- 结束阶段破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetRange(LOCATION_MZONE)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetOperation(c64662453.desop)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e3:SetCountLimit(1)
		tc:RegisterEffect(e3,true)
	end
	-- 完成特殊召唤的处理
	Duel.SpecialSummonComplete()
end
-- 结束阶段破坏怪兽的延迟效果处理函数
function c64662453.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 因效果破坏该怪兽
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
