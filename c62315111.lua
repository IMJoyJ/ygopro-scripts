--エーリアン・ハンター
-- 效果：
-- 这张卡战斗破坏放置有A指示物的怪兽的场合，只有1次可以继续进行攻击。
function c62315111.initial_effect(c)
	-- 放置有A指示物的怪兽的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c62315111.regop)
	c:RegisterEffect(e1)
	-- 这张卡战斗破坏...的场合，只有1次可以继续进行攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62315111,0))  --"继续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c62315111.atcon)
	e2:SetOperation(c62315111.atop)
	c:RegisterEffect(e2)
end
-- 在伤害计算后，若战斗对象存在且放置有A指示物，则给自身注册一个在伤害步骤结束时重置的标记
function c62315111.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:GetCounter(0x100e)>0 then
		c:RegisterFlagEffect(62315111,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 判断是否满足发动条件：自身战斗破坏怪兽、可以进行连续攻击，且存在伤害步骤内注册的特定标记
function c62315111.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回是否满足：自身战斗破坏怪兽、可以继续攻击、且存在代表战斗对象有A指示物的标记
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable() and c:GetFlagEffect(62315111)~=0
end
-- 连续攻击效果的处理函数
function c62315111.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使该怪兽可以再进行1次攻击
	Duel.ChainAttack()
end
