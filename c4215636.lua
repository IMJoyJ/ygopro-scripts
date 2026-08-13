--霞の谷の祭壇
-- 效果：
-- 风属性怪兽被卡的效果破坏送去自己墓地时，可以从自己的手卡·卡组把1只风属性·3星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果1回合只能使用1次。
function c4215636.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 风属性怪兽被卡的效果破坏送去自己墓地时，可以从自己的手卡·卡组把1只风属性·3星以下的怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。这个效果1回合只能使用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetDescription(aux.Stringid(4215636,0))  --"特殊召唤"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1)
	e2:SetCondition(c4215636.condition)
	e2:SetTarget(c4215636.target)
	e2:SetOperation(c4215636.operation)
	c:RegisterEffect(e2)
end
-- 检查送入墓地的怪兽是否满足：被卡的效果破坏、原控制者为发动方、属性为风，以判断是否符合触发条件。
function c4215636.cfilter(c,tp)
	return bit.band(c:GetReason(),0x41)==0x41 and c:IsControler(tp) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 确认本次送去墓地的事件集合中存在至少1只满足上述条件的风属性怪兽。
function c4215636.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c4215636.cfilter,1,nil,tp)
end
-- 筛选可特殊召唤的怪兽：等级3以下、风属性，并且能够被玩家tp以效果形式特殊召唤。
function c4215636.spfilter(c,e,tp)
	return c:IsLevelBelow(3) and c:IsAttribute(ATTRIBUTE_WIND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动合法性判定：该效果不在连锁处理中、自己主怪兽区有空位，并且手卡·卡组中存在符合条件的怪兽。
function c4215636.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING)
		-- 进一步检查主怪兽区空格数大于0，且手卡·卡组中存在可特殊召唤的风属性3星以下怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(c4215636.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统登记本次操作包含将1只风属性怪兽从手卡·卡组特殊召唤，供相关卡牌效果进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果处理：若主怪兽区已无空位则直接结束；否则提示玩家选择要特殊召唤的卡，从手卡·卡组选出符合条件的1只，以表侧表示特殊召唤，并给该怪兽附加效果无效化状态，最后完成特殊召唤处理。
function c4215636.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 处理开始时再次确认自己场上是否有可用的主怪兽区空格，没有则本次特殊召唤不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示，让玩家从候选卡中选择。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己的手卡·卡组中选择1张满足风属性·3星以下且可特殊召唤的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c4215636.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 成功将所选怪兽以表侧表示特殊召唤时，继续为其附加后续的无效化效果。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 这个效果特殊召唤的怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成整个特殊召唤流程，统一处理特殊召唤成功时的时点与诱发效果。
	Duel.SpecialSummonComplete()
end
