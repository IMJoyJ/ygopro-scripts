--オッドアイズ・ファントム・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，另一边的自己的灵摆区域有「异色眼」卡存在的场合，自己的表侧表示怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到战斗阶段结束时上升1200。
-- 【怪兽效果】
-- 「异色眼幻影龙」的怪兽效果1回合只能使用1次。
-- ①：灵摆召唤的这张卡的攻击给与对方战斗伤害时才能发动。给与对方为自己的灵摆区域的「异色眼」卡数量×1200伤害。
function c93149655.initial_effect(c)
	-- 注册灵摆怪兽的灵摆召唤及灵摆卡的发动等基本属性。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，另一边的自己的灵摆区域有「异色眼」卡存在的场合，自己的表侧表示怪兽和对方怪兽进行战斗的攻击宣言时才能发动。那只自己怪兽的攻击力直到战斗阶段结束时上升1200。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(93149655,0))  --"攻击力上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c93149655.atkcon)
	e1:SetTarget(c93149655.atktg)
	e1:SetOperation(c93149655.atkop)
	c:RegisterEffect(e1)
	-- 「异色眼幻影龙」的怪兽效果1回合只能使用1次。①：灵摆召唤的这张卡的攻击给与对方战斗伤害时才能发动。给与对方为自己的灵摆区域的「异色眼」卡数量×1200伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(93149655,1))  --"效果伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCountLimit(1,93149655)
	e2:SetCondition(c93149655.damcon)
	e2:SetTarget(c93149655.damtg)
	e2:SetOperation(c93149655.damop)
	c:RegisterEffect(e2)
end
-- 灵摆效果发动条件：检查另一边灵摆区是否有「异色眼」卡，并确认是否为自己表侧表示怪兽与对方怪兽进行战斗的攻击宣言时，同时记录进行战斗的自己怪兽。
function c93149655.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查另一边的自己的灵摆区域是否存在「异色眼」卡（不包含自身），若不存在则无法发动。
	if not Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,e:GetHandler(),0x99) then return end
	-- 获取本次战斗的攻击怪兽。
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽（攻击对象）。
	local d=Duel.GetAttackTarget()
	if d and a:GetControler()~=d:GetControler() then
		if a:IsControler(tp) and a:IsFaceup() then e:SetLabelObject(a)
		elseif d:IsFaceup() then e:SetLabelObject(d)
		else return false end
		return true
	else return false end
end
-- 灵摆效果的目标选择：确认进行战斗的自己怪兽是否在场，并将其设为效果处理的对象。
function c93149655.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=e:GetLabelObject()
	if chk==0 then return tc:IsOnField() end
	-- 将进行战斗的自己怪兽设为当前连锁的效果处理对象。
	Duel.SetTargetCard(tc)
end
-- 灵摆效果处理：使作为对象的自己怪兽的攻击力直到战斗阶段结束时上升1200。
function c93149655.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 那只自己怪兽的攻击力直到战斗阶段结束时上升1200。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
end
-- 怪兽效果发动条件：给与对方战斗伤害时，且这张卡是灵摆召唤的，并且这张卡是攻击怪兽。
function c93149655.damcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
		-- 检查本次战斗的攻击怪兽是否为这张卡自身。
		and Duel.GetAttacker()==e:GetHandler()
end
-- 过滤函数：筛选自己灵摆区域表侧表示的「异色眼」卡。
function c93149655.damfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x99)
end
-- 怪兽效果的目标选择：计算自己灵摆区域的「异色眼」卡数量，并设置给与对方伤害的效果参数和操作信息。
function c93149655.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 计算自己灵摆区域表侧表示的「异色眼」卡数量。
	local ct=Duel.GetMatchingGroupCount(c93149655.damfilter,tp,LOCATION_PZONE,0,nil)
	if chk==0 then return ct>0 end
	-- 将计算出的伤害数值（数量×1200）设为效果处理的参数。
	Duel.SetTargetParam(ct*1200)
	-- 设置当前连锁的操作信息为“给与对方玩家对应数值的伤害”。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*1200)
end
-- 怪兽效果处理：给与对方自己灵摆区域的「异色眼」卡数量×1200的伤害。
function c93149655.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，重新计算自己灵摆区域表侧表示的「异色眼」卡数量。
	local ct=Duel.GetMatchingGroupCount(c93149655.damfilter,tp,LOCATION_PZONE,0,nil)
	-- 以效果伤害的形式给与对方玩家对应数值的伤害。
	Duel.Damage(1-tp,ct*1200,REASON_EFFECT)
end
