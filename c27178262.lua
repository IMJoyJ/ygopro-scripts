--六武衆の理
-- 效果：
-- 把自己场上表侧表示存在的1只名字带有「六武众」的怪兽送去墓地才能发动。选择自己或者对方的墓地1只名字带有「六武众」的怪兽在自己场上特殊召唤。
function c27178262.initial_effect(c)
	-- 把自己场上表侧表示存在的1只名字带有「六武众」的怪兽送去墓地才能发动。选择自己或者对方的墓地1只名字带有「六武众」的怪兽在自己场上特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c27178262.cost)
	e1:SetTarget(c27178262.target)
	e1:SetOperation(c27178262.activate)
	c:RegisterEffect(e1)
end
-- 代价过滤条件：自己场上的表侧表示怪兽，必须为名字带有「六武众」的怪兽、可作为代价送去墓地；并且若己方主要怪兽区无空格则只能选择位于主要怪兽区的怪兽作为代价（以便送墓后空出特殊召唤位置）。
function c27178262.costfilter(c,ft)
	return c:IsFaceup() and c:IsSetCard(0x103d) and c:IsAbleToGraveAsCost() and (ft>0 or c:GetSequence()<5)
end
-- 支付代价处理：获取己方主要怪兽区空格数，检查能否支付代价并存在符合条件的表侧表示「六武众」怪兽；提示玩家选择一张要送去墓地的卡，将其作为代价送入墓地。
function c27178262.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区的可用空格数，用于判断代价送墓后是否有地方可以特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 若处于发动可行性检查阶段（chk==0），返回是否满足：空格数允许且己方场上存在至少1只符合代价条件的「六武众」怪兽。
	if chk==0 then return ft>-1 and Duel.IsExistingMatchingCard(c27178262.costfilter,tp,LOCATION_MZONE,0,1,nil,ft) end
	-- 向玩家发送选择提示，提示内容为“请选择要送去墓地的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方场上选择1张满足代价过滤条件的「六武众」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c27178262.costfilter,tp,LOCATION_MZONE,0,1,1,nil,ft)
	-- 将选择的怪兽作为发动代价送入墓地（REASON_COST）。
	Duel.SendtoGrave(g,REASON_COST)
end
-- 墓地对象过滤条件：墓地里的怪兽必须为名字带有「六武众」的怪兽，并且能够被当前效果特殊召唤（检查召唤条件与苏生限制）。
function c27178262.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时的对象选择处理：确认目标合法性、检查墓地是否存在合法对象、提示玩家选择要特殊召唤的卡，选定1只墓地中的「六武众」怪兽为对象，并设置操作为特殊召唤1只怪兽。
function c27178262.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c27178262.filter(chkc,e,tp) end
	-- 若处于发动可行性检查阶段（chk==0），返回墓地是否存在至少1只满足特殊召唤条件且可作为对象的「六武众」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c27178262.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil,e,tp) end
	-- 向玩家发送选择提示，提示内容为“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从双方墓地中选择1只满足条件的「六武众」怪兽作为本效果的对象（取对象，并与当前连锁建立关联）。
	local g=Duel.SelectTarget(tp,c27178262.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息：本次效果将对所选择的1只怪兽进行特殊召唤处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理阶段：若己方主要怪兽区仍有空位，则取得效果对象；若对象仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function c27178262.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 若己方主要怪兽区没有空位，则无法特殊召唤，效果处理直接结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 取得发动时选择的对象卡（取对象效果保存的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示（POS_FACEUP，通常为表侧攻击表示）特殊召唤到己方场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
