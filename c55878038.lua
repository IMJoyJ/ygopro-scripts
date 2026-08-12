--混源龍レヴィオニア
-- 效果：
-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽合计3只除外的场合可以特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：这个方法让这张卡特殊召唤成功时才能发动。为那次特殊召唤而除外的怪兽属性的以下效果适用。这个回合，这张卡不能攻击。
-- ●只有光：从自己墓地选1只怪兽守备表示特殊召唤。
-- ●只有暗：对方手卡随机选1张回到卡组。
-- ●光和暗：选场上最多2张卡破坏。
function c55878038.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从自己墓地把光·暗属性怪兽合计3只除外的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55878038,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c55878038.spcon)
	e1:SetTarget(c55878038.sptg)
	e1:SetOperation(c55878038.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ①：这个方法让这张卡特殊召唤成功时才能发动。为那次特殊召唤而除外的怪兽属性的以下效果适用。这个回合，这张卡不能攻击。●只有光：从自己墓地选1只怪兽守备表示特殊召唤。●只有暗：对方手卡随机选1张回到卡组。●光和暗：选场上最多2张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,55878038)
	e2:SetCondition(c55878038.descon)
	e2:SetTarget(c55878038.destg)
	e2:SetOperation(c55878038.desop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 过滤条件：用于特殊召唤的从墓地除外的光·暗属性怪兽
function c55878038.spcostfilter(c)
	return c:IsAbleToRemoveAsCost() and c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK)
end
-- 特殊召唤规则的条件：检查怪兽区域空位以及墓地是否存在3只可除外的光·暗属性怪兽
function c55878038.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位
	if Duel.GetMZoneCount(tp)<=0 then return false end
	-- 检查自己墓地是否存在至少3只满足条件的光·暗属性怪兽
	return Duel.IsExistingMatchingCard(c55878038.spcostfilter,tp,LOCATION_GRAVE,0,3,nil)
end
-- 特殊召唤规则的准备：从墓地选择3只光·暗属性怪兽，并记录其属性信息
function c55878038.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己墓地所有满足条件的光·暗属性怪兽
	local g=Duel.GetMatchingGroup(c55878038.spcostfilter,tp,LOCATION_GRAVE,0,nil)
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=g:CancelableSelect(tp,3,3,nil)
	if sg then
		sg:KeepAlive()
		e:SetLabelObject(sg)
		return true
	else return false end
end
-- 特殊召唤规则的执行：根据除外怪兽的属性设置标记，并将它们除外
function c55878038.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	local label=0
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_LIGHT) then
		label=label+1
	end
	if g:IsExists(Card.IsAttribute,1,nil,ATTRIBUTE_DARK) then
		label=label+2
	end
	e:SetLabel(label)
	-- 将选择的3只怪兽因特殊召唤而表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 发动条件：检查此卡是否是通过自身特殊召唤规则特殊召唤成功
function c55878038.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤条件：可以守备表示特殊召唤的怪兽
function c55878038.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果发动时的可行性检查与效果分类、操作信息的注册
function c55878038.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local label=e:GetLabelObject():GetLabel()
	if chk==0 then
		if label==1 then
			-- （只有光效果）检查自己场上是否有可用的怪兽区域空位
			return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
				-- （只有光效果）检查自己墓地是否存在可以特殊召唤的怪兽
				and Duel.IsExistingMatchingCard(c55878038.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		elseif label==2 then
			-- （只有暗效果）检查对方手卡数量是否大于0
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
		else
			return true
		end
	end
	e:SetLabel(label)
	if label==1 then
		-- 向对方玩家提示发动了“只有光”的效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(55878038,1))  --"从自己墓地选1只怪兽守备表示特殊召唤"
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置特殊召唤的操作信息，准备从墓地特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
	elseif label==2 then
		-- 向对方玩家提示发动了“只有暗”的效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(55878038,2))  --"对方手卡随机选1张回到卡组"
		e:SetCategory(CATEGORY_TODECK)
		-- 设置让卡片回到卡组的操作信息，准备将对方手卡送回卡组
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,0,1-tp,LOCATION_HAND)
	else
		-- 向对方玩家提示发动了“光和暗”的效果
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(55878038,3))  --"选场上最多2张卡破坏"
		e:SetCategory(CATEGORY_DESTROY)
		-- 获取双方场上的所有卡片
		local g=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 设置破坏的操作信息，准备破坏场上的卡片
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
end
-- 效果处理：使自身不能攻击，并根据除外怪兽的属性适用对应的效果
function c55878038.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，这张卡不能攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
	local label=e:GetLabel()
	if label==1 then
		-- （只有光效果）若自己场上没有可用的怪兽区域空位则结束处理
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只不受王家之谷影响且满足特殊召唤条件的怪兽
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c55878038.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g1:GetCount()>0 then
			-- 将选择的怪兽以守备表示特殊召唤到自己场上
			Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	elseif label==2 then
		-- （只有暗效果）若对方手卡为0则结束处理
		if Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)<=0 then return end
		-- 随机选择对方的1张手卡
		local g2=Duel.GetFieldGroup(tp,0,LOCATION_HAND):RandomSelect(tp,1)
		-- 将选择的对方手卡送回卡组并洗牌
		Duel.SendtoDeck(g2,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	else
		-- （光和暗效果）获取双方场上的所有卡片
		local g3=Duel.GetMatchingGroup(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if g3:GetCount()>0 then
			local ct=math.min(g3:GetCount(),2)
			-- 提示玩家选择要破坏的卡片
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local sg=g3:Select(tp,1,ct,nil)
			-- 为选择的卡片显示被选为对象的动画效果
			Duel.HintSelection(sg)
			-- 因效果破坏选择的卡片
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
