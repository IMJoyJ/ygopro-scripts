--氷結界の鏡
-- 效果：
-- ①：这个回合中，每次对方发动的怪兽的效果让卡被除外，以那卡从哪里除外来对应的以下效果适用。
-- ●自己手卡：对方手卡随机最多2张除外。
-- ●自己场上：对方场上最多2张卡除外。
-- ●自己墓地：对方墓地最多2张卡除外。
function c10691144.initial_effect(c)
	-- ①：这个回合中，每次对方发动的怪兽的效果让卡被除外，以那卡从哪里除外来对应的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c10691144.activate)
	c:RegisterEffect(e1)
end
-- 效果发动时的处理函数
function c10691144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 如果本回合已经发动过此效果则不重复发动
	if Duel.GetFlagEffect(tp,10691144)~=0 then return end
	-- 注册一个在对方除外卡时触发的效果，用于判断除外来源并执行对应处理
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c10691144.rmcon)
	e1:SetOperation(c10691144.rmop)
	-- 将效果e1注册给玩家tp，使其在对方除外卡时触发
	Duel.RegisterEffect(e1,tp)
	-- 为玩家tp注册一个标识效果，防止本回合重复发动此效果
	Duel.RegisterFlagEffect(tp,10691144,RESET_PHASE+PHASE_END,0,1)
end
-- 判断除外卡来源位置的条件函数
function c10691144.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local flag=0
	local tc=eg:GetFirst()
	while tc do
		local ploc=tc:GetPreviousLocation()
		local te=tc:GetReasonEffect()
		if tc:IsReason(REASON_EFFECT) and not tc:IsReason(REASON_REDIRECT) and bit.band(ploc,0x1e)~=0 and tc:IsPreviousControler(tp)
			and te:GetOwnerPlayer()==1-tp and te:IsActiveType(TYPE_MONSTER) and te:IsActivated() then
			flag=bit.bor(flag,ploc)
		end
		tc=eg:GetNext()
	end
	e:SetLabel(flag)
	return flag~=0
end
-- 根据除外卡来源位置执行对应处理的函数
function c10691144.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local flag=e:GetLabel()
	if bit.band(flag,LOCATION_HAND)~=0 then
		-- 获取对方手牌中可以被除外的卡组
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if rg:GetCount()>0 then
			local ct=1
			-- 如果对方手牌数量大于1，则让玩家选择除外1张或2张手牌
			if rg:GetCount()>1 then ct=Duel.SelectOption(tp,aux.Stringid(10691144,3),aux.Stringid(10691144,4))+1 end  --"除外1张手牌" / "除外2张手牌"
			g:Merge(rg:RandomSelect(tp,ct))
		end
	end
	if bit.band(flag,LOCATION_ONFIELD)~=0 then
		-- 获取对方场上可以被除外的卡组
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if rg:GetCount()>0 then
			-- 向玩家tp提示选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	if bit.band(flag,LOCATION_GRAVE)~=0 then
		-- 获取对方墓地中可以被除外的卡组
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if rg:GetCount()>0 then
			-- 向玩家tp提示选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	-- 将符合条件的卡以正面表示的形式除外
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
