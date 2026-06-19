--火之迦具土
-- 效果：
-- 这张卡不能特殊召唤。召唤·反转的回合的结束阶段时回到持有者手卡。此外，这张卡给与对方玩家战斗伤害时发动。下个回合的抽卡阶段的抽卡前对方把全部手卡丢弃。
function c75745607.initial_effect(c)
	-- 注册灵魂怪兽在召唤、反转成功的回合结束阶段回到持有者手卡的效果
	aux.EnableSpiritReturn(c,EVENT_SUMMON_SUCCESS,EVENT_FLIP)
	-- 这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件为不可特殊召唤（始终返回false）
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	-- 此外，这张卡给与对方玩家战斗伤害时发动。下个回合的抽卡阶段的抽卡前对方把全部手卡丢弃。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(75745607,1))
	e4:SetCategory(CATEGORY_HANDES_OPPO)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(c75745607.hdcon)
	e4:SetOperation(c75745607.hdreg)
	c:RegisterEffect(e4)
end
-- 判断受到战斗伤害的玩家是否为对方玩家
function c75745607.hdcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 在给与对方战斗伤害时，注册一个持续到下个回合结束、在抽卡阶段抽卡前触发的延迟效果
function c75745607.hdreg(e,tp,eg,ep,ev,re,r,rp)
	-- 下个回合的抽卡阶段的抽卡前对方把全部手卡丢弃。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PREDRAW)
	e1:SetReset(RESET_PHASE+PHASE_END,2)
	e1:SetOperation(c75745607.hdop)
	-- 将该延迟触发的效果注册给全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 在下个回合抽卡前，执行将对方全部手牌丢弃的操作
function c75745607.hdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方玩家的全部手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 将对方的全部手牌以效果丢弃的形式送去墓地
		Duel.SendtoGrave(g,REASON_DISCARD+REASON_EFFECT)
	end
end
