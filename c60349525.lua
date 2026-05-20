--クラッキング・ドラゴン
-- 效果：
-- ①：这张卡不会被和持有这张卡的等级以下的等级的怪兽的战斗破坏。
-- ②：这张卡在怪兽区域存在，对方只把怪兽1只召唤·特殊召唤时才能发动。那只怪兽的攻击力直到回合结束时下降那个等级×200，给与对方下降数值的伤害。
function c60349525.initial_effect(c)
	-- ①：这张卡不会被和持有这张卡的等级以下的等级的怪兽的战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(c60349525.indval)
	c:RegisterEffect(e1)
	-- ②：这张卡在怪兽区域存在，对方只把怪兽1只召唤·特殊召唤时才能发动。那只怪兽的攻击力直到回合结束时下降那个等级×200，给与对方下降数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(60349525,0))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c60349525.condition)
	e2:SetTarget(c60349525.target)
	e2:SetOperation(c60349525.operation)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 判定与这张卡进行战斗的怪兽等级是否在这张卡的等级以下
function c60349525.indval(e,c)
	return c:IsLevelBelow(e:GetHandler():GetLevel())
end
-- 检查是否为对方仅召唤·特殊召唤了1只表侧表示且有等级的怪兽，且该怪兽不是自身
function c60349525.condition(e,tp,eg,ep,ev,re,r,rp)
	if eg:GetCount()~=1 then return false end
	local tc=eg:GetFirst()
	return tc~=e:GetHandler() and tc:IsFaceup() and tc:GetLevel()>0 and tc:IsSummonPlayer(1-tp)
end
-- 效果发动的目标确认，并注册给与对方伤害的操作信息
function c60349525.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置给与对方该怪兽等级×200伤害的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,eg:GetFirst():GetLevel()*200)
end
-- 使召唤·特殊召唤的怪兽攻击力下降其等级×200，并给与对方实际下降数值的伤害
function c60349525.operation(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE) and not tc:IsImmuneToEffect(e) then
		local atk=tc:GetAttack()
		local nv=math.min(atk,tc:GetLevel()*200)
		-- 那只怪兽的攻击力直到回合结束时下降那个等级×200
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(-tc:GetLevel()*200)
		tc:RegisterEffect(e1)
		if not tc:IsHasEffect(EFFECT_REVERSE_UPDATE) then
			-- 给与对方等同于攻击力实际下降数值的伤害
			Duel.Damage(1-tp,nv,REASON_EFFECT)
		end
	end
end
