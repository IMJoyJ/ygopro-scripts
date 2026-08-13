--絢嵐たる権能
-- 效果：
-- ①：1回合1次，以包含「绚岚」卡的自己墓地3张速攻魔法卡为对象才能发动。以下适用。
-- ●那些卡回到卡组。那之后，自己抽1张。
-- ●这个回合中，自己场上的风属性怪兽的攻击力·守备力上升300。
-- ②：「旋风」发动时，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果无效。
-- ③：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 注册该卡作为魔法卡发动所需的空效果（e1），以及①回收抽卡效果（e2）、②无效效果（e3）、③盖放效果（e4），分别设置其类型、范围、条件、目标与操作。
function s.initial_effect(c)
	-- 将「旋风」（5318639）登记为本卡记载的卡名，用于后续「旋风」相关效果判定。
	aux.AddCodeList(c,5318639)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：1回合1次，以包含「绚岚」卡的自己墓地3张速攻魔法卡为对象才能发动。以下适用。●那些卡回到卡组。那之后，自己抽1张。●这个回合中，自己场上的风属性怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"回收效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_SZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCountLimit(1)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_END_PHASE+TIMING_DAMAGE_STEP)
	e2:SetTarget(s.drtg)
	e2:SetOperation(s.drop)
	c:RegisterEffect(e2)
	-- ②：「旋风」发动时，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果无效。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"无效效果"
	e3:SetCategory(CATEGORY_DISABLE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.discon)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：这张卡被「旋风」的效果破坏的场合才能发动。这张卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCondition(s.setcon)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
end
-- 筛选条件：对象为速攻魔法卡，且能够返回卡组，并且能够成为效果的对象。
function s.tdfilter(c)
	return c:IsType(TYPE_QUICKPLAY) and c:IsAbleToDeck() and c:IsCanBeEffectTarget()
end
-- 检查所选3张卡中是否至少包含1张卡名含有「绚岚」（系列编号0x1d1）的卡。
function s.gcheck(g)
	return g:FilterCount(Card.IsSetCard,nil,0x1d1)>0
end
-- ①的发动目标处理：从自己墓地选出3张满足条件的速攻魔法卡（其中至少1张「绚岚」卡）作为对象，并设置送回卡组和抽1张卡的操作信息。
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足s.tdfilter条件的速攻魔法卡。
	local dg=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return dg:CheckSubGroup(s.gcheck,3,3) end
	-- 向操作者显示“请选择要返回卡组的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	local g=dg:SelectSubGroup(tp,s.gcheck,false,3,3)
	-- 将选中的卡组设为当前连锁的对象，使后续“回卡组”处理能够追踪这些卡。
	Duel.SetTargetCard(g)
	-- 登记操作信息：将3张对象卡返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,3,0,0)
	-- 登记操作信息：自己抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ①的操作处理：先将对象卡返回卡组，若返回成功且其中有卡在卡组，则抽1张；随后给自己场上的风属性怪兽附加攻击力·守备力上升300的效果。
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡（即发动时选择的那3张速攻魔法卡）。
	local g=Duel.GetTargetsRelateToChain()
	if #g~=0 then
		-- 若对象卡实际返回了卡组，并且其中仍有卡存在于卡组中，则继续执行后续抽卡处理。
		if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and g:IsExists(Card.IsLocation,1,nil,LOCATION_DECK) then
			-- 中断当前效果链，使接下来的抽卡处理视为独立动作，以正确发出抽卡时点。
			Duel.BreakEffect()
			-- 自己抽1张卡。
			Duel.Draw(tp,1,REASON_EFFECT)
			-- 再次中断效果链，使后续的攻防上升处理与抽卡处理分离。
			Duel.BreakEffect()
		end
	end
	-- ●这个回合中，自己场上的风属性怪兽的攻击力·守备力上升300。②：「旋风」发动时，以对方场上1张表侧表示卡为对象才能发动（同一连锁上最多1次）。那张卡的效果无效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.atktg)
	e1:SetValue(300)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在场上区域注册永续效果：自己场上的风属性怪兽攻击力上升300，直到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e1:SetCode(EFFECT_UPDATE_DEFENSE)
	-- 注册与e1相同但改为防御力上升300的永续效果。
	Duel.RegisterEffect(e2,tp)
end
-- 攻防上升效果的目标筛选：只对自己场上的风属性怪兽生效。
function s.atktg(e,c)
	return c:IsAttribute(ATTRIBUTE_WIND)
end
-- ②的发动条件：检测到「旋风」的魔法卡发动时允许发动。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:GetHandler():IsCode(5318639)
end
-- ②的目标处理：选择对方场上一张表侧表示且能被无效的卡作为对象，并登记无效操作信息。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 当检查已选对象时，确认该卡是对方场上表侧表示且能被无效的卡。
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and aux.NegateAnyFilter(chkc) end
	-- 效果发动合法性检查：确认对方场上有满足条件的对象存在。
	if chk==0 then return Duel.IsExistingTarget(aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 显示“请选择要无效的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
	-- 选择对方场上一张符合条件（表侧表示且可被无效）的卡作为对象。
	local g=Duel.SelectTarget(tp,aux.NegateAnyFilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 登记操作信息：无效所选对象卡。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
end
-- ②的操作处理：使对象卡的效果无效，包括无效其卡片效果、效果发动，以及若为陷阱怪兽则无效陷阱怪兽化。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果处理时的对象卡（唯一的对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToChain() and tc:IsCanBeDisabledByEffect(e,false) then
		-- 使与该对象卡相关的连锁效果无效化，持续到回合结束时重置。
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 那张卡的效果无效。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 那张卡的效果无效。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		if tc:IsType(TYPE_TRAPMONSTER) then
			-- 那张卡的效果无效。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_DISABLE_TRAPMONSTER)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e3)
		end
	end
end
-- ③的发动条件：本卡因「旋风」的效果被破坏的场合。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and re:GetHandler():IsCode(5318639)
end
-- ③的目标处理：确认本卡可以被盖放，并登记“从墓地离开”的操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	-- 登记操作信息：本卡将离开墓地（以盖放形式返回场上）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- ③的操作处理：将本卡在自己场上盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认本卡仍与连锁相关，并且不受王家长眠之谷等墓地效果限制的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡盖放到自己场上。
		Duel.SSet(tp,c)
	end
end
