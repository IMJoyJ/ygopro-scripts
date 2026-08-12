--地獄の扉越し銃
-- 效果：
-- 给与战斗伤害以外的伤害的效果发动时才能发动这张卡。将自己所受的伤害转给对方。
function c78783370.initial_effect(c)
	-- 给与战斗伤害以外的伤害的效果发动时才能发动这张卡。将自己所受的伤害转给对方。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c78783370.condition)
	e1:SetOperation(c78783370.operation)
	c:RegisterEffect(e1)
end
-- 判断发动连锁的效果是否为给与自己伤害的效果（包括因回复变伤害效果导致自己受伤害的情况）
function c78783370.condition(e,tp,eg,ep,ev,re,r,rp)
	if re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁中关于给与伤害的操作信息
	local ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_DAMAGE)
	if ex and (cp==tp or cp==PLAYER_ALL) then return true end
	-- 获取当前连锁中关于回复生命值的操作信息
	ex,cg,ct,cp,cv=Duel.GetOperationInfo(ev,CATEGORY_RECOVER)
	-- 若为回复效果，且对象包含自己，且自己受到“回复转伤害”效果的影响，则判定为会受到伤害，满足发动条件
	return ex and (cp==tp or cp==PLAYER_ALL) and Duel.IsPlayerAffectedByEffect(tp,EFFECT_REVERSE_RECOVER)
end
-- 效果处理时，注册一个在当前连锁中将自己受到的效果伤害转移给对方的效果
function c78783370.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发本卡发动的那个连锁的唯一连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 将自己所受的伤害转给对方。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c78783370.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害反射效果注册给发动本卡效果的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前造成伤害的连锁ID是否与触发本卡发动的连锁ID一致，且伤害原因为效果伤害，若是则进行反射
function c78783370.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
