--破械神雙ラギア
local s,id,o=GetID()
-- 初始化效果，设置卡片的连接召唤手续和两个诱发效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，要求使用2到3张满足条件的连接素材
	aux.AddLinkProcedure(c,nil,2,3,s.lcheck)
	-- 为单张卡片注册合并的延迟事件监听，以限制其自身特殊召唤成功时的效果在一连锁中只响应一次
	local custom_code=aux.RegisterMergedDelayedEvent_ToSingleCard(c,id,EVENT_SPSUMMON_SUCCESS)
	-- 创建第一个诱发效果，用于在特殊召唤成功时无效并破坏对方怪兽
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
	-- 创建第二个诱发效果，用于在对方发动效果时破坏对方场上的一张怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	-- 设置效果发动时需要将自身除外作为费用
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 连接素材检查函数，确保至少有一张恶魔族的连接怪兽
function s.lcheck(g,lc)
	return g:IsExists(Card.IsLinkRace,1,nil,RACE_FIEND)
end
-- 无效效果怪兽过滤器，筛选可以被无效的表侧表示怪兽
function s.disfilter(c,tp,e)
	-- 筛选条件：表侧表示、在主要怪兽区、是对方召唤的、能成为效果对象且未被无效的效果怪兽
	return c:IsFaceupEx() and c:IsLocation(LOCATION_MZONE) and c:IsSummonPlayer(1-tp) and c:IsCanBeEffectTarget(e) and aux.NegateEffectMonsterFilter(c)
end
-- 无效效果发动条件，检查是否有对方召唤成功的怪兽
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
end
-- 破坏怪兽过滤器，筛选场上表侧表示的恶魔族怪兽
function s.desfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FIEND)
end
-- 选择目标过滤器，用于在多个目标中选择一个进行处理
function s.tgfilter(c,g,dg)
	return g:IsContains(c) and (dg:GetCount()>1 or not dg:IsContains(c))
end
-- 无效效果的目标选择函数，根据条件筛选并设置目标卡
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.disfilter,nil,tp,e)
	-- 获取对方场上的所有恶魔族怪兽作为可破坏对象
	local dg=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,0,nil)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:GetCount()>0 and (dg:GetCount()>1 or dg~=g) end
	local sg
	if g:GetCount()==1 then
		sg=g:Clone()
		-- 将选定的卡设置为当前连锁的对象
		Duel.SetTargetCard(sg)
	else
		-- 提示玩家选择要无效的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISABLE)  --"请选择要无效的卡"
		-- 从符合条件的卡中选择一张作为目标
		sg=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,g,dg)
	end
	-- 设置操作信息，表示将要使目标怪兽无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,sg,1,0,0)
	if dg:GetCount()>0 then
		-- 设置操作信息，表示将要破坏目标怪兽
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 无效效果的处理函数，选择并破坏对方怪兽并使其效果无效
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tgc=Duel.GetFirstTarget()
	local tc=nil
	if tgc and tgc:IsRelateToChain() then tc=tgc end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从场上选择一张恶魔族怪兽作为破坏对象
	local sg=Duel.SelectMatchingCard(tp,s.desfilter,tp,LOCATION_MZONE,0,1,1,tc)
	if sg:GetCount()>0 then
		-- 显示被选为对象的动画效果
		Duel.HintSelection(sg)
		-- 执行破坏操作，返回实际破坏的数量
		if Duel.Destroy(sg,REASON_EFFECT)~=0
			and tc and tc:IsRelateToChain() and tc:IsOnField() and tc:IsCanBeDisabledByEffect(e) then
			-- 使目标怪兽相关的连锁无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 创建一个使目标怪兽无效的效果
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 创建一个使目标怪兽效果无效化的效果
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
-- 破坏条件过滤器，筛选场上表侧表示、连接值大于等于4且为破械神卡组的怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsLinkAbove(4) and c:IsSetCard(0x130)
end
-- 破坏效果发动条件，检查对方发动的是怪兽类型的效果且己方场上有符合条件的怪兽
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return re:GetHandler():IsOnField() and re:GetHandler():IsRelateToEffect(re) and re:IsActiveType(TYPE_MONSTER)
		-- 检查己方场是否至少存在一张满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置破坏效果的目标和操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsDestructable() end
	-- 将对方发动效果的卡设置为当前连锁的对象
	Duel.SetTargetCard(re:GetHandler())
	-- 设置操作信息，表示将要破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
end
-- 破坏效果的处理函数，对目标怪兽进行破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsType(TYPE_MONSTER) then
		-- 执行破坏操作，将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
