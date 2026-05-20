--レスキューラビット
-- 效果：
-- 这张卡不能从卡组特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：把场上的这张卡除外才能发动。从卡组把2只4星以下的同名通常怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c85138716.initial_effect(c)
	-- 这张卡不能从卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_DECK)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 这个卡名的效果1回合只能使用1次。①：把场上的这张卡除外才能发动。从卡组把2只4星以下的同名通常怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85138716,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,85138716)
	e2:SetCost(c85138716.spcost)
	e2:SetTarget(c85138716.sptg)
	e2:SetOperation(c85138716.spop)
	c:RegisterEffect(e2)
end
-- 发动效果的代价（Cost）处理函数，检查并执行将自身除外
function c85138716.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	-- 将作为发动代价的场上的这张卡表侧表示除外
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
-- 过滤卡组中4星以下的、可以特殊召唤的通常怪兽
function c85138716.filter(c,e,tp)
	return c:IsType(TYPE_NORMAL) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤出在给定的卡片组中存在同名卡的卡片
function c85138716.filter2(c,g)
	return g:IsExists(Card.IsCode,1,c,c:GetCode())
end
-- 效果发动的目标（Target）处理函数，检查卡组中是否存在可特殊召唤的同名通常怪兽，并设置特殊召唤的操作信息
function c85138716.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取卡组中所有满足条件的4星以下通常怪兽
		local g=Duel.GetMatchingGroup(c85138716.filter,tp,LOCATION_DECK,0,nil,e,tp)
		-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
		return not Duel.IsPlayerAffectedByEffect(tp,59822133)
			-- 检查在自身离开场上后是否有2个以上的空怪兽区域，且卡组中是否存在至少一对同名怪兽
			and Duel.GetMZoneCount(tp,e:GetHandler())>1 and g:IsExists(c85138716.filter2,1,nil,g)
	end
	-- 设置连锁处理的操作信息，表示该效果会从卡组特殊召唤2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK)
end
-- 效果运行（Operation）处理函数，从卡组选择并特殊召唤2只同名通常怪兽，并注册结束阶段将其破坏的效果
function c85138716.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then return end
	-- 如果当前可用的怪兽区域少于2个，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<2 then return end
	-- 获取卡组中所有满足条件的4星以下通常怪兽
	local g=Duel.GetMatchingGroup(c85138716.filter,tp,LOCATION_DECK,0,nil,e,tp)
	local dg=g:Filter(c85138716.filter2,nil,g)
	if dg:GetCount()>=1 then
		local fid=e:GetHandler():GetFieldID()
		-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=dg:Select(tp,1,1,nil)
		local tc1=sg:GetFirst()
		dg:RemoveCard(tc1)
		local tc2=dg:Filter(Card.IsCode,nil,tc1:GetCode()):GetFirst()
		-- 将第一只怪兽以表侧表示特殊召唤到场上（分步处理）
		Duel.SpecialSummonStep(tc1,0,tp,tp,false,false,POS_FACEUP)
		-- 将第二只同名怪兽以表侧表示特殊召唤到场上（分步处理）
		Duel.SpecialSummonStep(tc2,0,tp,tp,false,false,POS_FACEUP)
		tc1:RegisterFlagEffect(85138716,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		tc2:RegisterFlagEffect(85138716,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 完成特殊召唤的最终处理
		Duel.SpecialSummonComplete()
		sg:AddCard(tc2)
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		e1:SetCondition(c85138716.descon)
		e1:SetOperation(c85138716.desop)
		-- 注册全局效果，用于在结束阶段破坏特殊召唤的怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 过滤出带有当前特殊召唤标记（fid）的怪兽
function c85138716.desfilter(c,fid)
	return c:GetFlagEffectLabel(85138716)==fid
end
-- 结束阶段破坏效果的发动条件，检查被特殊召唤的怪兽是否还存在于场上，若不存在则重置该效果
function c85138716.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c85138716.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段破坏效果的执行函数，破坏依然存在于场上的被特殊召唤的怪兽
function c85138716.desop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	local tg=g:Filter(c85138716.desfilter,nil,e:GetLabel())
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tg,REASON_EFFECT)
end
