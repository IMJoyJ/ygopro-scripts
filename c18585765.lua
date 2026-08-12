--ボルテスター
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡在连接怪兽所连接区特殊召唤的场合发动。和这张卡成为连接状态的连接怪兽全部破坏。并且再重复「破坏的连接怪兽的所连接区的怪兽也全部破坏」处理。（这个效果不会让这张卡被破坏。）
function c18585765.initial_effect(c)
	-- 创建效果，设置效果描述、破坏类别、触发类型、特殊召唤成功时发动、限制一回合一次、条件函数、目标函数、处理函数
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
-- 判断该卡是否在连接怪兽所连接区被特殊召唤
function c18585765.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方连接怪兽组
	local lg1=Duel.GetLinkedGroup(tp,1,1)
	-- 获取对方连接怪兽组
	local lg2=Duel.GetLinkedGroup(1-tp,1,1)
	lg1:Merge(lg2)
	return lg1 and lg1:IsContains(e:GetHandler())
end
-- 过滤函数，用于筛选与指定卡片连接的连接怪兽
function c18585765.desfilter1(c,mc)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetLinkedGroup():IsContains(mc)
end
-- 设置连锁处理信息，确定要破坏的卡片组
function c18585765.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取满足条件的连接怪兽组
	local g=Duel.GetMatchingGroup(c18585765.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	-- 设置连锁操作信息，指定破坏效果的目标
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 处理函数，用于获取连接怪兽所连接区的怪兽并注册标记
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
-- 过滤函数，用于筛选与已破坏怪兽连接区相关的怪兽
function c18585765.desfilter3(c,g)
	local tc=g:GetFirst()
	while tc do
		local fid=tc:GetFlagEffectLabel(18585766)
		if fid~=nil and c:GetFlagEffectLabel(18585765)==fid then return true end
		tc=g:GetNext()
	end
	return false
end
-- 效果处理函数，先破坏连接怪兽，再重复破坏其连接区的怪兽
function c18585765.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的连接怪兽组
	local g=Duel.GetMatchingGroup(c18585765.desfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,nil,e:GetHandler())
	local lg=c18585765.desfilter2(g)
	-- 判断是否有连接怪兽被破坏且破坏成功
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的卡片组
		local og=Duel.GetOperatedGroup()
		local sg=lg:Filter(c18585765.desfilter3,e:GetHandler(),og)
		while sg:GetCount()>0 do
			-- 中断当前效果处理，避免连锁错时
			Duel.BreakEffect()
			lg=c18585765.desfilter2(sg)
			-- 再次破坏符合条件的怪兽，若无法破坏则返回
			if Duel.Destroy(sg,REASON_EFFECT)==0 then return end
			-- 获取再次破坏后实际操作的卡片组
			og=Duel.GetOperatedGroup()
			sg=lg:Filter(c18585765.desfilter3,e:GetHandler(),og)
		end
	end
end
