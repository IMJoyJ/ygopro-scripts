--ボルテスター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在连接怪兽所连接区特殊召唤的场合发动。和这张卡成为连接状态的连接怪兽全部破坏。并且再重复「破坏的连接怪兽的所连接区的怪兽也全部破坏」处理。（这个效果不会让这张卡被破坏。）
function c18585765.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：这张卡在连接怪兽所连接区特殊召唤的场合发动。和这张卡成为连接状态的连接怪兽全部破坏。并且再重复「破坏的连接怪兽的所连接区的怪兽也全部破坏」处理。（这个效果不会让这张卡被破坏。）
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18585765,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,18585765)
	e1:SetCondition(c18585765.descon)
	e1:SetTarget(c18585765.destg)
	e1:SetOperation(c18585765.desop)
	c:RegisterEffect(e1)
end
-- 发动条件判定：将双方场上处于连接状态的卡合并，检查其中是否包含这张卡，以判断这张卡是否是在连接怪兽所连接区被特殊召唤。
function c18585765.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方场上所有处于连接状态的卡片组。
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方场上所有处于连接状态的卡片组。
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 筛选条件：这张卡是表侧表示的连接怪兽，并且其连接区包含作为判断对象的“这张卡”（即与这张卡成为连接状态）。
function c18585765.desfilter1(c,mc)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(mc)
end
-- 发动时目标设定：无条件允许发动，然后检索场上所有满足条件的、与这张卡相互连接的连接怪兽，将其作为破坏对象并写入操作信息。
function c18585765.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 检索场上所有与这张卡处于连接状态的表侧连接怪兽。
	local g=Duel.GetMatchingGroup(c18585765.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 设置本次操作信息为破坏效果，目标为上述连接怪兽组，数量为其数量，用于触发相关场合的检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 预计算迭代破坏候选：为要破坏的连接怪兽记录其场地标识，并将其所连接区的所有怪兽登记对应的标识，返回这些连接区怪兽的集合，用于后续判断“被破坏的连接怪兽所连接区的怪兽”。
function c18585765.desfilter2(g)
	local sg=Group.CreateGroup()
	local tc=g:GetFirst()
	while tc do
		local fid=tc:GetFieldID()
		tc:RegisterFlagEffect(18585766,RESET_CHAIN,0,1,fid)
		local lg=tc:GetLinkedGroup()
		local sc=lg:GetFirst()
		while sc do
			sc:RegisterFlagEffect(18585765,RESET_EVENT+RESETS_STANDARD+RESET_CHAIN,0,1,fid)
			sg:AddCard(sc)
			sc=lg:GetNext()
		end
		tc=g:GetNext()
	end
	return sg
end
-- 过滤函数：判断卡片c是否属于“已被破坏的连接怪兽所连接区的怪兽”，通过比较c上登记的标识与已破坏怪兽登记的标识是否一致来确定。
function c18585765.desfilter3(c,g)
	local tc=g:GetFirst()
	while tc do
		local fid=tc:GetFlagEffectLabel(18585766)
		if fid~=nil and c:GetFlagEffectLabel(18585765)==fid then return true end
		tc=g:GetNext()
	end
	return false
end
-- 效果处理：先检索出当前与这张卡处于连接状态的连接怪兽并破坏；然后循环检索这些被破坏怪兽所连接区的其他怪兽并继续破坏，每次用BreakEffect错开时点，且通过Filter排除这张卡自身，直到没有可破坏的怪兽为止。
function c18585765.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 检索场上所有与这张卡处于连接状态的表侧连接怪兽。
	local g=Duel.GetMatchingGroup(c18585765.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	local lg=c18585765.desfilter2(g)
	-- 如果存在这样的连接怪兽且破坏成功，则继续执行后续的重复破坏处理。
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取刚刚因效果实际被破坏的卡片组（不是预选组），用于确定哪些连接怪兽已经实际被破坏。
		local og=Duel.GetOperatedGroup()
		local sg=lg:Filter(c18585765.desfilter3,e:GetHandler(),og)
		while sg:GetCount()>0 do
			-- 中断当前效果处理，使后续的重复破坏视为不同时处理，避免错时点。
			Duel.BreakEffect()
			lg=c18585765.desfilter2(sg)
			-- 破坏当前符合条件的连接区怪兽组；若实际破坏数量为0（没有破坏任何卡）则终止效果处理。
			if Duel.Destroy(sg,REASON_EFFECT)==0 then return end
			-- 更新实际被破坏的卡片组为最新一次破坏操作的结果，用于继续筛选下一轮应被破坏的连接区怪兽。
			og=Duel.GetOperatedGroup()
			sg=lg:Filter(c18585765.desfilter3,e:GetHandler(),og)
		end
	end
end
