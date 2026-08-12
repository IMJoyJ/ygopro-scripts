--原子ホタル
-- 效果：
-- 战斗破坏以表侧表示存在于场上的这张卡的玩家受到1000点伤害。
function c87340664.initial_effect(c)
	-- 战斗破坏以表侧表示存在于场上的这张卡的玩家受到1000点伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(87340664,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c87340664.condition)
	e1:SetTarget(c87340664.target)
	e1:SetOperation(c87340664.operation)
	c:RegisterEffect(e1)
end
-- 判断是否是被战斗破坏且破坏前在场上表侧表示，并记录造成破坏的玩家
function c87340664.condition(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(e:GetHandler():GetReasonPlayer())
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():IsPreviousPosition(POS_FACEUP)
end
-- 设置效果的对象玩家为造成破坏的玩家，对象参数为1000，并注册伤害操作信息
function c87340664.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将造成破坏的玩家设置为效果的对象玩家
	Duel.SetTargetPlayer(e:GetLabel())
	-- 将伤害数值1000设置为效果的对象参数
	Duel.SetTargetParam(1000)
	-- 设置效果处理信息为给与目标玩家1000点伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,e:GetLabel(),1000)
end
-- 效果处理，获取目标玩家和伤害数值并执行伤害操作
function c87340664.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中设定的对象玩家和对象参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家对应的效果伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
