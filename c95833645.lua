--マグマ・ドラゴン
-- 效果：
-- 「岩浆龙」的效果1回合只能使用1次，这个效果发动的回合，自己不是幻龙族怪兽不能特殊召唤。
-- ①：这张卡特殊召唤成功时，以「岩浆龙」以外的自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c95833645.initial_effect(c)
	-- 「岩浆龙」的效果1回合只能使用1次，这个效果发动的回合，自己不是幻龙族怪兽不能特殊召唤。①：这张卡特殊召唤成功时，以「岩浆龙」以外的自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCountLimit(1,95833645)
	e1:SetCost(c95833645.cost)
	e1:SetTarget(c95833645.target)
	e1:SetOperation(c95833645.operation)
	c:RegisterEffect(e1)
	-- 添加自定义活动计数器，用于监测特殊召唤过非幻龙族怪兽的次数
	Duel.AddCustomActivityCounter(95833645,ACTIVITY_SPSUMMON,c95833645.counterfilter)
end
-- 自定义活动计数器过滤条件：特殊召唤的怪兽是表侧表示的幻龙族怪兽
function c95833645.counterfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup()
end
-- 效果发动的代价与限制：检查本回合自己是否曾特殊召唤过非幻龙族怪兽，并注册本回合不能特殊召唤非幻龙族怪兽的限制效果
function c95833645.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断发动条件：检查本回合自己是否未特殊召唤过非幻龙族怪兽
	if chk==0 then return Duel.GetCustomActivityCount(95833645,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是幻龙族怪兽不能特殊召唤。以「岩浆龙」以外的自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95833645.splimit)
	-- 为玩家注册本回合不能特殊召唤非幻龙族怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制过滤：限制不能特殊召唤非幻龙族怪兽的怪兽
function c95833645.splimit(e,c)
	return c:GetRace()~=RACE_WYRM
end
-- 过滤自己墓地中除「岩浆龙」以外、可以守备表示特殊召唤的幻龙族怪兽
function c95833645.filter(c,e,tp)
	return c:IsRace(RACE_WYRM) and not c:IsCode(95833645) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果的发动条件检查与对象选择：判断自己场上是否有空位以及墓地中是否存在符合条件的幻龙族怪兽
function c95833645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c95833645.filter(chkc,e,tp) end
	-- 判断发动条件：检查自己场上是否有可用于特殊召唤的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在符合条件的、可以作为效果对象的怪兽
		and Duel.IsExistingTarget(c95833645.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择并锁定自己墓地中1只符合条件的幻龙族怪兽作为特殊召唤的对象
	local g=Duel.SelectTarget(tp,c95833645.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设定效果处理信息：本次效果处理包含将选定的1张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将作为特殊召唤对象的怪兽守备表示特殊召唤，并将其效果无效化
function c95833645.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被选为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否仍与效果相关，如果是则执行守备表示特殊召唤的步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
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
	-- 结束特殊召唤的流程，确认并完成所有特殊召唤步骤
	Duel.SpecialSummonComplete()
end
