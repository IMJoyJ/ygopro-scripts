--クリムゾン・ヘルフレア
-- 效果：
-- 自己场上有「红莲魔龙」存在，给与自己伤害的魔法·陷阱卡由对方发动时才能发动。作为自己受到的那个效果伤害的代替，对方受到那个数值2倍的伤害。
function c24566654.initial_effect(c)
	-- 注册本卡效果文本中记述的卡名「红莲魔龙」(70902743)，使该卡名与本体建立关联，用于满足发动条件时的场上检索判定。
	aux.AddCodeList(c,70902743)
	-- 自己场上有「红莲魔龙」存在，给与自己伤害的魔法·陷阱卡由对方发动时才能发动。作为自己受到的那个效果伤害的代替，对方受到那个数值2倍的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(c24566654.condition)
	e1:SetOperation(c24566654.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡片是否为表侧表示且卡名是「红莲魔龙」(70902743)，用于确认己方场上是否存在该怪兽。
function c24566654.cfilter(c)
	return c:IsFaceup() and c:IsCode(70902743)
end
-- 发动条件判断：己方场上有表侧「红莲魔龙」存在，效果由对方玩家发动且为魔法·陷阱卡的发动，并且该连锁会给己方造成效果伤害时，才可发动。
function c24566654.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方场上存在表侧「红莲魔龙」；发动玩家不是己方；且发动的是魔法·陷阱卡的激活效果。
	return Duel.IsExistingMatchingCard(c24566654.cfilter,tp,LOCATION_ONFIELD,0,1,nil) and ep~=tp and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		-- 调用伤害判断函数aux.damcon1，确认对方连锁的效果会使己方受到效果伤害（或满足反转伤害等情形），对应“给与自己伤害的魔法·陷阱卡由对方发动”的条件。
		and aux.damcon1(e,tp,eg,ep,ev,re,r,rp)
end
-- 效果处理：记录当前连锁ID，分别注册作用于己方的伤害反射效果和作用于对方的伤害数值变更效果，并设置它们在连锁结束重置，从而实现“代替伤害+2倍伤害”的处理。
function c24566654.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取造成伤害的那个对方魔法·陷阱卡发动的连锁ID，用于后续限定只对这一次伤害效果生效。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	-- 对应效果原文“作为自己受到的那个效果伤害的代替”：通过EFFECT_REFLECT_DAMAGE让对方代替己方承受伤害；refcon函数用于核对该伤害确系当前连锁的效果伤害。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_REFLECT_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetLabel(cid)
	e1:SetValue(c24566654.refcon)
	e1:SetReset(RESET_CHAIN)
	-- 将伤害反射效果注册给己方玩家，使本次连锁的效果伤害改为由对方代为承受。
	Duel.RegisterEffect(e1,tp)
	-- 对应效果原文“对方受到那个数值2倍的伤害”：通过EFFECT_CHANGE_DAMAGE将对方受到的伤害值翻倍；dammul函数判断为当前连锁的效果伤害时乘以2，refcon则用于限定当前连锁ID。
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetLabel(cid)
	e2:SetValue(c24566654.dammul)
	e2:SetReset(RESET_CHAIN)
	-- 将伤害变更效果注册给己方玩家，使本次连锁中对对方玩家造成的效果伤害数值变为2倍。
	Duel.RegisterEffect(e2,tp)
end
-- refcon作为e1的Value判定：仅当当前存在连锁、伤害原因为效果伤害、且当前连锁ID与记录的ID一致时，才允许触发反射伤害，保证只代替那次特定效果伤害。
function c24566654.refcon(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号；若没有连锁则直接返回，避免在非连锁计算伤害时误触发反射。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的ID，与保存的目标连锁ID比较，确保只反射当初指定的那次伤害。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel()
end
-- dammul作为e2的Value判定：仅在当前连锁ID匹配且伤害原因为效果伤害时，将伤害数值乘以2，否则保留原值，实现“对方受到那个数值2倍的伤害”。
function c24566654.dammul(e,re,val,r,rp,rc)
	-- 获取当前正在处理的连锁序号；若没有连锁则不做倍率变更，防止非连锁伤害被错误倍增。
	local cc=Duel.GetCurrentChain()
	if cc==0 or bit.band(r,REASON_EFFECT)==0 then return end
	-- 获取当前正在处理的连锁的ID，与保存的目标连锁ID比较，确保只对该次效果伤害进行2倍化。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	return cid==e:GetLabel() and val*2 or val
end
