--シンクロ・チェンジ
-- 效果：
-- 把自己场上表侧表示存在的1只同调怪兽从游戏中除外发动。和那只怪兽相同等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
function c36737092.initial_effect(c)
	-- 把自己场上表侧表示存在的1只同调怪兽从游戏中除外发动。和那只怪兽相同等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c36737092.cost)
	e1:SetTarget(c36737092.target)
	e1:SetOperation(c36737092.activate)
	c:RegisterEffect(e1)
end
-- 发动时的代价函数：设置标签为100表示已进行发动前检查，并返回true；实际除外代价在target函数中支付。
function c36737092.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 定义可选择为代价的场上同调怪兽的条件：表侧表示、同调怪兽、可作为代价除外；并且额外卡组存在等级相同且可特殊召唤的同调怪兽。
function c36737092.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		-- 检查额外卡组中是否存在满足filter2条件的同调怪兽（与被候选怪兽同等级、可特殊召唤、且除候选后有额外卡组可用区域），以保证后续特殊召唤可行。
		and Duel.IsExistingMatchingCard(c36737092.filter2,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),e,tp,c)
end
-- 定义额外卡组可特殊召唤的同调怪兽的条件：是同调怪兽、等级等于记录的等级、可以被效果特殊召唤，并且将候选怪兽除外后场上仍有可用的额外卡组怪兽区域。
function c36737092.filter2(c,lv,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确认将候选怪兽（mc）除外后，有足够的区域来特殊召唤目标同调怪兽（c），即额外卡组怪兽可出场的空格数大于0。
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 发动时的目标选择与代价支付流程：合法检查时确认存在可除外的同调怪兽；发动时选择1只表侧同调怪兽作为代价除外，记录其等级，并设置特殊召唤的操作信息。
function c36737092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在至少1只满足filter1条件的表侧同调怪兽，即发动是否具备合法对象。
		return Duel.IsExistingMatchingCard(c36737092.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	-- 给玩家显示选择提示，要求选择要除外的同调怪兽（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足filter1条件的表侧同调怪兽，用于作为发动代价。
	local rg=Duel.SelectMatchingCard(tp,c36737092.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的同调怪兽以表侧表示从游戏中除外（作为发动代价）。
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 设置操作信息：效果处理时将执行特殊召唤，对象为额外卡组的1只怪兽（数量1，属于tp）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理流程：根据记载的等级选择额外卡组1只同调怪兽进行特殊召唤，并为特殊召唤成功的怪兽附加效果无效化；最后完成特殊召唤。
function c36737092.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 给玩家显示选择提示，要求选择要特殊召唤的同调怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从额外卡组选择1只满足filter2条件的同调怪兽（等级等于除外怪兽的等级、可特殊召唤、且有空位）。
	local g=Duel.SelectMatchingCard(tp,c36737092.filter2,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,nil)
	local tc=g:GetFirst()
	-- 以表侧表示将选择的同调怪兽进行特殊召唤（进入连锁的特殊召唤步骤）；若成功，则继续为其赋予效果无效化。
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 这个效果特殊召唤的效果怪兽的效果无效化。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 和那只怪兽相同等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成整个特殊召唤流程（SpecialSummonStep对应的连续特殊召唤步骤结束，触发召唤成功的时点）。
	Duel.SpecialSummonComplete()
end
