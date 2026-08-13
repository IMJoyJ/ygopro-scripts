--エーリアン・ハンター
-- 效果：
-- 这张卡战斗破坏放置有A指示物的怪兽的场合，只有1次可以继续进行攻击。
function c62315111.initial_effect(c)
	-- 这张卡战斗破坏放置有A指示物的怪兽的场合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c62315111.regop)
	c:RegisterEffect(e1)
	-- 只有1次可以继续进行攻击
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62315111,0))  --"继续攻击"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(c62315111.atcon)
	e2:SetOperation(c62315111.atop)
	c:RegisterEffect(e2)
end
c62315111.mentioned_counter={
	[0x100e]=true,
}
-- 伤害计算后处理：若这张卡的战斗对象放置有A指示物（0x100e），则为这张卡注册标识效果（伤害步骤结束时重置），记录本回合与放置有A指示物的怪兽进行过战斗
function c62315111.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:GetCounter(0x100e)>0 then
		c:RegisterFlagEffect(62315111,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- 发动条件函数：确认这张卡与本次战斗有关、可以进行连续攻击，且带有「regop」注册的标识（即本次战斗破坏了放置有A指示物的怪兽）
function c62315111.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 返回条件判断：这张卡与本次战斗有关、攻击宣言次数未达上限可以连续攻击、且已注册过与A指示物怪兽战斗的标识
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable() and c:GetFlagEffect(62315111)~=0
end
-- 效果处理：使这张卡可以再进行1次攻击
function c62315111.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使这张卡可以再进行1次攻击
	Duel.ChainAttack()
end
