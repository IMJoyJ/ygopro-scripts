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
-- 效果作用
function c43716289.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将对方玩家设置为效果的对象
	Duel.SetTargetPlayer(1-tp)
	-- 将伤害值设置为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为造成500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 效果作用
function c43716289.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
