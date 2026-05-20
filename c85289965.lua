--ヴァレルソード・ドラゴン
-- 效果：
-- 效果怪兽3只以上
-- ①：这张卡不会被战斗破坏。
-- ②：自己·对方回合1次，以1只攻击表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽变成守备表示。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
-- ③：1回合1次，这张卡向表侧表示怪兽攻击宣言时才能发动。直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力一半数值，那只怪兽的攻击力变成一半。
function c85289965.initial_effect(c)
	-- 为这张卡添加连接召唤手续，需要效果怪兽3只以上作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),3)
	c:EnableReviveLimit()
	-- ①：这张卡不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合1次，以1只攻击表示怪兽为对象才能发动（对方不能对应这个效果的发动把卡的效果发动）。那只怪兽变成守备表示。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85289965,0))
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetTarget(c85289965.postg)
	e2:SetOperation(c85289965.posop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，这张卡向表侧表示怪兽攻击宣言时才能发动。直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力一半数值，那只怪兽的攻击力变成一半。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85289965,1))
	e3:SetCategory(CATEGORY_ATKCHANGE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetCountLimit(1)
	e3:SetCondition(c85289965.atkcon)
	e3:SetTarget(c85289965.atktg)
	e3:SetOperation(c85289965.atkop)
	c:RegisterEffect(e3)
end
-- 过滤场上攻击表示且可以改变表示形式的怪兽。
function c85289965.posfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition()
end
-- 改变表示形式效果的发动准备与目标选择。
function c85289965.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c85289965.posfilter(chkc) end
	-- 检测场上是否存在可以改变表示形式的攻击表示怪兽。
	if chk==0 then return Duel.IsExistingTarget(c85289965.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变表示形式的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择1只符合条件的攻击表示怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c85289965.posfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，表示该效果包含改变表示形式的操作。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
	-- 限制连锁，使对方不能对应这个效果的发动把卡的效果发动。
	Duel.SetChainLimit(c85289965.chlimit)
end
-- 连锁限制条件函数，仅允许发动该效果的玩家进行连锁。
function c85289965.chlimit(e,ep,tp)
	return tp==ep
end
-- 改变表示形式效果的执行处理。
function c85289965.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择为对象的那只怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsAttackPos() and tc:IsRelateToEffect(e) then
		-- 将目标怪兽变成表侧守备表示。
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE)
	end
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 攻击力变化效果的发动条件检测，确认攻击对象为表侧表示且攻击力大于0的怪兽。
function c85289965.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetBattleTarget()
	return tc and tc:IsFaceup() and tc:GetAttack()>0
end
-- 攻击力变化效果的发动准备，将攻击对象怪兽设为效果处理的目标。
function c85289965.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return true end
	-- 将这张卡当前的攻击对象怪兽设定为效果处理的目标卡片。
	Duel.SetTargetCard(e:GetHandler():GetBattleTarget())
end
-- 攻击力变化效果的执行处理。
function c85289965.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为攻击对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or tc:IsFacedown() or not tc:IsRelateToEffect(e) then return end
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetAttack()
		-- 直到回合结束时，这张卡的攻击力上升那只怪兽的攻击力一半数值
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(math.ceil(atk/2))
		c:RegisterEffect(e2)
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and not tc:IsImmuneToEffect(e) then
			-- 那只怪兽的攻击力变成一半。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(math.ceil(atk/2))
			tc:RegisterEffect(e1)
		end
	end
end
