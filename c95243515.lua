--電脳堺虎－虎々
-- 效果：
-- 9星怪兽×2只以上
-- ①：这张卡得到自己场上的「电脑堺门」卡数量的以下效果。
-- ●2张以上：这张卡可以直接攻击。
-- ●4张：这张卡不受「电脑堺」卡以外的卡发动的效果影响。
-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只效果怪兽和与那只怪兽是种族和属性不同的场上1只效果怪兽为对象才能发动。那些怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
function c95243515.initial_effect(c)
	-- 添加XYZ召唤手续：9星怪兽2只以上（最多99只）。
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ●2张以上：这张卡可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(c95243515.efcon1)
	c:RegisterEffect(e1)
	-- ●4张：这张卡不受「电脑堺」卡以外的卡发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_IMMUNE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c95243515.efcon2)
	e2:SetValue(c95243515.immval)
	c:RegisterEffect(e2)
	-- ②：1回合1次，把这张卡1个超量素材取除，以自己场上1只效果怪兽和与那只怪兽是种族和属性不同的场上1只效果怪兽为对象才能发动。那些怪兽的效果直到回合结束时无效。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(95243515,0))
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCost(c95243515.discost)
	e3:SetTarget(c95243515.distg)
	e3:SetOperation(c95243515.disop)
	c:RegisterEffect(e3)
end
-- 效果①中“2张以上”效果的启用条件函数。
function c95243515.efcon1(e)
	-- 计算自己场上表侧表示的「电脑堺门」卡数量。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSetCard),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil,0x114e)
	return ct>=2
end
-- 效果①中“4张”效果的启用条件函数。
function c95243515.efcon2(e)
	-- 计算自己场上表侧表示的「电脑堺门」卡数量。
	local ct=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsSetCard),e:GetHandlerPlayer(),LOCATION_ONFIELD,0,nil,0x114e)
	return ct==4
end
-- 免疫效果的判定函数，用于过滤「电脑堺」卡以外的卡发动的效果。
function c95243515.immval(e,re)
	local rc=re:GetHandler()
	return re:IsActivated() and not rc:IsSetCard(0x14e)
end
-- 效果②的代价：取除这张卡的1个超量素材。
function c95243515.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 效果②的第一只目标怪兽的筛选函数（自己场上的未被无效的效果怪兽，且场上存在与其种族和属性都不同的另一只未被无效的效果怪兽）。
function c95243515.filter1(c,tp)
	-- 判定卡片是否为未被无效的效果怪兽。
	return c:IsType(TYPE_EFFECT) and aux.NegateEffectMonsterFilter(c)
		-- 判定场上是否存在满足第二只怪兽条件的可选择对象。
		and Duel.IsExistingTarget(c95243515.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,c)
end
-- 效果②的第二只目标怪兽的筛选函数（与第一只怪兽种族和属性都不同的未被无效的效果怪兽）。
function c95243515.filter2(c,tc)
	-- 判定卡片是否为未被无效的效果怪兽。
	return c:IsType(TYPE_EFFECT) and aux.NegateEffectMonsterFilter(c)
		and not c:IsRace(tc:GetRace()) and not c:IsAttribute(tc:GetAttribute())
end
-- 效果②的发动准备与目标选择（Target阶段）。
function c95243515.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判定是否能选择符合条件的第一只怪兽（自己场上的效果怪兽）。
	if chk==0 then return Duel.IsExistingTarget(c95243515.filter1,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择自己场上的1只效果怪兽作为第一个对象。
	local g1=Duel.SelectTarget(tp,c95243515.filter1,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 提示玩家选择要无效的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 玩家选择场上1只与第一只怪兽种族和属性都不同的效果怪兽作为第二个对象。
	local g2=Duel.SelectTarget(tp,c95243515.filter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,g1:GetFirst(),g1:GetFirst())
	g1:Merge(g2)
	-- 设置效果处理信息：使选中的怪兽效果无效。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g1,#g1,0,0)
end
-- 效果②的效果处理（Operation阶段）。
function c95243515.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在连锁处理时仍存在于场上且表侧表示的对象怪兽。
	local g=Duel.GetTargetsRelateToChain():Filter(Card.IsFaceup,nil)
	if #g==0 then return end
	-- 遍历所有符合条件的对象怪兽。
	for tc in aux.Next(g) do
		if tc:IsCanBeDisabledByEffect(e) then
			-- 使与该怪兽相关的连锁效果无效化。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那些怪兽的效果直到回合结束时无效。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 那些怪兽的效果直到回合结束时无效。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
