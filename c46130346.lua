--ファイヤー・ボール
-- 效果：
-- ①：给与对方500伤害。
function c46130346.initial_effect(c)
	-- ①：给与对方500伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c46130346.damtg)
	e1:SetOperation(c46130346.damop)
	c:RegisterEffect(e1)
end
-- 设置伤害效果的发动条件和目标
function c46130346.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将连锁的目标玩家设置为对手
	Duel.SetTargetPlayer(1-tp)
	-- 将连锁的目标参数设置为500点伤害
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息为对对手造成500点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 执行伤害效果的处理函数
function c46130346.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定点数的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
