--最期の同調
-- 效果：
-- ①：以自己场上1只3星怪兽为对象才能发动。那1只同名怪兽从自己的手卡·墓地特殊召唤。这个效果特殊召唤的怪兽的效果无效化。作为对象的怪兽在这个回合的结束阶段破坏。
function c23269426.initial_effect(c)
	-- ①：以自己场上1只3星怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c23269426.target)
	e1:SetOperation(c23269426.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断手卡或墓地是否存在同名且可特殊召唤的怪兽
function c23269426.spfilter(c,e,tp,code)
	return c:IsCode(code) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数，用于判断场上是否存在满足条件的3星怪兽
function c23269426.filter(c,e,tp)
	return c:IsFaceup() and c:IsLevel(3)
		-- 检查场上是否存在满足条件的3星怪兽
		and Duel.IsExistingMatchingCard(c23269426.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp,c:GetCode())
end
-- 效果处理时的条件判断，检查是否满足发动条件
function c23269426.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c23269426.filter(chkc,e,tp) end
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在满足条件的3星怪兽
		and Duel.IsExistingTarget(c23269426.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的场上怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c23269426.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表示将要从手卡或墓地特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 效果处理函数，执行特殊召唤和后续处理
function c23269426.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否有足够的召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 获取当前效果的对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或墓地选择满足条件的同名怪兽
	local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c23269426.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp,tc:GetCode())
	-- 执行特殊召唤步骤并设置效果无效化
	if sg:GetCount()>0 and Duel.SpecialSummonStep(sg:GetFirst(),0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		sg:GetFirst():RegisterEffect(e2,true)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
	-- 设置在结束阶段破坏对象怪兽的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetOperation(c23269426.desop)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	tc:RegisterEffect(e1)
end
-- 破坏对象怪兽的处理函数
function c23269426.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对象怪兽破坏
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
