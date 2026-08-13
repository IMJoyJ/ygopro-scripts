--GP－ペダル・トゥ・メタル
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：以自己场上1只「黄金荣耀」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。
-- ②：这个回合有自己场上的表侧表示的「黄金荣耀」怪兽被战斗·效果破坏的场合，结束阶段才能发动。墓地的这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建并注册该卡的①效果（发动后取对象，赋予攻击力上升、双重破坏抗性与不能发动效果）、②效果（满足条件时从墓地盖放），并注册一个全局破坏监测效果，用于记录本回合有无黄金荣耀怪兽被战破/效破。
function s.initial_effect(c)
	-- ①：以自己场上1只「黄金荣耀」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 限制为当前不在伤害步骤、或处于伤害步骤但尚未伤害计算时才能发动，即不能进入伤害计算后发动。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：这个回合有自己场上的表侧表示的「黄金荣耀」怪兽被战斗·效果破坏的场合，结束阶段才能发动。墓地的这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- ①：以自己场上1只「黄金荣耀」怪兽为对象才能发动。那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。②：这个回合有自己场上的表侧表示的「黄金荣耀」怪兽被战斗·效果破坏的场合。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_DESTROYED)
		e3:SetOperation(s.check)
		-- 将全局破坏监测效果注册到玩家0（环境侧），使所有场上发生的破坏事件都能进入s.check进行条件判断。
		Duel.RegisterEffect(e3,0)
	end
end
-- 定义过滤器：卡为表侧表示且属于系列0x192（黄金荣耀）的怪兽。
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x192)
end
-- ①效果的发动时点：选择自己场上1只表侧表示「黄金荣耀」怪兽为对象；若是在连锁处理中，则对指定的对象进行合法性校验。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查自己场上是否存在至少1只可选的表侧表示「黄金荣耀」怪兽，作为①效果的发动条件。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家显示“请选择表侧表示的卡”的选择提示，供接下来的对象选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 让玩家从自己场上的表侧「黄金荣耀」怪兽中选择1只，将其登记为本次连锁的对象（取对象效果）。
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ①效果处理：取得对象后，先确认对象仍与效果有联系；随后赋予其“不会被战斗破坏”“不会被效果破坏”“不能发动效果”的持续效果，并在对象表侧表示时使其攻击力上升500；这些效果都在回合结束时重置。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取出连锁中登记的对象卡，即①效果选择的那只黄金荣耀怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local c=e:GetHandler()
	-- 对应①效果原文“那只怪兽直到回合结束时攻击力上升500，不会被战斗·效果破坏，不能把效果发动。”中的“不会被战斗·效果破坏”的战斗破坏部分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	tc:RegisterEffect(e2)
	-- 直接对应①效果原文中的“不能把效果发动”。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CANNOT_TRIGGER)
	e3:SetReset(RESET_PHASE+PHASE_END+RESET_EVENT+RESETS_STANDARD)
	tc:RegisterEffect(e3)
	if tc:IsFaceup() then
		local e4=e1:Clone()
		e4:SetCode(EFFECT_UPDATE_ATTACK)
		e4:SetValue(500)
		tc:RegisterEffect(e4)
	end
end
-- ②效果的发动条件：当前玩家必须拥有本回合“黄金荣耀怪兽被战破/效破”的标记，且时点在结束阶段。
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查tp玩家身上带有本卡id标志的数量是否大于0，即是否满足②效果所需的“本回合有己方黄金荣耀怪兽被战破/效破”前提。
	return Duel.GetFlagEffect(tp,id)>0
end
-- ②效果发动时的合法性判定：确认墓地中的这张卡可以被盖放到场上；在满足条件（chk==1）时登记离墓操作信息。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 登记效果处理时会将墓地的这张卡移动（离墓），使其它卡片能针对这一动作进行连锁或限制。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- ②效果处理：若墓地的这张卡仍与发动效果保持联系，则将其在自己场上里侧表示盖放。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时先确认这张卡仍与效果有联系（未被除外/移动），再执行盖放，防止墓地卡片离场后仍被错误处理。
	if c:IsRelateToEffect(e) then Duel.SSet(tp,c) end
end
-- 判定被破坏的卡在破坏前是否属于「黄金荣耀」系列、由玩家tp控制、位于主要怪兽区且表侧表示，并且破坏原因是战斗或效果。
function s.cfilter(c,tp)
	return c:IsPreviousSetCard(0x192) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousPosition(POS_FACEUP)
end
-- 全局破坏事件的处理：对玩家0和玩家1分别检查，若该玩家控制的符合s.cfilter的黄金荣耀怪兽被战破/效破，则为该玩家注册一个当回合结束（PHASE_END）时重置的标志。
function s.check(e,tp,eg,ep,ev,re,r,rp)
	for p=0,1 do
		-- 若事件组eg中存在至少一张满足s.cfilter且属于玩家p的卡，就为玩家p注册标志；该标志为RESET_PHASE+PHASE_END，因此只持续到当回合结束，正好对应②的“这个回合”条件。
		if eg:IsExists(s.cfilter,1,nil,p) then Duel.RegisterFlagEffect(p,id,RESET_PHASE+PHASE_END,0,1) end
	end
end
