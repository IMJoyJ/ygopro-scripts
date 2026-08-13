--氷結界の鏡
-- 效果：
-- ①：这个回合中，每次对方发动的怪兽的效果让卡被除外，以那卡从哪里除外来对应的以下效果适用。
-- ●自己手卡：对方手卡随机最多2张除外。
-- ●自己场上：对方场上最多2张卡除外。
-- ●自己墓地：对方墓地最多2张卡除外。
function c10691144.initial_effect(c)
	-- “①：这个回合中，每次对方发动的怪兽的效果让卡被除外，以那卡从哪里除外来对应的以下效果适用。”；这里将卡片的发动效果注册为通常陷阱。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c10691144.activate)
	c:RegisterEffect(e1)
end
-- 发动时若本回合尚未适用过此卡效果，则创建一个本回合持续存在的、监测除外事件的诱发效果并注册到场上，同时给自己打上使用标记，避免重复发动。
function c10691144.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己是否已有本回合发动过“冰结界之镜”的标记，若有则结束处理，防止同一回合重复发动。
	if Duel.GetFlagEffect(tp,10691144)~=0 then return end
	-- “①：这个回合中，每次对方发动的怪兽的效果让卡被除外，以那卡从哪里除外来对应的以下效果适用。●自己手卡：对方手卡随机最多2张除外。●自己场上：对方场上最多2张卡除外。●自己墓地：对方墓地最多2张卡除外。”；这里注册持续监测除外事件的触发器，并定义触发条件和具体处理。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_REMOVE)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetCondition(c10691144.rmcon)
	e1:SetOperation(c10691144.rmop)
	-- 将上述持续效果注册到场上，使其在本回合内任何卡被除外时都能尝试触发。
	Duel.RegisterEffect(e1,tp)
	-- 给自己注册一个本回合使用过此卡效果的标记，该标记在结束阶段重置，用于防止本回合再次发动同名卡效果。
	Duel.RegisterFlagEffect(tp,10691144,RESET_PHASE+PHASE_END,0,1)
end
-- 监测除外事件组，筛选出满足“因对方发动的怪兽效果、非改变去向、从自己手牌/场上/墓地除外、且之前由自己控制”的卡片，按来源位置记录标志位。
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
-- 根据来源位置标志，分别处理：若来自手牌则随机选1-2张对方手牌除外；若来自场上或墓地则选择对方场上或墓地1-2张卡除外，最后统一除外。
function c10691144.rmop(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	local flag=e:GetLabel()
	if bit.band(flag,LOCATION_HAND)~=0 then
		-- 获取对方手牌中所有能被除外的卡，作为随机除外候选组。
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if rg:GetCount()>0 then
			local ct=1
			-- 若对方手牌数大于1，则让己方选择随机除外1张还是2张（最多2张），确定实际排除数量。
			if rg:GetCount()>1 then ct=Duel.SelectOption(tp,aux.Stringid(10691144,3),aux.Stringid(10691144,4))+1 end  --"除外一张手牌/除外两张手牌"
			g:Merge(rg:RandomSelect(tp,ct))
		end
	end
	if bit.band(flag,LOCATION_ONFIELD)~=0 then
		-- 获取对方场上所有能被除外的卡，作为选择除外候选组。
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		if rg:GetCount()>0 then
			-- 显示“请选择要除外的卡”的提示消息，供己方在对方场上卡片中选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	if bit.band(flag,LOCATION_GRAVE)~=0 then
		-- 获取对方墓地所有能被除外的卡，作为选择除外候选组。
		local rg=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,nil)
		if rg:GetCount()>0 then
			-- 显示“请选择要除外的卡”的提示消息，供己方在对方墓地卡片中选择要除外的卡。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			g:Merge(rg:Select(tp,1,2,nil))
		end
	end
	-- 将累计选中的卡片以表侧表示除外，除外原因记录为效果（REASON_EFFECT）。
	Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
end
