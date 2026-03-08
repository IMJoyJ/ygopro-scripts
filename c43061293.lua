--ファイアーダーツ
-- 效果：
-- 自己手卡0张的时候才能发动。投掷3次骰子。给与对方基本分那个投掷结果的合计数目×100数值的伤害。
function c43061293.initial_effect(c)
	-- 自己手卡0张的时候才能发动。投掷3次骰子。给与对方基本分那个投掷结果的合计数目×100数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DICE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c43061293.damcon)
	e1:SetTarget(c43061293.damtg)
	e1:SetOperation(c43061293.damop)
	c:RegisterEffect(e1)
end
-- 效果作用
function c43061293.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己手卡是否为0张
	return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0
end
-- 效果作用
function c43061293.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁对象玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁操作信息为投掷3次骰子
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,3)
	-- 设置连锁操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
-- 效果作用
function c43061293.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象玩家
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 投掷3次骰子并获取结果
	local d1,d2,d3=Duel.TossDice(tp,3)
	-- 对对方造成骰子点数合计乘以100的伤害
	Duel.Damage(p,(d1+d2+d3)*100,REASON_EFFECT)
end
