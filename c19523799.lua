--昼夜の大火事
-- 效果：
-- 给与对方基本分800分伤害。
function c19523799.initial_effect(c)
	-- 给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c19523799.damtg)
	e1:SetOperation(c19523799.damop)
	c:RegisterEffect(e1)
end
-- 设置伤害效果的目标玩家为对方
function c19523799.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为800
	Duel.SetTargetParam(800)
	-- 设置连锁操作信息为伤害效果，对象玩家为对方，伤害值为800
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 执行伤害效果的处理函数
function c19523799.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
