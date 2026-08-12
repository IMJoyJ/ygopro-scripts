--Ai打ち
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己和对方的怪兽之间进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力只在那次伤害计算时变成和那只对方怪兽的攻击力相同，那次伤害步骤结束时那次战斗破坏的怪兽的控制者受到那原本攻击力数值的伤害。
-- ②：自己的「@火灵天星」怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
function c86449372.initial_effect(c)
	-- ①：自己和对方的怪兽之间进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力只在那次伤害计算时变成和那只对方怪兽的攻击力相同，那次伤害步骤结束时那次战斗破坏的怪兽的控制者受到那原本攻击力数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,86449372+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c86449372.condition)
	e1:SetOperation(c86449372.activate)
	c:RegisterEffect(e1)
	-- ②：自己的「@火灵天星」怪兽被战斗破坏的场合，可以作为代替把墓地的这张卡除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetTarget(c86449372.reptg)
	e2:SetValue(c86449372.repval)
	e2:SetOperation(c86449372.repop)
	c:RegisterEffect(e2)
end
-- 判断是否满足发动条件：自己和对方的怪兽之间进行战斗的伤害计算时
function c86449372.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前进行战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return a and d and a:IsFaceup() and d:IsFaceup()
end
-- 效果①的发动处理：使自己怪兽的攻击力在伤害计算时与对方怪兽相同，并注册伤害步骤结束时造成伤害的效果
function c86449372.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前进行战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取当前进行战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	if a:IsControler(1-tp) then a,d=d,a end
	if a:IsFaceup() and a:IsRelateToBattle() and d:IsFaceup() and d:IsRelateToBattle() then
		-- 那只自己怪兽的攻击力只在那次伤害计算时变成和那只对方怪兽的攻击力相同
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(d:GetAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		a:RegisterEffect(e1)
		local g=Group.FromCards(a,d)
		g:KeepAlive()
		-- 那次伤害步骤结束时那次战斗破坏的怪兽的控制者受到那原本攻击力数值的伤害。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_BATTLED)
		e2:SetLabelObject(g)
		e2:SetOperation(c86449372.damop)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		-- 注册在伤害步骤结束时（伤害计算后）触发的全局延迟效果
		Duel.RegisterEffect(e2,tp)
	end
end
-- 伤害步骤结束时，对被战斗破坏的怪兽的控制者造成该怪兽原本攻击力数值的伤害
function c86449372.damop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(Card.IsStatus,nil,STATUS_BATTLE_DESTROYED)
	local tc1=tg:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=tg:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc1 then
		-- 对自身造成自身被破坏怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(tp,tc1:GetBaseAttack(),REASON_EFFECT,true)
	end
	if tc2 then
		-- 对对方造成对方被破坏怪兽原本攻击力数值的伤害（分步处理）
		Duel.Damage(1-tp,tc2:GetBaseAttack(),REASON_EFFECT,true)
	end
	-- 触发并完成伤害/恢复生命值的时点
	Duel.RDComplete()
	g:DeleteGroup()
end
-- 过滤满足被战斗破坏的自己场上的「@火灵天星」怪兽
function c86449372.repfilter(c,tp)
	return c:IsFaceup() and c:IsControler(tp) and c:IsLocation(LOCATION_MZONE)
		and c:IsSetCard(0x135) and c:IsReason(REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 代替破坏的靶向与条件判断：检查墓地的这张卡是否可以除外以代替自己场上的「@火灵天星」怪兽被战斗破坏，并询问玩家是否发动
function c86449372.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c86449372.repfilter,1,nil,tp) and e:GetHandler():IsAbleToRemove() end
	-- 询问玩家是否发动代替破坏的效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 确定代替破坏的目标怪兽符合过滤条件
function c86449372.repval(e,c)
	return c86449372.repfilter(c,e:GetHandlerPlayer())
end
-- 代替破坏的执行操作：将墓地的这张卡除外
function c86449372.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将墓地的这张卡除外作为代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
