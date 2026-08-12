--Ai－ボウ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上的原本攻击力是2300的电子界族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
-- ②：把墓地的这张卡除外，以自己的除外状态的1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①效果（无效对方场上的卡）和②效果（从墓地除外自身特召除外状态的电子界族怪兽）。
function s.initial_effect(c)
	-- ①：以自己场上的原本攻击力是2300的电子界族怪兽数量的对方场上的表侧表示卡为对象才能发动。那些卡的效果直到回合结束时无效。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"效果无效"
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以自己的除外状态的1只电子界族怪兽为对象才能发动。那只怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	-- 设置发动代价为将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示、原本攻击力为2300的电子界族怪兽。
function s.cfilter(c)
	return c:GetBaseAttack()==2300 and c:IsRace(RACE_CYBERSE) and c:IsFaceup()
end
-- ①效果的发动准备与目标选择（计算符合条件的怪兽数量，并选择对应数量的对方场上表侧表示卡片作为对象）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己场上符合条件的原本攻击力2300的电子界族怪兽数量。
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	-- 处于已选择对象状态时，检查该对象是否为对方场上可无效的卡。
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and aux.NegateAnyFilter(chkc) end
	-- 检查可行性：自己场上存在至少1只符合条件的怪兽，且对方场上有足够数量的可无效卡片。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上等同于符合条件怪兽数量的表侧表示卡片作为对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,ct,ct,nil)
	-- 设置效果处理信息：无效指定数量的卡的效果。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ①效果的实际处理（使选中的对象卡片效果直到回合结束时无效）。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中仍有效的对象卡片。
	local tg=Duel.GetTargetsRelateToChain()
	-- 遍历所有选中的对象卡片。
	for tc in aux.Next(tg) do
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
			-- 使与该卡相关的连锁效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些卡的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些卡的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
			if tc:IsType(TYPE_TRAPMONSTER) then
				-- 那些卡的效果直到回合结束时无效。
				local e3=Effect.CreateEffect(c)
				e3:SetType(EFFECT_TYPE_SINGLE)
				e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
				e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e3)
			end
		end
	end
end
-- 过滤条件：除外状态且可以特殊召唤的电子界族怪兽。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsRace(RACE_CYBERSE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备与目标选择（检查怪兽区域空位，并选择1只除外状态的电子界族怪兽作为对象）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	-- 检查可行性：自己场上是否有可用的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查可行性：自己的除外状态中是否存在符合特殊召唤条件的电子界族怪兽。
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_REMOVED,0,1,e:GetHandler(),e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己除外状态的1只符合条件的电子界族怪兽作为对象。
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤选中的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果的实际处理（将选中的除外状态怪兽特殊召唤）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为特殊召唤对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以表侧表示特殊召唤。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
