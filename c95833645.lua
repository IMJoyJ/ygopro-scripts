--マグマ・ドラゴン
-- 效果：
-- 「岩浆龙」的效果1回合只能使用1次，这个效果发动的回合，自己不是幻龙族怪兽不能特殊召唤。
-- ①：这张卡特殊召唤成功时，以「岩浆龙」以外的自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c95833645.initial_effect(c)
	-- ①：这张卡特殊召唤成功时，以「岩浆龙」以外的自己墓地1只幻龙族怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
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
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合中是否特殊召唤过非幻龙族怪兽。
	Duel.AddCustomActivityCounter(95833645,ACTIVITY_SPSUMMON,c95833645.counterfilter)
end
-- 计数器的过滤函数，用于判定特殊召唤的怪兽是否为幻龙族。
function c95833645.counterfilter(c)
	return c:IsRace(RACE_WYRM) and c:IsFaceup()
end
-- 效果发动的Cost函数，检查本回合是否特殊召唤过非幻龙族怪兽，并适用本回合不能特殊召唤非幻龙族怪兽的限制。
function c95833645.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果前，确认玩家在本回合内没有特殊召唤过非幻龙族怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(95833645,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不是幻龙族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c95833645.splimit)
	-- 将不能特殊召唤非幻龙族怪兽的限制效果注册给发动效果的玩家。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽种族不能是幻龙族以外的种族。
function c95833645.splimit(e,c)
	return c:GetRace()~=RACE_WYRM
end
-- 过滤自己墓地中除「岩浆龙」以外、可以守备表示特殊召唤的幻龙族怪兽。
function c95833645.filter(c,e,tp)
	return c:IsRace(RACE_WYRM) and not c:IsCode(95833645) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的Target（对象选择）函数，确认怪兽区域空位并选择墓地的目标怪兽。
function c95833645.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c95833645.filter(chkc,e,tp) end
	-- 检查玩家场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地是否存在满足条件的、可作为效果对象的怪兽。
		and Duel.IsExistingTarget(c95833645.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只满足条件的幻龙族怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c95833645.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，表明此效果包含将选中的1张卡特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的Operation（操作）函数，将对象怪兽守备表示特殊召唤并使其效果无效化。
function c95833645.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果相关联，并尝试将其以表侧守备表示特殊召唤到场上。
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
	-- 完成特殊召唤的后续处理，使怪兽正式登场。
	Duel.SpecialSummonComplete()
end
