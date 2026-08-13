--反発力
-- 效果：
-- 表侧攻击表示存在的怪兽为攻击对象的怪兽的攻击无效时才能发动。给与对方基本分那2只怪兽的攻击力差的数值的伤害。
function c30488793.initial_effect(c)
	-- 表侧攻击表示存在的怪兽为攻击对象的怪兽的攻击无效时才能发动。给与对方基本分那2只怪兽的攻击力差的数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetCode(EVENT_ATTACK_DISABLED)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCondition(c30488793.condition)
	e1:SetTarget(c30488793.target)
	e1:SetOperation(c30488793.activate)
	c:RegisterEffect(e1)
end
-- 检查攻击怪兽是否在怪兽区域，攻击对象是否存在且为表侧攻击表示，满足这些条件时效果才能发动。
function c30488793.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local t=Duel.GetAttackTarget()
	return a:IsLocation(LOCATION_MZONE) and t and t:IsLocation(LOCATION_MZONE) and t:IsPosition(POS_FACEUP_ATTACK)
end
-- 效果发动时：确定对方为伤害对象，计算两只怪兽攻击力差值的绝对值作为伤害数值，并登记两只怪兽及伤害信息。
function c30488793.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取进行攻击的怪兽。
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（攻击对象）。
	local t=Duel.GetAttackTarget()
	local g=Group.FromCards(a,t)
	local dam=math.abs(a:GetAttack()-t:GetAttack())
	-- 将效果的对象玩家设置为对方（1-tp）。
	Duel.SetTargetPlayer(1-tp)
	-- 将计算的伤害数值（攻击力差的绝对值）登记为连锁参数。
	Duel.SetTargetParam(dam)
	-- 将那两只怪兽登记为当前连锁的关联对象，用于效果处理时确认它们仍与效果有关。
	Duel.SetTargetCard(g)
	-- 设置操作信息：本连锁将造成伤害，对象为对方玩家，伤害数值为dam。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,0,0,1-tp,dam)
end
-- 效果处理时：从连锁中取出关联怪兽，若仍有两只且都为表侧表示，则给与对方玩家攻击力差的伤害。
function c30488793.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁登记的对象卡组，并筛选出仍与本次效果存在关联的卡。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()<2 then return end
	local c1=g:GetFirst()
	local c2=g:GetNext()
	if c1:IsFaceup() and c2:IsFaceup() then
		-- 获取当前连锁登记的对象玩家，即需要承受伤害的玩家。
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=math.abs(c1:GetAttack()-c2:GetAttack())
		-- 以效果原因给对方玩家造成dam点伤害。
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
