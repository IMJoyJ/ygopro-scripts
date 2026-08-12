--エネルギー吸収板
-- 效果：
-- 给与自己伤害的魔法·陷阱·效果怪兽的效果由对方发动时才能发动。自己作为受到伤害的代替而回复那个数值的基本分。
function c57006589.initial_effect(c)
	-- 给与自己伤害的魔法·陷阱·效果怪兽的效果由对方发动时才能发动。自己作为受到伤害的代替而回复那个数值的基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c57006589.condition)
	e1:SetOperation(c57006589.operation)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件（对方发动了给与自己伤害的效果）
function c57006589.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 确认发动效果的玩家是对方，且该效果是给与自己伤害的效果
	return ep~=tp and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：注册一个在当前连锁中将伤害转化为回复的领域效果
function c57006589.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发本卡发动的那个连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 自己作为受到伤害的代替而回复那个数值的基本分。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REVERSE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c57006589.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害变回复的效果注册给发动本卡的玩家
	Duel.RegisterEffect(e1,tp)
end
-- 判断当前产生伤害的效果是否为触发本卡发动的那个效果
function c57006589.refcon(e,re,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前产生伤害的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
