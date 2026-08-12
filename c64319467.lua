--ダブルフィン・シャーク
-- 效果：
-- 这张卡召唤成功时，可以从自己墓地选择1只3星或者4星的鱼族·水属性怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。
function c64319467.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己墓地选择1只3星或者4星的鱼族·水属性怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(64319467,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCost(c64319467.spcost)
	e1:SetTarget(c64319467.sptg)
	e1:SetOperation(c64319467.spop)
	c:RegisterEffect(e1)
	-- 注册一个自定义活动计数器，用于检测玩家在当前回合内是否特殊召唤过水属性以外的怪兽
	Duel.AddCustomActivityCounter(64319467,ACTIVITY_SPSUMMON,c64319467.counterfilter)
end
-- 计数器过滤函数：判定特殊召唤的怪兽是否为水属性
function c64319467.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动的Cost函数：检查本回合是否特殊召唤过水属性以外的怪兽，并注册不能特殊召唤水属性以外怪兽的誓约效果
function c64319467.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在Cost检查阶段，确认本回合在此效果发动前没有特殊召唤过水属性以外的怪兽
	if chk==0 then return Duel.GetCustomActivityCount(64319467,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个效果发动的回合，自己不能把水属性以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c64319467.splimit)
	-- 将不能特殊召唤水属性以外怪兽的限制效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：判定非水属性的怪兽不能被特殊召唤
function c64319467.splimit(e,c)
	return c:GetAttribute()~=ATTRIBUTE_WATER
end
-- 过滤函数：筛选自己墓地中满足等级为3或4、鱼族、水属性且能以表侧守备表示特殊召唤的怪兽
function c64319467.filter(c,e,tp)
	return c:IsLevel(3,4) and c:IsRace(RACE_FISH) and c:IsAttribute(ATTRIBUTE_WATER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的Target（目标选择）函数：进行合法性检查并选择墓地的目标怪兽
function c64319467.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c64319467.filter(chkc,e,tp) end
	-- 在Target检查阶段，确认自己场上有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 确认自己墓地中存在至少1只满足条件的怪兽
		and Duel.IsExistingTarget(c64319467.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 在屏幕上提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家选择自己墓地中1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c64319467.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理的操作信息，表明此效果包含特殊召唤该目标怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理的Operation（操作）函数：将选择的怪兽特殊召唤并使其效果无效化
function c64319467.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在Target阶段选择的效果对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认目标怪兽仍符合效果条件，并将其以表侧守备表示特殊召唤到场上（单步处理）
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理，刷新场上状态
	Duel.SpecialSummonComplete()
end
