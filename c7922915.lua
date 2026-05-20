--マジシャンズ・ナビゲート
-- 效果：
-- ①：从手卡把1只「黑魔术师」特殊召唤。那之后，从卡组把1只7星以下的魔法师族·暗属性怪兽特殊召唤。
-- ②：自己场上有「黑魔术师」存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。
function c7922915.initial_effect(c)
	-- 注册卡片记有「黑魔术师」卡名的信息。
	aux.AddCodeList(c,46986414)
	-- ①：从手卡把1只「黑魔术师」特殊召唤。那之后，从卡组把1只7星以下的魔法师族·暗属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c7922915.target)
	e1:SetOperation(c7922915.activate)
	c:RegisterEffect(e1)
	-- ②：自己场上有「黑魔术师」存在的场合，把这个回合没有送去墓地的这张卡从墓地除外，以对方场上1张表侧表示的魔法·陷阱卡为对象才能发动。那张卡的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(7922915,0))  --"效果无效"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCondition(c7922915.negcon)
	-- 把墓地的这张卡除外作为发动的代价。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c7922915.negtg)
	e2:SetOperation(c7922915.negop)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以特殊召唤的「黑魔术师」。
function c7922915.filter(c,e,tp)
	return c:IsCode(46986414) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤卡组中可以特殊召唤的7星以下的魔法师族·暗属性怪兽。
function c7922915.filter2(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsLevelBelow(7) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动准备与合法性检测。
function c7922915.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否能进行2次特殊召唤。
	if chk==0 then return Duel.IsPlayerCanSpecialSummonCount(tp,2)
		-- 检查自己场上的怪兽区域是否有2个以上的空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检查手卡中是否存在至少1只可以特殊召唤的「黑魔术师」。
		and Duel.IsExistingMatchingCard(c7922915.filter,tp,LOCATION_HAND,0,1,nil,e,tp)
		-- 检查卡组中是否存在至少1只可以特殊召唤的7星以下魔法师族·暗属性怪兽。
		and Duel.IsExistingMatchingCard(c7922915.filter2,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，涉及手卡和卡组的共2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①的处理逻辑。
function c7922915.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否有空位，若无则直接结束处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡选择1只「黑魔术师」。
	local g=Duel.SelectMatchingCard(tp,c7922915.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功将选择的「黑魔术师」表侧表示特殊召唤。
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 再次检查怪兽区域是否有空位，若无则直接结束处理。
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组选择1只7星以下的魔法师族·暗属性怪兽。
		local g2=Duel.SelectMatchingCard(tp,c7922915.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 中断当前效果，使后续的特殊召唤处理与前一次特殊召唤不视为同时处理。
			Duel.BreakEffect()
			-- 将选择的卡组怪兽表侧表示特殊召唤。
			Duel.SpecialSummon(g2,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 过滤场上表侧表示的「黑魔术师」。
function c7922915.cfilter(c)
	return c:IsCode(46986414) and c:IsFaceup()
end
-- 效果②的发动条件判断。
function c7922915.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查这张卡是否不是在送去墓地的回合，且自己场上是否存在表侧表示的「黑魔术师」。
	return aux.exccon(e) and Duel.IsExistingMatchingCard(c7922915.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 过滤可以被无效的魔法·陷阱卡。
function c7922915.negfilter(c)
	-- 检查卡片是否为可无效的表侧表示魔法或陷阱卡。
	return aux.NegateAnyFilter(c) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果②的发动准备与目标选择。
function c7922915.negtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c7922915.negfilter(chkc) end
	-- 检查对方场上是否存在至少1张可无效的表侧表示魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingTarget(c7922915.negfilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上1张表侧表示的魔法·陷阱卡作为效果对象。
	Duel.SelectTarget(tp,c7922915.negfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
end
-- 效果②的处理逻辑。
function c7922915.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与目标卡片相关的连锁都无效化。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果直到回合结束时无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			local e3=e1:Clone()
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			tc:RegisterEffect(e3)
		end
	end
end
