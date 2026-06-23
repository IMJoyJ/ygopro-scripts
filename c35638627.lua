--ワーム・ウォーロード
-- 效果：
-- 这张卡不能特殊召唤。这张卡战斗破坏的效果怪兽的效果无效化。这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击。
function c35638627.initial_effect(c)
	-- 这张卡不能特殊召唤
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏的效果怪兽的效果无效化
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BATTLED)
	e2:SetOperation(c35638627.disop)
	c:RegisterEffect(e2)
	-- 这张卡战斗破坏对方怪兽的场合，只有1次可以继续攻击
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35638627,0))
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	e3:SetCondition(c35638627.atcon)
	e3:SetOperation(c35638627.atop)
	c:RegisterEffect(e3)
end
-- 检测到战斗结束事件，获取攻击目标怪兽并判断其是否为效果怪兽且已被战斗破坏
function c35638627.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击方的攻击目标
	local tc=Duel.GetAttackTarget()
	local c=e:GetHandler()
	-- 若攻击目标为自身，则获取攻击方怪兽
	if c==tc then tc=Duel.GetAttacker() end
	if tc and tc:IsType(TYPE_EFFECT) and tc:IsStatus(STATUS_BATTLE_DESTROYED) then
		-- 使目标怪兽的效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e1)
		-- 使目标怪兽的效果无效
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+0x17a0000)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否满足连续攻击条件
function c35638627.atcon(e,tp,eg,ep,ev,re,r,rp)
	-- 满足战斗破坏条件且自身可连续攻击
	return aux.bdocon(e,tp,eg,ep,ev,re,r,rp) and e:GetHandler():IsChainAttackable()
end
-- 执行连续攻击操作
function c35638627.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使攻击卡可以再进行1次攻击
	Duel.ChainAttack()
end
