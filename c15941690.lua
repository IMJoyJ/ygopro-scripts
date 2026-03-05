--先史遺産クリスタル・ボーン
-- 效果：
-- 对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，可以从自己的手卡·墓地选「先史遗产 水晶骨架」以外的1只名字带有「先史遗产」的怪兽特殊召唤。
function c15941690.initial_effect(c)
	-- 效果原文内容：对方场上有怪兽存在，自己场上没有怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c15941690.hspcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 效果原文内容：这个方法特殊召唤成功时，可以从自己的手卡·墓地选「先史遗产 水晶骨架」以外的1只名字带有「先史遗产」的怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(15941690,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c15941690.spcon)
	e2:SetTarget(c15941690.sptg)
	e2:SetOperation(c15941690.spop)
	c:RegisterEffect(e2)
end
-- 规则层面操作：判断特殊召唤条件是否满足，包括自己场上没有怪兽、对方场上存在怪兽、且自己场上存在可用召唤区域。
function c15941690.hspcon(e,c)
	if c==nil then return true end
	-- 规则层面操作：检查自己场上是否没有怪兽。
	return Duel.GetFieldGroupCount(c:GetControler(),LOCATION_MZONE,0)==0
		-- 规则层面操作：检查对方场上是否存在怪兽。
		and	Duel.GetFieldGroupCount(c:GetControler(),0,LOCATION_MZONE)>0
		-- 规则层面操作：检查自己场上是否有可用召唤区域。
		and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 规则层面操作：判断该卡是否通过特殊召唤方式（非通常召唤）成功召唤。
function c15941690.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 规则层面操作：过滤满足条件的「先史遗产」怪兽，排除自身并确保可特殊召唤。
function c15941690.filter(c,e,tp)
	return c:IsSetCard(0x70) and not c:IsCode(15941690) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面操作：判断是否满足特殊召唤目标的条件，包括场上存在可用区域和满足条件的怪兽。
function c15941690.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面操作：检查场上是否存在可用召唤区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面操作：检查手卡或墓地中是否存在满足条件的怪兽。
		and Duel.IsExistingMatchingCard(c15941690.filter,tp,LOCATION_GRAVE+LOCATION_HAND,0,1,nil,e,tp) end
	-- 规则层面操作：设置连锁操作信息，表示将要特殊召唤1只怪兽，目标为手卡或墓地。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_HAND)
end
-- 规则层面操作：执行特殊召唤流程，包括检查召唤区域、提示选择、选择目标怪兽并进行特殊召唤。
function c15941690.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面操作：检查场上是否还有可用召唤区域，若无则直接返回。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 规则层面操作：向玩家提示选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面操作：从手卡或墓地中选择满足条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c15941690.filter),tp,LOCATION_GRAVE+LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 规则层面操作：将选中的怪兽特殊召唤到场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
