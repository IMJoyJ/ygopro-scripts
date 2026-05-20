--命の水
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上没有怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这张卡的发动后，直到回合结束时自己不能把这个效果特殊召唤的场上的怪兽以外的怪兽的效果发动。
function c7133305.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上没有怪兽存在的场合，以自己墓地1只怪兽为对象才能发动。那只怪兽攻击表示特殊召唤。这张卡的发动后，直到回合结束时自己不能把这个效果特殊召唤的场上的怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,7133305+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c7133305.condition)
	e1:SetTarget(c7133305.target)
	e1:SetOperation(c7133305.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自己场上没有怪兽存在
function c7133305.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上的怪兽数量是否为0
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 过滤条件：可以以表侧攻击表示特殊召唤的怪兽
function c7133305.filter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 效果发动时的对象选择与合法性检查
function c7133305.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c7133305.filter(chkc,e,tp) end
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在至少1只满足特殊召唤条件的怪兽
		and Duel.IsExistingTarget(c7133305.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家发送选择特殊召唤对象的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c7133305.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息为特殊召唤选定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：特殊召唤目标怪兽，并注册限制玩家发动其他怪兽效果的全局效果
function c7133305.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧攻击表示特殊召唤
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK)
		tc:RegisterFlagEffect(7133305,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,0)
	end
	if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	-- 这张卡的发动后，直到回合结束时自己不能把这个效果特殊召唤的场上的怪兽以外的怪兽的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c7133305.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 向玩家注册该限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：判定发动的效果是否为未带有特殊召唤标记的怪兽的效果
function c7133305.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and rc:GetFlagEffect(7133305)==0
end
