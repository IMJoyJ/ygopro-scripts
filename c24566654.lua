--クリムゾン・ヘルフレア
-- 效果：
-- 自己场上有「红莲魔龙」存在，给与自己伤害的魔法·陷阱卡由对方发动时才能发动。作为自己受到的那个效果伤害的代替，对方受到那个数值2倍的伤害。
function c24566654.initial_effect(c)
	-- 记录此卡具有「红莲魔龙」的卡名
	aux.AddCodeList(c,70902743)
	-- 自己场上有「红莲魔龙」存在，给与自己伤害的魔法·陷阱卡由对方发动时才能发动。作为自己受到的那个效果伤害的代替，对方受到那个数值2倍的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c24566654.condition)
	e1:SetOperation(c24566654.operation)
	c:RegisterEffect(e1)
end
-- 检查场上是否存在表侧表示的「红莲魔龙」
function c24566654.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 检查连锁是否为对方发动的魔法·陷阱卡且自己受到伤害
function c24566654.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在表侧表示的「红莲魔龙」且发动者不是自己且发动的是魔法·陷阱卡
	return Duel.IsExistingMatchingCard(c24566654.cfilter,tp,LOCATION_ONFIELD,0,1,nil) and ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 检查是否受到来自效果的伤害
		and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 将此卡注册为发动效果
function c24566654.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 创建反射伤害效果并注册
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c24566654.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将反射伤害效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	-- 创建伤害翻倍效果并注册
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetLabel(cid)
	e2:SetValue(c24566654.dammul)
	e2:SetReset(RESET_CHAIN)
	-- 将伤害翻倍效果注册给玩家
	Duel.RegisterEffect(e2,tp)
end
-- 判断是否为当前连锁的反射伤害效果
function c24566654.refcon(e,re,val,r,rp,rc)
	-- 获取当前处理中的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
-- 判断是否为当前连锁的伤害翻倍效果
function c24566654.dammul(e,re,val,r,rp,rc)
	-- 获取当前处理中的连锁序号
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and val*2 or val
end
