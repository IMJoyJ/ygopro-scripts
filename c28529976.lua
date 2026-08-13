--超栄養太陽
-- 效果：
-- ①：把自己场上1只2星以下的植物族怪兽解放才能把这张卡发动。把持有解放的怪兽的等级＋3以下的等级的1只植物族怪兽从手卡·卡组特殊召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽从场上离开时这张卡破坏。
function c28529976.initial_effect(c)
	-- 把自己场上1只2星以下的植物族怪兽解放才能把这张卡发动。把持有解放的怪兽的等级＋3以下的等级的1只植物族怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c28529976.target)
	e1:SetOperation(c28529976.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c28529976.desop)
	c:RegisterEffect(e2)
	-- 那只怪兽从场上离开时这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(c28529976.descon2)
	e3:SetOperation(c28529976.desop2)
	c:RegisterEffect(e3)
end
-- 该函数为解放候选怪兽的过滤条件：必须是2星以下的植物族；若主要怪兽区当前没有空位，则只能选择自己主怪兽区的怪兽；只能选择自己控制的怪兽或对方表侧表示的怪兽；并且手卡·卡组中必须存在1只等级不超过该怪兽等级+3且可特殊召唤的植物族怪兽。
function c28529976.cfilter(c,e,tp,ft)
	return c:IsLevelBelow(2) and c:IsRace(RACE_PLANT)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
		-- 在解放候选的过滤中追加判定：手卡·卡组存在至少1只等级不高于该候选怪兽当前等级+3的植物族怪兽，且该怪兽能够被特殊召唤，确保发动后可以检索到目标。
		and Duel.IsExistingMatchingCard(c28529976.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,c:GetLevel()+3,e,tp)
end
-- 这是可特殊召唤目标的过滤函数：要求是等级不超过指定等级lv的植物族怪兽，并且能够被当前效果特殊召唤（不检查召唤条件与苏生限制）。
function c28529976.filter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_PLANT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 目标函数：判定发动条件并执行发动时的代价。需要主要怪兽区有空位（或解放后有空位）且存在可解放的2星以下植物族怪兽；然后选择1只解放，将解放怪兽的等级+3存入效果标签，并设置从手卡·卡组特殊召唤1只植物族怪兽的操作信息。
function c28529976.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家主要怪兽区的可用格数，用于后续判断能否特殊召唤及解放选择限制。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动条件检查时：要求当前主要怪兽区空位数不为负（解放后能腾出空位），并且场上存在1只满足条件的可解放植物族怪兽（其还必须能对应手卡·卡组中的可特召目标）。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c28529976.cfilter,1,nil,e,tp,ft) end
	-- 从满足解放条件的怪兽中选择1只作为发动代价的解放对象。
	local rg=Duel.SelectReleaseGroup(tp,c28529976.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel()+3)
	-- 将选择的怪兽解放，作为这张卡发动的代价。
	Duel.Release(rg,REASON_COST)
	-- 设置操作信息：本次效果将进行1只植物族怪兽从手卡·卡组的特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数：若主要怪兽区空位不足则效果不处理；否则玩家从手卡·卡组选择1只符合条件的植物族怪兽，以表侧表示特殊召唤，并将这张卡设为那只怪兽的永续对象，以维持后续相互破坏的关联。
function c28529976.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认主要怪兽区仍有空位，若没有则特殊召唤无法进行，效果不处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 显示选择提示，提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡·卡组选择1只植物族怪兽，要求其等级不超过效果标签记录的解放怪兽等级+3，且可被特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c28529976.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的怪兽以表侧表示特殊召唤到当前玩家场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		c:SetCardTarget(tc)
	end
end
-- 这张卡从场上离开时触发的效果：若其永续对象（被特殊召唤的怪兽）仍在怪兽区，则破坏那只怪兽。
function c28529976.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 以效果原因破坏那只被特殊召唤的怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 效果发动条件：这张卡的永续对象（被特殊召唤的怪兽）从场上离场（出现在离场事件组中）时满足。
function c28529976.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
-- 当对象怪兽从场上离开时，处理效果：破坏这张卡（超营养太阳）。
function c28529976.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果原因破坏这张卡本身。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
