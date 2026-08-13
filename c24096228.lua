--二重魔法
-- 效果：
-- 从手卡丢弃1张魔法卡，选择对方墓地1张魔法卡才能发动。选择的魔法卡在自己场上的正确卡区域放置并使用。
function c24096228.initial_effect(c)
	-- 从手卡丢弃1张魔法卡，选择对方墓地1张魔法卡才能发动。选择的魔法卡在自己场上的正确卡区域放置并使用。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c24096228.cost)
	e1:SetTarget(c24096228.target)
	e1:SetOperation(c24096228.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：手牌中存在可以丢弃且为魔法卡的卡片。
function c24096228.cfilter(c)
	return c:IsDiscardable() and c:IsType(TYPE_SPELL)
end
-- 发动代价函数：检查并执行从手卡丢弃1张魔法卡作为发动代价。
function c24096228.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检测：确认自己手牌中是否存在至少1张可丢弃的魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24096228.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际支付代价：从手卡丢弃1张魔法卡，丢弃原因记作代价+丢弃。
	Duel.DiscardHand(tp,c24096228.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 对象筛选1：选择对方墓地中能够发动效果的魔法卡；若为升阶魔法，还需额外满足其目标条件。
function c24096228.filter1(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(false,false,false)
	if c:IsType(TYPE_SPELL) and te then
		if c:IsSetCard(0x95) then
			local tg=te:GetTarget()
			return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	return false
end
-- 对象筛选2：选择对方墓地中能够发动效果且不是装备·永续魔法的魔法卡；若为升阶魔法，还需额外满足其目标条件。
function c24096228.filter2(c,e,tp,eg,ep,ev,re,r,rp)
	local te=c:CheckActivateEffect(false,false,false)
	if c:IsType(TYPE_SPELL) and not c:IsType(TYPE_EQUIP+TYPE_CONTINUOUS) and te then
		if c:IsSetCard(0x95) then
			local tg=te:GetTarget()
			return not tg or tg(e,tp,eg,ep,ev,re,r,rp,0)
		else
			return true
		end
	end
	return false
end
-- 发动选择对象的处理：根据自己魔陷区是否有空位，选择对方墓地1张符合条件的魔法卡作为对象。
function c24096228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local b=e:GetHandler():IsLocation(LOCATION_HAND)
		-- 获取自己魔陷区当前可用的空格数量。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if (b and ft>1) or (not b and ft>0) then
			-- 检测是否存在对方墓地中满足filter1条件的魔法卡（适用于魔陷区有空位时）。
			return Duel.IsExistingTarget(c24096228.filter1,tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		else
			-- 检测是否存在对方墓地中满足filter2条件的魔法卡（适用于魔陷区没有空位时）。
			return Duel.IsExistingTarget(c24096228.filter2,tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		end
	end
	-- 向当前玩家显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 如果自己魔陷区还有空位，则按允许装备·永续魔法的filter1条件选择对象。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 选择对方墓地1张满足filter1的魔法卡作为这张卡效果的对象。
		Duel.SelectTarget(tp,c24096228.filter1,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	else
		-- 选择对方墓地1张满足filter2的魔法卡作为这张卡效果的对象。
		Duel.SelectTarget(tp,c24096228.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 效果处理函数：将选择的对方墓地魔法卡移动到正确区域，并复制其发动所需的目标、代价和操作来实际发动并使用该魔法。
function c24096228.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时选择的对象卡（对方墓地的魔法卡）。
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	-- 清除当前连锁的效果对象，为后续复制魔法卡的发动做准备。
	Duel.ClearTargetCard()
	if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS)~=0 or tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		-- 若自己魔陷区没有空位，则无法放置需要占用魔陷区的魔法卡，效果处理终止。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 将对象魔法卡移动到自己的魔陷区并表侧表示放置，使其当场上的魔法卡使用。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	elseif bit.band(tpe,TYPE_FIELD)~=0 then
		-- 将对象魔法卡移动到自己的场地区并表侧表示放置，使其作为场地魔法使用。
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	end
	tc:CreateEffectRelation(te)
	if co then co(te,tp,eg,ep,ev,re,r,rp,1) end
	if tg then
		if tc:IsSetCard(0x95) then
			tg(e,tp,eg,ep,ev,re,r,rp,1)
		else
			tg(te,tp,eg,ep,ev,re,r,rp,1)
		end
	end
	-- 中断当前效果处理，使之后复制的魔法卡效果视为独立处理，以避免时点错误。
	Duel.BreakEffect()
	-- 获取当前连锁中被登记的对象卡组，用于给复制魔法卡的效果目标建立关联。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local etc=g:GetFirst()
	while etc do
		etc:CreateEffectRelation(te)
		etc=g:GetNext()
	end
	if op then
		if tc:IsSetCard(0x95) then
			op(e,tp,eg,ep,ev,re,r,rp)
		else
			op(te,tp,eg,ep,ev,re,r,rp)
		end
	end
	tc:ReleaseEffectRelation(te)
	etc=g:GetFirst()
	while etc do
		etc:ReleaseEffectRelation(te)
		etc=g:GetNext()
	end
end
