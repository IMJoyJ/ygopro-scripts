--落とし大穴
-- 效果：
-- 对方以表侧表示对2只以上的怪兽的特殊召唤成功时才能发动。那些怪兽全部送去墓地。并且再把和那些怪兽同名怪兽从对方的手卡·卡组送去墓地。
function c30127518.initial_effect(c)
	-- 对应卡片效果原文：“对方以表侧表示对2只以上的怪兽的特殊召唤成功时才能发动。那些怪兽全部送去墓地。并且再把和那些怪兽同名怪兽从对方的手卡·卡组送去墓地。”此部分创建并注册效果，设置其为通常陷阱的发动效果，触发时机为对方特殊召唤成功时，并指定目标选择与效果处理函数。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetTarget(c30127518.target)
	e1:SetOperation(c30127518.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选出攻击表示（表侧表示）且由对方玩家（1-tp）特殊召唤成功的怪兽；若传入效果e，则还要求该怪兽与当前效果保持关联（没有离场或失去联系），用于发动时判断和效果处理时再次确认对象。
function c30127518.cfilter(c,sp,e)
	return c:IsFaceup() and c:IsSummonPlayer(sp) and (not e or c:IsRelateToEffect(e))
end
-- 目标选择函数：效果发动时，检查本次特殊召唤成功的怪兽组eg中，是否存在至少2只由对方玩家特殊召唤的表侧表示怪兽；若存在，则将这些怪兽整体作为对象，并设置对应的送去墓地的操作信息。
function c30127518.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c30127518.cfilter,2,nil,1-tp) end
	local g=eg:Filter(c30127518.cfilter,nil,1-tp)
	-- 将筛选出的怪兽组g登记为当前连锁的处理对象（广义对象），以便后续效果处理时通过连锁信息获取这些卡片。
	Duel.SetTargetCard(g)
	-- 设置本次效果的操作信息：声明效果类别为送去墓地，对象为g，数量为g中的卡片数量，用于诱发“被送去墓地”等相关效果的检测与发动判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,g:GetCount(),0,0)
end
-- 效果处理函数：先取回发动时登记的对象怪兽，过滤掉已不满足条件或与效果失去联系的卡，将剩下的怪兽全部送去墓地；然后获取这次被送去墓地的卡，从对方的手卡·卡组中检索同名卡并一并送去墓地；两次送墓之间插入间隔，使后续同名卡送墓不视为同时处理。
function c30127518.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时登记的对象卡组，并再次用cfilter过滤，剔除已经离场、翻转或与效果失去关联的怪兽，确保只处理仍然符合条件的对象。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(c30127518.cfilter,nil,1-tp,e)
	-- 将符合条件的对象怪兽全部以效果原因（REASON_EFFECT）送去墓地，对应原效果“那些怪兽全部送去墓地”。
	Duel.SendtoGrave(g,REASON_EFFECT)
	local exg=Group.CreateGroup()
	-- 通过Duel.GetOperatedGroup()获取刚刚因效果实际被送去墓地的卡片组，作为后续检索同名卡的基准。
	local g1=Duel.GetOperatedGroup()
	local tc=g1:GetFirst()
	while tc do
		if tc:IsLocation(LOCATION_GRAVE) then
			-- 在对方的手卡与卡组中检索卡号等于tc当前卡号的同名卡，将所有同名卡组成一个卡片组fg，用于后续一并送去墓地。
			local fg=Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode())
			exg:Merge(fg)
		end
		tc=g1:GetNext()
	end
	-- 调用Duel.BreakEffect()中断当前效果的处理，使接下来的“同名卡送去墓地”与前面的“对象怪兽送去墓地”分为不同的处理节点，符合“并且再把……”的连锁结算顺序，避免时点合并。
	Duel.BreakEffect()
	-- 将检索到的所有同名卡（exg）以效果原因全部送去墓地，对应原效果“并且再把和那些怪兽同名怪兽从对方的手卡·卡组送去墓地”。
	Duel.SendtoGrave(exg,REASON_EFFECT)
end
