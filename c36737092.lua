--シンクロ・チェンジ
-- 效果：
-- 把自己场上表侧表示存在的1只同调怪兽从游戏中除外发动。和那只怪兽相同等级的1只同调怪兽从额外卡组特殊召唤。这个效果特殊召唤的效果怪兽的效果无效化。
function c36737092.initial_effect(c)
	-- 效果发动时创建效果，设置为魔陷发动，自由时点，需要支付代价，有特殊召唤的处理，发动时需要选择目标
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(c36737092.cost)
	e1:SetTarget(c36737092.target)
	e1:SetOperation(c36737092.activate)
	c:RegisterEffect(e1)
end
-- 设置标签为100，表示可以发动效果
function c36737092.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	return true
end
-- 过滤函数，检查自己场上是否存在满足条件的同调怪兽，包括正面表示、同调类型、可以作为除外的代价，并且额外卡组存在相同等级的同调怪兽
function c36737092.filter1(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO) and c:IsAbleToRemoveAsCost()
		-- 检查额外卡组是否存在满足条件的同调怪兽
		and Duel.IsExistingMatchingCard(c36737092.filter2,tp,LOCATION_EXTRA,0,1,nil,c:GetLevel(),e,tp,c)
end
-- 过滤函数，检查额外卡组是否存在满足条件的同调怪兽，包括同调类型、等级匹配、可以特殊召唤，并且有足够召唤空间
function c36737092.filter2(c,lv,e,tp,mc)
	return c:IsType(TYPE_SYNCHRO) and c:IsLevel(lv) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查是否有足够的召唤空间
		and Duel.GetLocationCountFromEx(tp,tp,mc,c)>0
end
-- 设置效果目标，检查是否满足发动条件，若满足则提示选择除外的卡并执行除外操作，设置特殊召唤的处理信息
function c36737092.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查自己场上是否存在满足条件的同调怪兽
		return Duel.IsExistingMatchingCard(c36737092.filter1,tp,LOCATION_MZONE,0,1,nil,e,tp)
	end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的卡进行除外
	local rg=Duel.SelectMatchingCard(tp,c36737092.filter1,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
	e:SetLabel(rg:GetFirst():GetLevel())
	-- 将选中的卡从游戏中除外
	Duel.Remove(rg,POS_FACEUP,REASON_COST)
	-- 设置操作信息，表示将要特殊召唤一张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果发动时处理特殊召唤，选择满足条件的卡并特殊召唤，同时使该卡效果无效
function c36737092.activate(e,tp,eg,ep,ev,re,r,rp)
	local lv=e:GetLabel()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的卡进行特殊召唤
	local g=Duel.SelectMatchingCard(tp,c36737092.filter2,tp,LOCATION_EXTRA,0,1,1,nil,lv,e,tp,nil)
	local tc=g:GetFirst()
	-- 执行特殊召唤步骤，若成功则设置效果无效
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 使特殊召唤的怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
		-- 使特殊召唤的怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2,true)
	end
	-- 完成特殊召唤处理
	Duel.SpecialSummonComplete()
end
