--ポイズンマミー
-- 效果：
-- 反转：给与对方500基本分伤害。
function c43716289.initial_effect(c)
	-- 反转：给与对方500基本分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43716289,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c43716289.target)
	e1:SetOperation(c43716289.operation)
	c:RegisterEffect(e1)
end
-- 定义反转效果的发动条件检查与目标设置逻辑，确认发动后设定伤害对象为对方、数值为500，并注册伤害操作信息。
function c43716289.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前处理连锁的对象玩家设置为对方玩家。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前处理连锁的对象参数设置为500。
	Duel.SetTargetParam(500)
	-- 设置当前连锁的操作信息：效果分类为伤害，目标玩家为对方，参数为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 定义效果处理函数，用于在效果结算时执行具体的伤害操作。
function c43716289.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁信息中的对象玩家和对象参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果为原因给予对方玩家500点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
