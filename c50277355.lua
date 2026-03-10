--クロシープ
-- 效果：
-- 卡名不同的怪兽2只
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡所连接区有怪兽特殊召唤的场合才能发动。这张卡所连接区的怪兽种类的以下效果各适用。
-- ●仪式：自己抽2张。那之后，选自己2张手卡丢弃。
-- ●融合：从自己墓地把1只4星以下的怪兽特殊召唤。
-- ●同调：自己场上的全部怪兽的攻击力上升700。
-- ●超量：对方场上的全部怪兽的攻击力下降700。
function c50277355.initial_effect(c)
	c:EnableReviveLimit()
	-- 为卡片添加连接召唤手续，要求使用2个连接素材，且连接素材的卡名不能重复
	aux.AddLinkProcedure(c,nil,2,2,c50277355.lcheck)
	-- ①：这张卡所连接区有怪兽特殊召唤的场合才能发动。这张卡所连接区的怪兽种类的以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,50277355)
	e1:SetCondition(c50277355.condition)
	e1:SetTarget(c50277355.target)
	e1:SetOperation(c50277355.activate)
	c:RegisterEffect(e1)
end
-- 连接素材的卡名不能重复的判断函数
function c50277355.lcheck(g,lc)
	return g:GetClassCount(Card.GetLinkCode)==g:GetCount()
end
-- 判断特殊召唤成功的怪兽是否在连接区内的过滤函数
function c50277355.cfilter(c,lg)
	return lg:IsContains(c)
end
-- 墓地4星以下怪兽的过滤函数
function c50277355.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否有连接区怪兽被特殊召唤成功
function c50277355.condition(e,tp,eg,ep,ev,re,r,rp)
	local lg=e:GetHandler():GetLinkedGroup()
	return eg:IsExists(c50277355.cfilter,1,nil,lg)
end
-- 判断连接区是否存在指定类型的怪兽
function c50277355.lkfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
-- 判断目标区域是否存在满足条件的怪兽并设置效果处理信息
function c50277355.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local lg=e:GetHandler():GetLinkedGroup()
	-- 判断是否可以发动仪式效果（抽2张卡并丢弃2张手卡）
	local b1=Duel.IsPlayerCanDraw(tp,2) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_RITUAL)
	-- 判断自己场上是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在4星以下怪兽并设置融合效果的发动条件
		and Duel.IsExistingMatchingCard(c50277355.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_FUSION)
	-- 判断自己场上是否存在怪兽并设置同调效果的发动条件
	local b3=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_SYNCHRO)
	-- 判断对方场上是否存在怪兽并设置超量效果的发动条件
	local b4=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_XYZ)
	if chk==0 then return b1 or b2 or b3 or b4 end
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
	-- 设置丢弃手卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,2)
	-- 设置从墓地特殊召唤怪兽的效果操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果处理函数，根据连接区怪兽类型执行对应效果
function c50277355.activate(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	local lg=e:GetHandler():GetLinkedGroup()
	local res=0
	-- 判断是否可以发动仪式效果（抽2张卡并丢弃2张手卡）
	local b1=Duel.IsPlayerCanDraw(tp,2) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_RITUAL)
	if b1 then
		-- 让玩家抽2张卡
		res=Duel.Draw(tp,2,REASON_EFFECT)
		if res==2 then
			-- 将玩家手牌洗切
			Duel.ShuffleHand(tp)
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 让玩家丢弃2张手牌
			Duel.DiscardHand(tp,aux.TRUE,2,2,REASON_EFFECT+REASON_DISCARD)
		end
	end
	lg=e:GetHandler():GetLinkedGroup()
	-- 判断自己场上是否有空位
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断墓地是否存在4星以下怪兽并设置融合效果的发动条件
		and Duel.IsExistingMatchingCard(aux.NecroValleyFilter(c50277355.spfilter),tp,LOCATION_GRAVE,0,1,nil,e,tp) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_FUSION)
	if b2 then
		-- 中断当前效果处理，使后续效果视为错时处理
		if res~=0 then Duel.BreakEffect() end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择1只满足条件的墓地怪兽进行特殊召唤
		local g1=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c50277355.spfilter),tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g1:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			res=Duel.SpecialSummon(g1,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	lg=e:GetHandler():GetLinkedGroup()
	-- 判断自己场上是否存在怪兽并设置同调效果的发动条件
	local b3=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_SYNCHRO)
	if b3 then
		-- 中断当前效果处理，使后续效果视为错时处理
		if res~=0 then Duel.BreakEffect() end
		-- 获取自己场上的所有怪兽
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		local tc1=g2:GetFirst()
		while tc1 do
			-- 给目标怪兽攻击力增加700
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(700)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc1:RegisterEffect(e1)
			res=res+1
			tc1=g2:GetNext()
		end
	end
	lg=e:GetHandler():GetLinkedGroup()
	-- 判断对方场上是否存在怪兽并设置超量效果的发动条件
	local b4=Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and lg:IsExists(c50277355.lkfilter,1,nil,TYPE_XYZ)
	if b4 then
		-- 中断当前效果处理，使后续效果视为错时处理
		if res~=0 then Duel.BreakEffect() end
		-- 获取对方场上的所有怪兽
		local g3=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		local tc2=g3:GetFirst()
		while tc2 do
			-- 给目标怪兽攻击力减少700
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(-700)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc2:RegisterEffect(e2)
			tc2=g3:GetNext()
		end
	end
end
