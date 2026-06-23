--コザッキーの自爆装置
-- 效果：
-- 给与破坏盖放的这张卡的玩家1000分伤害。
function c21908319.initial_effect(c)
	-- 给与破坏盖放的这张卡的玩家1000分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21908319,0))  --"1000伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetCondition(c21908319.damcon)
	e1:SetTarget(c21908319.damtg)
	e1:SetOperation(c21908319.damop)
	c:RegisterEffect(e1)
end
-- 破坏时的卡必须在魔陷区且为背面表示
function c21908319.damcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_SZONE) and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
-- 设置连锁处理目标玩家为破坏时的玩家，设置连锁处理目标参数为1000点伤害
function c21908319.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁处理的目标玩家为破坏时的玩家
	Duel.SetTargetPlayer(rp)
	-- 设置连锁处理的目标参数为1000点伤害
	Duel.SetTargetParam(1000)
	-- 设置连锁操作信息为伤害效果，目标玩家为破坏时的玩家，伤害值为1000
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,rp,1000)
end
-- 执行伤害效果，对目标玩家造成1000点伤害
function c21908319.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁处理的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害值的伤害，伤害原因为效果
	Duel.Damage(p,d,REASON_EFFECT)
end
