--エーリアン・ハンター
-- 效果：
-- 这张卡战斗破坏放置有A指示物的怪兽的场合，只有1次可以继续进行攻击。
function c62315111.initial_effect(c)
	-- 伤害步骤战斗结果检测：若战斗对方带有A指示物，则注册可继续攻击的标记
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetOperation(c62315111.regop)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏放置有A指示物的怪兽的场合才能发动。这张卡只1次可以继续攻击。
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
-- 伤害步骤处理：确认战斗对方怪兽是否带有A指示物并给自身注册标记
function c62315111.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:GetCounter(0x100e)>0 then
		c:RegisterFlagEffect(62315111,RESET_PHASE+PHASE_DAMAGE,0,1)
	end
end
-- ①效果发动条件：战斗破坏对方怪兽送去墓地、自身可以继续攻击且带有对应Flag标记
function c62315111.atcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断战斗破坏条件、能否连续攻击以及是否存在A指示物战斗记录标记
	return aux.bdcon(e,tp,eg,ep,ev,re,r,rp) and c:IsChainAttackable() and c:GetFlagEffect(62315111)~=0
end
-- ①效果处理：进行追加攻击
function c62315111.atop(e,tp,eg,ep,ev,re,r,rp)
	-- 使此卡可以继续攻击
	Duel.ChainAttack()
end
