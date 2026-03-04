--連爆魔人
-- 效果：
-- 有魔法·陷阱卡连锁的场合，给与对方基本分500分伤害。
function c11685347.initial_effect(c)
	-- 有魔法·陷阱卡连锁的场合，给与对方基本分500分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c11685347.chop)
	c:RegisterEffect(e1)
	-- 有魔法·陷阱卡连锁的场合，给与对方基本分500分伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11685347,0))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_CHAIN_END)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c11685347.damcon)
	e2:SetTarget(c11685347.damtg)
	e2:SetOperation(c11685347.damop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 连锁发动时的处理函数
function c11685347.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前连锁是否为第一连锁
	if Duel.GetCurrentChain()==1 then
		e:SetLabel(0)
	elseif re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:SetLabel(1)
	end
end
-- 伤害效果发动条件判断函数
function c11685347.damcon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 伤害效果的宣言函数
function c11685347.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为500
	Duel.SetTargetParam(500)
	-- 设置连锁操作信息为造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 伤害效果的处理函数
function c11685347.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
