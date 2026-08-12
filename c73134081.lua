--火あぶりの刑
-- 效果：
-- 给与对方基本分600分的伤害。
function c73134081.initial_effect(c)
	-- 给与对方基本分600分的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c73134081.damtg)
	e1:SetOperation(c73134081.damop)
	c:RegisterEffect(e1)
end
-- 设置伤害效果的目标玩家与操作信息
function c73134081.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数（伤害值）为600
	Duel.SetTargetParam(600)
	-- 设置当前连锁的操作信息为：给与对方600点的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
-- 执行伤害效果处理
function c73134081.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁设定的对象玩家及伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 因效果给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
