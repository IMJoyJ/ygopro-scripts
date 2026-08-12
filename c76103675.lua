--火の粉
-- 效果：
-- 给与对方基本分200分伤害。
function c76103675.initial_effect(c)
	-- 给与对方基本分200分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c76103675.damtg)
	e1:SetOperation(c76103675.damop)
	c:RegisterEffect(e1)
end
-- 效果发动的目标确认，设置目标玩家为对方，伤害数值为200，并向系统宣告伤害操作
function c76103675.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置当前连锁的对象参数为200
	Duel.SetTargetParam(200)
	-- 设置当前连锁的操作信息，向系统宣告将要给与对方200分伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,200)
end
-- 效果处理的执行，获取目标玩家和伤害数值并执行伤害处理
function c76103675.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数（伤害数值）
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因给与目标玩家对应的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
