--防御輪
-- 效果：
-- 陷阱卡的效果的伤害为0。
function c58641905.initial_effect(c)
	-- 陷阱卡的效果的伤害为0。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c58641905.condition)
	e1:SetOperation(c58641905.operation)
	c:RegisterEffect(e1)
end
-- 检查发动效果的卡是否为陷阱卡，且该效果是否会造成伤害
function c58641905.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_TRAP) then return false end
	-- 检查该效果是否会造成伤害
	return aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 获取当前连锁的ID，并注册一个在当前连锁内将该陷阱卡效果伤害变为0的全局效果
function c58641905.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取触发效果的连锁唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 陷阱卡的效果的伤害为0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,1)
	e1:SetLabel(cid)
	e1:SetValue(c58641905.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将改变伤害的效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 伤害改变的价值函数，判断当前造成伤害的连锁ID是否与被防御轮锁定的连锁ID一致，若一致则将效果伤害变为0
function c58641905.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前处理连锁的唯一标识（连锁ID）
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	if cid==e:GetLabel() then return 0 end
	return val
end
