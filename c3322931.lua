--星風狼ウォルフライエ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- ①：「星风狼 沃尔夫拉叶狼」在自己场上只能有1只表侧表示存在。
-- ②：只要攻击力未满4000的这张卡在怪兽区域存在，每次这张卡以外的怪兽的效果发动，这张卡的攻击力上升300。
-- ③：1回合1次，这张卡的攻击力是4000以上的场合才能发动。这张卡和对方场上的怪兽全部回到持有者卡组。这个效果在对方回合也能发动。
function c3322931.initial_effect(c)
	c:SetUniqueOnField(1,0,3322931)
	-- 设置这张卡的同调召唤手续：调整＋调整以外的怪兽1只以上，其中调整部分不限定（任意调整），调整以外怪兽至少1只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ②：每次这张卡以外的怪兽的效果发动（本段用于监听效果发动时点并做标记，对应②的触发条件）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetRange(LOCATION_MZONE)
	-- 设置连锁发生时的操作为记录函数，使这张卡在该连锁中被标记为已在场上存在，用于②判定“这张卡在怪兽区域存在”以及“是这张卡以外的怪兽的效果”。
	e1:SetOperation(aux.chainreg)
	c:RegisterEffect(e1)
	-- ②：只要攻击力未满4000的这张卡在怪兽区域存在，每次这张卡以外的怪兽的效果发动，这张卡的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(c3322931.atkop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡的攻击力是4000以上的场合才能发动。这张卡和对方场上的怪兽全部回到持有者卡组。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3322931,0))
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCountLimit(1)
	e3:SetCondition(c3322931.tdcon)
	e3:SetTarget(c3322931.tdtg)
	e3:SetOperation(c3322931.tdop)
	c:RegisterEffect(e3)
end
-- ②的诱发处理函数：当连锁结束时，若这张卡攻击力未满4000、发动连锁的效果来自这张卡以外的怪兽效果、且该连锁发动时这张卡已在场上，则为这张卡附加一次攻击力上升300的效果。
function c3322931.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetAttack()<4000 and re:GetHandler()~=c and re:IsActiveType(TYPE_MONSTER) and c:GetFlagEffect(FLAG_ID_CHAINING)>0 then
		-- 这张卡的攻击力上升300（对应②中的攻击力上升部分）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ③的发动条件判定：这张卡当前攻击力在4000以上时才能发动。
function c3322931.tdcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackAbove(4000)
end
-- ③的发动时目标判定：获取对方场上所有可以回到卡组的怪兽，并连同这张卡一起作为回卡组的对象，同时检查这张卡自身能否回卡组以及对方场上是否存在可回卡组的怪兽。
function c3322931.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取对方场上所有满足“可以回到卡组”的怪兽集合（不取对象，实际处理对象在效果处理时确定）。
	local g=Duel.GetMatchingGroup(Card.IsAbleToDeck,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return c:IsAbleToDeck() and g:GetCount()>0 end
	g:AddCard(c)
	-- 登记本次连锁的操作信息：效果分类为回卡组（CATEGORY_TODECK），处理对象为g（这张卡＋对方怪兽），数量为g的数量，目标玩家和位置未知填0，使相关卡（如星尘龙等）能正确响应这次回卡组效果。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- ③的效果处理函数：若这张卡仍与效果关联，则重新获取对方场上当前全部怪兽，将这张卡和这些怪兽一起返回持有者卡组并洗牌，实现“回到持有者卡组”。
function c3322931.tdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 效果处理时重新获取对方场上当前存在的所有怪兽，以保证实际处理的是在场上的怪兽。
		local g=Duel.GetMatchingGroup(nil,tp,0,LOCATION_MZONE,nil)
		if g:GetCount()>0 then
			g:AddCard(c)
			-- 将g中的所有卡（这张卡和对方场上的怪兽）返回持有者卡组并洗牌，效果原因记为REASON_EFFECT，完成回卡组操作。
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end
