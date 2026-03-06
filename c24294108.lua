--燃えさかる大地
-- 效果：
-- 这张卡的发动时，场上的场地魔法卡全部破坏。此外，双方的准备阶段时，回合玩家受到500分伤害。
function c24294108.initial_effect(c)
	-- 这张卡的发动时，场上的场地魔法卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c24294108.target)
	e1:SetOperation(c24294108.activate)
	c:RegisterEffect(e1)
	-- 双方的准备阶段时，回合玩家受到500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24294108,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e2:SetTarget(c24294108.damtg)
	e2:SetOperation(c24294108.damop)
	c:RegisterEffect(e2)
end
-- 检索满足条件的场地魔法卡组
function c24294108.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上所有场地魔法卡
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	-- 设置连锁操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 发动时破坏场上所有场地魔法卡
function c24294108.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有场地魔法卡
	local g=Duel.GetFieldGroup(tp,LOCATION_FZONE,LOCATION_FZONE)
	if g:GetCount()>0 then
		-- 将场上所有场地魔法卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 准备阶段时对回合玩家造成伤害
function c24294108.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取当前回合玩家
	local cp=Duel.GetTurnPlayer()
	-- 设置连锁操作对象玩家为当前回合玩家
	Duel.SetTargetPlayer(cp)
	-- 设置连锁操作参数为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为伤害效果
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,cp,500)
end
-- 处理伤害效果
function c24294108.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁对象玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
