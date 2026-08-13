--ギアギアーノ Mk－Ⅲ
-- 效果：
-- 这张卡用名字带有「齿轮齿轮」的卡的效果特殊召唤成功时，可以从自己的手卡·墓地选「齿轮齿轮人 Mk-3」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「齿轮齿轮人 Mk-3」的效果1回合只能使用1次，这个效果发动的回合，自己不能把名字带有「齿轮齿轮」的怪兽以外的怪兽特殊召唤。
function c45286019.initial_effect(c)
	-- 对应效果原文：这张卡用名字带有「齿轮齿轮」的卡的效果特殊召唤成功时，可以从自己的手卡·墓地选「齿轮齿轮人 Mk-3」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。「齿轮齿轮人 Mk-3」的效果1回合只能使用1次，这个效果发动的回合，自己不能把名字带有「齿轮齿轮」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45286019,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,45286019)
	e1:SetCondition(c45286019.spcon)
	e1:SetCost(c45286019.spcost)
	e1:SetTarget(c45286019.sptg)
	e1:SetOperation(c45286019.spop)
	c:RegisterEffect(e1)
	-- 注册一个特殊召唤活动计数器，记录本回合内玩家特殊召唤非「齿轮齿轮」怪兽的情况，用于“这个效果发动的回合，自己不能把名字带有「齿轮齿轮」的怪兽以外的怪兽特殊召唤”的自肃检查。
	Duel.AddCustomActivityCounter(45286019,ACTIVITY_SPSUMMON,c45286019.counterfilter)
end
-- 计数器过滤函数：若被特殊召唤的怪兽是「齿轮齿轮」系列则返回 true，否则返回 false；返回 false 时会触发计数器计数（表示进行了违规特殊召唤）。
function c45286019.counterfilter(c)
	return c:IsSetCard(0x72)
end
-- 效果发动条件：判断这张卡是否是通过名字带有「齿轮齿轮」的卡的效果特殊召唤成功的场合。
function c45286019.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSpecialSummonSetCard(0x72)
end
-- 效果发动代价：检查本回合尚未特殊召唤过非「齿轮齿轮」怪兽，然后给自己施加直到结束阶段不能特殊召唤非「齿轮齿轮」怪兽的自肃效果。
function c45286019.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在代价检查阶段（chk==0）确认本回合的特殊召唤活动计数为0，即玩家本回合还没有特殊召唤过非「齿轮齿轮」怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(45286019,tp,ACTIVITY_SPSUMMON)==0 end
	-- 对应效果原文：可以从自己的手卡·墓地选「齿轮齿轮人 Mk-3」以外的1只名字带有「齿轮齿轮」的怪兽表侧守备表示特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果发动的回合，自己不能把名字带有「齿轮齿轮」的怪兽以外的怪兽特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c45286019.splimit)
	-- 将创建的自肃效果 e1 以玩家 tp 为对象注册到场上，从此刻起持续限制 tp 不能特殊召唤非「齿轮齿轮」怪兽，直到结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的判定条件：当特殊召唤的怪兽不是「齿轮齿轮」系列时，禁止该特殊召唤（返回 true 表示不能特殊召唤）。
function c45286019.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x72)
end
-- 检索/选择条件：选择「齿轮齿轮人 Mk-3」以外的、名字带有「齿轮齿轮」的怪兽，且该怪兽可以被效果以表侧守备表示特殊召唤。
function c45286019.filter(c,e,tp)
	return c:IsSetCard(0x72) and not c:IsCode(45286019) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动的目标阶段：确认己方主要怪兽区域有空位，并且手卡·墓地存在符合条件的可特殊召唤的「齿轮齿轮」怪兽。
function c45286019.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区域是否存在可用空格，作为效果能否发动的条件之一。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡·墓地是否存在至少1只满足 c45286019.filter 条件的「齿轮齿轮」怪兽，作为效果能否发动的条件之一。
		and Duel.IsExistingMatchingCard(c45286019.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向连锁处理登记本次操作将进行特殊召唤，登记为从手卡·墓地特殊召唤1只怪兽（对象数量1，目标玩家为tp），供其他卡/效果在发动时参考。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 效果处理：在仍有空位的情况下，从手卡·墓地选择1只符合条件的「齿轮齿轮」怪兽，以表侧守备表示特殊召唤，并给其附加效果无效化的状态（EFFECT_DISABLE 与 EFFECT_DISABLE_EFFECT），直到其离场。
function c45286019.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理前再次确认己方主要怪兽区域仍有空位，若没有则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡（HINTMSG_SPSUMMON，显示“请选择要特殊召唤的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·墓地中选择1只符合条件的「齿轮齿轮」怪兽，使用王家长眠之谷过滤器处理，避免从墓地选择时受王家长眠之谷的干扰。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45286019.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以表侧守备表示特殊召唤到己方场上（不检查召唤条件与苏生限制，因为已经用 IsCanBeSpecialSummoned 验证过）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		-- 对应效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对应效果原文：这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
end
