--痛魂の呪術
-- 效果：
-- ①：给与自己伤害的效果由对方发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
function c76714458.initial_effect(c)
	-- ①：给与自己伤害的效果由对方发动时才能发动。那个效果发生的对自己的效果伤害由对方代受。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c76714458.condition)
	e1:SetOperation(c76714458.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：对方发动了给与自己伤害的效果
function c76714458.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断发动效果的玩家是否为对方，且该效果是否为给与自己伤害的效果
	return ep~=tp and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：注册一个在当前连锁结算期间适用的伤害反射效果，使原本由自己承受的效果伤害改由对方承受
function c76714458.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发该效果的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 那个效果发生的对自己的效果伤害由对方代受。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c76714458.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害反射效果注册给玩家自己
	Duel.RegisterEffect(e1,tp)
end
-- 伤害反射效果的过滤函数，用于判断当前发生的伤害是否为该连锁产生的效果伤害
function c76714458.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
