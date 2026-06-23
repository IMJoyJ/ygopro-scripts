--永の王 オルムガンド
-- 效果：
-- 9星怪兽×2只以上
-- 这个卡名的③的效果1回合只能使用1次。
-- ①：「永界王战 欧姆刚德王」在自己场上只能有1只表侧表示存在。
-- ②：这张卡的原本的攻击力·守备力变成这张卡的超量素材数量×1000。
-- ③：把这张卡1个超量素材取除才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身的手卡·场上1张卡在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
function c2665273.initial_effect(c)
	c:SetUniqueOnField(1,0,2665273)
	-- 添加XYZ召唤手续，要求满足条件的9星怪兽至少2只
	aux.AddXyzProcedure(c,nil,9,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ②：这张卡的原本的攻击力·守备力变成这张卡的超量素材数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_SET_BASE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c2665273.atkval)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_BASE_DEFENSE)
	c:RegisterEffect(e2)
	-- ③：把这张卡1个超量素材取除才能发动。双方各自从卡组抽1张。那之后，抽卡的玩家选自身的手卡·场上1张卡在这张卡下面重叠作为超量素材。这个效果在对方回合也能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(2665273,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,2665273)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(c2665273.drcost)
	e3:SetTarget(c2665273.drtg)
	e3:SetOperation(c2665273.drop)
	c:RegisterEffect(e3)
end
-- 设置自身原本攻击力为超量素材数量乘以1000
function c2665273.atkval(e,c)
	return c:GetOverlayCount()*1000
end
-- 支付效果代价，从自己场上移除1个超量素材
function c2665273.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 判断是否可以发动效果，检查双方是否可以抽卡
function c2665273.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断自己是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 判断对方是否可以抽卡
		and Duel.IsPlayerCanDraw(1-tp,1) end
	-- 设置连锁操作信息，指定双方各抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 过滤函数，返回可以作为超量素材的卡，排除受效果影响的卡
function c2665273.matfilter(c,e)
	return c:IsCanOverlay() and not (e and c:IsImmuneToEffect(e))
end
-- 效果处理函数，执行抽卡和选择超量素材的操作
function c2665273.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 让当前玩家从卡组抽1张卡
	local td=Duel.Draw(tp,1,REASON_EFFECT)
	-- 让对方玩家从卡组抽1张卡
	local ed=Duel.Draw(1-tp,1,REASON_EFFECT)
	if td+ed>0 and c:IsRelateToEffect(e) then
		local sg=Group.CreateGroup()
		-- 获取当前玩家可以作为超量素材的卡组
		local tg1=Duel.GetMatchingGroup(c2665273.matfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if td>0 and tg1:GetCount()>0 then
			-- 洗切当前玩家的手卡
			Duel.ShuffleHand(tp)
			-- 提示当前玩家选择作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local tc1=tg1:Select(tp,1,1,nil):GetFirst()
			if tc1 then
				tc1:CancelToGrave()
				sg:AddCard(tc1)
			end
		end
		-- 获取对方玩家可以作为超量素材的卡组
		local tg2=Duel.GetMatchingGroup(c2665273.matfilter,1-tp,LOCATION_HAND+LOCATION_ONFIELD,0,aux.ExceptThisCard(e),e)
		if ed>0 and tg2:GetCount()>0 then
			-- 洗切对方玩家的手卡
			Duel.ShuffleHand(1-tp)
			-- 提示对方玩家选择作为超量素材的卡
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
			local tc2=tg2:Select(1-tp,1,1,nil):GetFirst()
			if tc2 then
				tc2:CancelToGrave()
				sg:AddCard(tc2)
			end
		end
		if sg:GetCount()>0 then
			-- 中断当前效果处理，使后续处理视为不同时处理
			Duel.BreakEffect()
			-- 遍历选择的卡组，对每张卡进行处理
			for tc in aux.Next(sg) do
				local og=tc:GetOverlayGroup()
				if og:GetCount()>0 then
					-- 将卡的叠放组送去墓地
					Duel.SendtoGrave(og,REASON_RULE)
				end
			end
			-- 将选择的卡叠放至自身卡上
			Duel.Overlay(c,sg)
		end
	end
end
