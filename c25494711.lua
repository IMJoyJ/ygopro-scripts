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
-- 效果①的发动条件：必须在自己的主要阶段1（PHASE_MAIN1）且当前阶段为主要阶段1时才能发动。
function c25494711.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段1，是则返回真，作为效果①的发动条件。
	return Duel.GetCurrentPhase()==PHASE_MAIN1
end
-- 定义效果①要统计攻击力的对象：己方场上表侧表示、属于「文具电子人」系列且卡名不是「文具电子人009」的怪兽。
function c25494711.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xab) and not c:IsCode(25494711)
end
-- 效果①发动时的处理：确认存在满足条件的「文具电子人」怪兽后，在发动同时给自己场上除这张卡以外的怪兽赋予“本回合不能攻击”的誓约限制。
function c25494711.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果①的发动条件判定：自己场上存在「文具电子人009」以外的表侧表示「文具电子人」怪兽时才能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c25494711.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- ①：1回合1次，自己主要阶段1才能发动。这张卡的攻击力直到对方回合结束时上升「文具电子人009」以外的自己场上的「文具电子人」怪兽的攻击力的合计数值。这个效果发动的回合，不用这张卡不能攻击。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c25494711.ftarget)
	e1:SetLabel(e:GetHandler():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将“本回合除这张卡以外的己方怪兽不能攻击”的誓约效果注册到当前玩家场上，并在结束阶段自动失效。
	Duel.RegisterEffect(e1,tp)
end
-- 效果①处理：统计当前己方场上其他「文具电子人」怪兽的攻击力合计，并将这张卡的攻击力上升该数值，持续到对方回合结束。
function c25494711.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 获取当前己方场上所有满足条件的「文具电子人」怪兽（表侧表示、不属于009、属于字段）组成集合。
		local g=Duel.GetMatchingGroup(c25494711.atkfilter,tp,LOCATION_MZONE,0,nil)
		local atk=g:GetSum(Card.GetAttack)
		-- 这张卡的攻击力直到对方回合结束时上升「文具电子人009」以外的自己场上的「文具电子人」怪兽的攻击力的合计数值。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		e1:SetValue(atk)
		tc:RegisterEffect(e1)
	end
end
-- 筛选不能攻击的对象：只限制除这张卡（即「文具电子人009」）以外的己方怪兽，保证这张卡自身仍可攻击。
function c25494711.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
-- 效果②的适用条件：这张卡进行战斗时（作为攻击者或攻击目标）才能封锁对方的效果发动。
function c25494711.actcon(e)
	-- 当前战斗的攻击者或攻击目标是否为这张卡，若是则条件成立。
	return Duel.GetAttacker()==e:GetHandler() or Duel.GetAttackTarget()==e:GetHandler()
end
-- 定义可代替破坏的卡的条件：己方场上表侧表示的「文具电子人」卡，可被效果破坏且未处于预定破坏状态。
function c25494711.repfilter(c,e)
	return c:IsFaceup() and c:IsSetCard(0xab)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
end
-- 效果③的触发条件：这张卡要被战斗或效果破坏（且不是由代替破坏引起），并且自己场上存在可代替破坏的「文具电子人」卡时，可以选择发动代替破坏。
function c25494711.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE)
		-- 检查自己场上是否存在至少1张满足代替破坏条件的「文具电子人」卡。
		and Duel.IsExistingMatchingCard(c25494711.repfilter,tp,LOCATION_ONFIELD,0,1,c,e) end
	-- 让玩家选择是否发动代替破坏效果，若选择是则进入下一步处理。
	if Duel.SelectEffectYesNo(tp,c,96) then
		-- 显示“请选择要代替破坏的卡”的选择提示，将选择信息写入缓存。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)  --"请选择要代替破坏的卡"
		-- 让玩家从自己场上选择1张满足条件的「文具电子人」卡作为代替破坏对象。
		local g=Duel.SelectMatchingCard(tp,c25494711.repfilter,tp,LOCATION_ONFIELD,0,1,1,c,e)
		-- 将选择的代替破坏对象设为当前连锁的对象卡，使后续Duel.GetChainInfo能取到它。
		Duel.SetTargetCard(g)
		g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,true)
		return true
	else return false end
end
-- 代替破坏处理：清除对象卡的“预定破坏”状态，并将其作为代替破坏的卡破坏（送去墓地）。
function c25494711.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取得发动代替破坏时选择的那张卡（对象卡组）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	g:GetFirst():SetStatus(STATUS_DESTROY_CONFIRMED,false)
	-- 将选择的卡以“效果+代替”的原因破坏，完成代替破坏。
	Duel.Destroy(g,REASON_EFFECT+REASON_REPLACE)
end
