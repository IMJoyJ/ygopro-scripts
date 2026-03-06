--ブンボーグ009
-- 效果：
-- ①：1回合1次，自己主要阶段1才能发动。这张卡的攻击力直到对方回合结束时上升「文具电子人009」以外的自己场上的「文具电子人」怪兽的攻击力的合计数值。这个效果发动的回合，不用这张卡不能攻击。
-- ②：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1张「文具电子人」卡破坏。
function c25494711.initial_effect(c)
	-- ①：1回合1次，自己主要阶段1才能发动。这张卡的攻击力直到对方回合结束时上升「文具电子人009」以外的自己场上的「文具电子人」怪兽的攻击力的合计数值。这个效果发动的回合，不用这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c25494711.atkcon)
	e1:SetTarget(c25494711.atktg)
	e1:SetOperation(c25494711.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡进行战斗的场合，对方直到伤害步骤结束时魔法·陷阱·怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(1)
	e2:SetCondition(c25494711.actcon)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗·效果破坏的场合，可以作为代替把自己场上1张「文具电子人」卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c25494711.reptg)
	e3:SetOperation(c25494711.repop)
	c:RegisterEffect(e3)
end
-- 判断是否处于主要阶段1
function c25494711.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否处于主要阶段1
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 过滤满足条件的「文具电子人」怪兽（场上正面表示、种族为文具电子人、且不是009本身）
function c25494711.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab) and not c:IsCode(25494711)
end
-- 设置效果目标，检查是否存在满足条件的怪兽并注册不能攻击效果
function c25494711.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在满足条件的「文具电子人」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c25494711.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 创建并注册不能攻击效果，使本回合不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c25494711.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家
	Duel.RegisterEffect(e1,tp)
end
-- 处理攻击力提升效果，计算满足条件怪兽的攻击力总和并加到自身
function c25494711.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取满足条件的「文具电子人」怪兽组
		local g=Duel.GetMatchingGroup(c25494711.atkfilter,tp,LOCATION_MZONE,0,nil)
		local atk=g:GetSum(Card.GetAttack)
		-- 创建并注册攻击力提升效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
-- 设置不能攻击效果的目标，排除自身
function c25494711.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 判断是否为攻击或被攻击状态
function c25494711.actcon(e)
	-- 判断是否为攻击或被攻击状态
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 过滤满足条件的「文具电子人」卡（正面表示、种族为文具电子人、可被破坏、未确认破坏）
function c25494711.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xab)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 判断是否满足代替破坏条件（被战斗或效果破坏、未被代替破坏、场上存在满足条件的卡）
function c25494711.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 场上存在满足条件的「文具电子人」卡
		and Duel.IsExistingMatchingCard(c25494711.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 提示玩家选择代替破坏的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 选择一张满足条件的「文具电子人」卡
		local g=Duel.SelectMatchingCard(tp,c25494711.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		-- 设置选择的卡为连锁对象
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 处理代替破坏效果，将选择的卡破坏
function c25494711.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选择的卡以效果和代替破坏原因破坏
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
