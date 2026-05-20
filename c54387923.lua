--シドレミコード・ビューティア
-- 效果：
-- ←2 【灵摆】 2→
-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。这个回合，那张卡从场上离开的场合除外。自己的灵摆区域有偶数的灵摆刻度存在的场合，也能以对方场上1张表侧表示的魔法·陷阱卡为对象。
-- ②：1回合1次，这张卡和持有自己的灵摆区域的最低灵摆刻度×300以上的攻击力的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
function c54387923.initial_effect(c)
	-- 为卡片注册灵摆怪兽属性（灵摆召唤、灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCondition(c54387923.actcon)
	e1:SetOperation(c54387923.actop)
	c:RegisterEffect(e1)
	-- ①：在自己的「七音服」灵摆怪兽的灵摆召唤成功时对方不能把怪兽的效果·魔法·陷阱卡发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetOperation(c54387923.subop)
	c:RegisterEffect(e2)
	-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。这个回合，那张卡从场上离开的场合除外。自己的灵摆区域有偶数的灵摆刻度存在的场合，也能以对方场上1张表侧表示的魔法·陷阱卡为对象。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(54387923,0))  --"选择卡片离场除外"
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,54387923)
	e3:SetTarget(c54387923.rmtg)
	e3:SetOperation(c54387923.rmop)
	c:RegisterEffect(e3)
	-- ②：1回合1次，这张卡和持有自己的灵摆区域的最低灵摆刻度×300以上的攻击力的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(54387923,2))  --"对方怪兽破坏"
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetCountLimit(1)
	e4:SetCondition(c54387923.descon)
	e4:SetTarget(c54387923.destg)
	e4:SetOperation(c54387923.desop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的、灵摆召唤成功的「七音服」灵摆怪兽
function c54387923.actfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsSetCard(0x162) and c:IsType(TYPE_PENDULUM) and c:IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 检查是否有自己的「七音服」灵摆怪兽灵摆召唤成功
function c54387923.actcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c54387923.actfilter,1,nil,tp)
end
-- 在灵摆召唤成功时，若当前连锁为0则直接限制对方发动卡的效果；若当前连锁为1则注册标记并添加连锁中重置标记的效果
function c54387923.actop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前是否没有其他卡片或效果在处理连锁（即灵摆召唤成功后直接进入时点）
	if Duel.GetCurrentChain()==0 then
		-- 设定直到连锁结束为止对方不能发动怪兽效果、魔法、陷阱卡
		Duel.SetChainLimitTillChainEnd(c54387923.chlimit)
	-- 判断当前连锁是否为1（即有诱发效果在灵摆召唤成功时发动）
	elseif Duel.GetCurrentChain()==1 then
		c:RegisterFlagEffect(54387923,RESET_EVENT+RESETS_STANDARD,0,1)
		-- ①：自己·对方回合，以对方场上1只效果怪兽为对象才能发动。这个回合，那张卡从场上离开的场合除外。自己的灵摆区域有偶数的灵摆刻度存在的场合，也能以对方场上1张表侧表示的魔法·陷阱卡为对象。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetOperation(c54387923.resetop)
		-- 在全局环境注册一个在有连锁发动时重置标记的效果
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EVENT_BREAK_EFFECT)
		e2:SetReset(RESET_CHAIN)
		-- 在全局环境注册一个在效果处理中途被中断时重置标记的效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 在有连锁发动或效果处理中断时，重置卡片的标记并使该重置效果自身失效
function c54387923.resetop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:ResetFlagEffect(54387923)
	e:Reset()
end
-- 在连锁结束时，如果卡片仍持有标记，则继续限制对方直到连锁结束
function c54387923.subop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(54387923)~=0 then
		-- 设定直到连锁结束为止对方不能发动怪兽效果、魔法、陷阱卡
		Duel.SetChainLimitTillChainEnd(c54387923.chlimit)
	end
end
-- 限制对方玩家不能发动怪兽效果，以及不能发动魔法·陷阱卡（不限制已在场上的魔陷的效果发动）
function c54387923.chlimit(e,ep,tp)
	return ep==tp or e:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not e:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 过滤对方场上的表侧表示效果怪兽，若自己灵摆区有偶数刻度，则也可以过滤表侧表示的魔法·陷阱卡
function c54387923.rfilter(c,szone)
	return c:IsFaceup() and (c:IsType(TYPE_EFFECT) or szone and c:IsType(TYPE_SPELL+TYPE_TRAP))
end
-- 过滤自己灵摆区中刻度为偶数的卡
function c54387923.pfilter(c)
	return c:GetCurrentScale()%2==0
end
-- 怪兽①效果的发动准备，检测并选择对方场上1只表侧表示效果怪兽（或在满足条件时选择1张表侧表示魔陷）作为对象
function c54387923.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己的灵摆区域是否存在偶数灵摆刻度的卡
	local szone=Duel.IsExistingMatchingCard(c54387923.pfilter,tp,LOCATION_PZONE,0,1,nil)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and c54387923.rfilter(chkc,szone) end
	-- 在效果发动时，检查对方场上是否存在可以作为效果对象的合法卡片
	if chk==0 then return Duel.IsExistingTarget(c54387923.rfilter,tp,0,LOCATION_ONFIELD,1,nil,szone) end
	-- 向玩家发送提示信息，要求选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家选择对方场上1张满足条件的卡作为效果的对象
	Duel.SelectTarget(tp,c54387923.rfilter,tp,0,LOCATION_ONFIELD,1,1,nil,szone)
end
-- 怪兽①效果的处理，为作为对象的卡注册一个离场时除外的重定向效果
function c54387923.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- ②：1回合1次，这张卡和持有自己的灵摆区域的最低灵摆刻度×300以上的攻击力的怪兽进行战斗的伤害步骤开始时发动。那只怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(54387923,1))  --"「西之七音服·比蒂娅」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT+RESET_PHASE+PHASE_END)
		e1:SetValue(LOCATION_REMOVED)
		tc:RegisterEffect(e1,true)
	end
end
-- 怪兽②效果的发动条件，检查与这张卡进行战斗的对方怪兽的攻击力是否在自己灵摆区最低灵摆刻度×300以上
function c54387923.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if not (bc and bc:IsFaceup()) then return false end
	-- 获取自己灵摆区域的所有卡
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	if g:GetCount()==0 then return false end
	local _,min=g:GetMinGroup(Card.GetCurrentScale)
	return bc:IsAttackAbove(min*300)
end
-- 怪兽②效果的发动准备，将进行战斗的对方怪兽设为破坏操作的对象
function c54387923.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	-- 设置连锁的操作信息，表明该效果将破坏1只与这张卡进行战斗的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- 怪兽②效果的处理，将与这张卡进行战斗的对方怪兽破坏
function c54387923.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc:IsRelateToBattle() then
		-- 因效果将与这张卡进行战斗的对方怪兽破坏
		Duel.Destroy(bc,REASON_EFFECT)
	end
end
