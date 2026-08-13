--連爆魔人
-- 效果：
-- 有魔法·陷阱卡连锁的场合，给与对方基本分500分伤害。
function c11685347.initial_effect(c)
	-- 有魔法·陷阱卡连锁的场合。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(c11685347.chop)
	c:RegisterEffect(e1)
	-- 给与对方基本分500分伤害。
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
-- 持续监听连锁发生：若当前连锁不是第1连锁且该连锁为魔法·陷阱卡的发动，则标记为满足触发条件；若为第1连锁则清除标记。
function c11685347.chop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前正在处理的连锁序号是否为1（即连锁1），若是则将标记重置为0，表示后续需要等待魔陷发动连锁。
	if Duel.GetCurrentChain()==1 then
		e:SetLabel(0)
	elseif re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		e:SetLabel(1)
	end
end
-- 连锁串结束时读取之前记录的标记：若标记为1则满足“有魔法·陷阱卡连锁”这一条件，允许发动伤害效果；同时将标记清零，避免重复触发。
function c11685347.damcon(e,tp,eg,ep,ev,re,r,rp)
	local res=e:GetLabelObject():GetLabel()
	e:GetLabelObject():SetLabel(0)
	return res==1
end
-- 伤害效果发动时的目标设定：无条件可发动，将对方玩家设为伤害对象，伤害数值设为500，并登记操作信息。
function c11685347.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为对方玩家（1-tp），即指定伤害的承受者。
	Duel.SetTargetPlayer(1-tp)
	-- 将当前连锁的对象参数设置为500，即指定伤害数值。
	Duel.SetTargetParam(500)
	-- 登记操作信息：本效果将对对方玩家造成500点伤害，分类为伤害效果，目标玩家为对方，伤害参数为500。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
-- 实际执行伤害效果：从当前连锁信息中取出伤害对象与数值，对对方造成500点效果伤害。
function c11685347.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中获取之前设置的对象玩家和参数，分别保存到局部变量p和d，用于后续伤害计算。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以“效果”为伤害原因，对玩家p造成d点基本分伤害，即实现“给与对方基本分500分伤害”。
	Duel.Damage(p,d,REASON_EFFECT)
end
