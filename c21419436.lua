--破械神雙ラギア
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 为该卡添加连接召唤手续，需要2-3个种族为恶魔的怪兽作为素材。
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 为卡片注册一个延迟事件监听器，在特殊召唤成功时触发。
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 创建第一个效果，用于破坏和无效化对方场上的怪兽。设置效果描述、类别、类型、代码、发动条件、目标选择函数和操作函数，并将其注册到卡片上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(custom_code)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- 创建第二个效果，用于在连锁中破坏墓地的恶魔族怪兽。设置效果描述、类别、类型、代码、发动条件、费用支付函数、目标选择函数和操作函数，并将其注册到卡片上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 定义了使用除外作为cost的简单写法
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义lcheck函数，用于检查连接素材中是否存在恶魔族怪兽。
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- 定义disfilter函数，用于筛选可以被无效化的表侧表示效果怪兽。
function s.disfilter(c,tp,e)
	-- 返回c是否为表侧表示、在主要怪兽区、由对方召唤、可以作为效果目标且不是被无效的怪兽
	return c:IsFaceupEx() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and aux.NegateEffectMonsterFilter(c)
end
-- 定义discon函数，用于判断是否满足触发第一个效果的条件：存在由对方控制的怪兽。
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 定义desfilter函数，用于筛选墓地中表侧表示的恶魔族怪兽。
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 定义tgfilter函数，用于在选择目标时过滤卡片。如果目标组包含当前卡片且目标组的数量大于1或者不包含当前卡片则返回true
function s.tgfilter(c,g,dg)
	return g:IsContains(c) and (dg:GetCount()>1 or not dg:IsContains(c))
end
-- 定义distg函数，用于选择要破坏和无效化的目标怪兽。
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.disfilter,nil,tp,e)
	-- 获取满足disfilter条件的怪兽组。
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:GetCount()>0 and (dg:GetCount()>1 or dg~=g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 设置选定的目标卡片。
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要无效的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 让玩家从满足tgfilter条件的怪兽中选择一个作为目标。
		sg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,dg)
	end
	-- 设置操作信息，表示将禁用所选的目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	if dg:GetCount()>0 then
		-- 设置操作信息，表示将破坏符合desfilter条件的怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 定义disop函数，用于执行第一个效果的操作：无效化对方的连锁并使目标怪兽失效。
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡片。
	local tgc=Duel.GetFirstTarget()
	local tc=nil
	if tgc and tgc:IsRelateToChain() then tc=tgc end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从满足desfilter条件的怪兽中选择一个作为目标。
	local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,tc)
	if sg:GetCount()>0 then
		-- 显示所选的目标卡片的动画效果。
		Duel.HintSelection(sg)
		-- 如果成功破坏了目标卡片，则检查目标卡片是否与连锁相关、在场上且可以被无效化。
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			and tc and tc:IsRelateToChain() and tc:IsOnField() and tc:IsCanBeDisabledByEffect(e) then
			-- 使和tc有关的连锁都无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 创建并注册一个持续效果，用于禁用目标怪兽的效果和能力。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 创建并注册一个持续效果，用于禁用目标怪兽的效果和能力。
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetValue(RESET_TURN_SET)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 定义cfilter函数，用于筛选种族为恶魔、连接值大于等于4且卡片所属系列为0x130的表侧表示怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsLinkAbove(4) and c:IsSetCard(0x130)
end
-- 定义descon函数，用于判断是否满足触发第二个效果的条件：目标怪兽在场上、与连锁相关、是效果怪兽，并且存在符合cfilter条件的怪兽。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查是否存在满足cfilter条件的卡片
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义destg函数，用于选择要破坏的目标怪兽。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 设置目标卡片为连锁中的第一个目标卡片。
	Duel.SetTargetCard(re:GetHandler())
	-- 设置操作信息，表示将破坏所选的目标卡片。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 定义desop函数，用于执行第二个效果的操作：破坏目标怪兽。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中的第一个目标卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 如果目标卡片与连锁相关且是怪兽类型，则将其破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
