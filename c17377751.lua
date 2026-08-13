--BF－煌星のグラム
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这张卡用同调召唤才能从额外卡组特殊召唤。这张卡同调召唤成功时，可以从手卡把1只调整以外的4星以下的名字带有「黑羽」的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c17377751.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整素材为任意调整，非调整素材为任意非调整怪兽，至少1只，对应「调整＋调整以外的怪兽1只以上」。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：这张卡用同调召唤才能从额外卡组特殊召唤。这里创建不可无效、不可复制、仅单卡范围的同调召唤条件限制效果。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SINGLE_RANGE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetRange(LOCATION_EXTRA)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该特殊召唤条件的判定函数为aux.synlimit，使这张卡只有通过同调召唤方式才能特殊召唤，其他特殊召唤方式均被禁止。
	e1:SetValue(aux.synlimit)
	c:RegisterEffect(e1)
	-- 对应效果原文：这张卡同调召唤成功时，可以从手卡把1只调整以外的4星以下的名字带有「黑羽」的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这里创建诱发选发效果，登记同调召唤成功时的特殊召唤效果。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17377751,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c17377751.spcon)
	e2:SetTarget(c17377751.sptg)
	e2:SetOperation(c17377751.spop)
	c:RegisterEffect(e2)
end
-- 发动条件判定：这张卡是成功进行同调召唤时，才允许发动此效果。
function c17377751.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤条件：选择手牌中满足「调整以外、4星以下、名字带有「黑羽」、且可以被特殊召唤」的怪兽。
function c17377751.filter(c,e,tp)
	return not c:IsType(TYPE_TUNER) and c:IsLevelBelow(4) and c:IsSetCard(0x33) and c:IsCanBeSpecialSummoned(e,0,tp,false,true)
end
-- 发动目标的检测：确认己方主要怪兽区有空位，且手牌存在符合条件的怪兽。
function c17377751.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查己方主要怪兽区是否有可用空位，没有空位则不能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在1只以上满足c17377751.filter条件的「黑羽」怪兽。
		and Duel.IsExistingMatchingCard(c17377751.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理涉及特殊召唤，预计从手牌特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手牌选择1只符合条件的「黑羽」怪兽进行特殊召唤，并对其适用效果无效化的处理。
function c17377751.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认己方主要怪兽区仍有空位，若无空位则效果处理不执行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选出1只满足c17377751.filter条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,c17377751.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 以特殊召唤手续将该怪兽表侧表示特殊召唤（不检查召唤条件、无视苏生限制），并准备附加无效化效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,true,POS_FACEUP) then
		-- 对应效果原文：这个效果特殊召唤的怪兽的效果无效化。给该怪兽附加EFFECT_DISABLE，使其效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 对应效果原文：这个效果特殊召唤的怪兽的效果无效化。继续给该怪兽附加EFFECT_DISABLE_EFFECT，使其效果持续无效化，并完成特殊召唤。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤处理，将之前通过SpecialSummonStep特殊召唤的怪兽正式登场，并触发召唤成功的时点。
	Duel.SpecialSummonComplete()
end
