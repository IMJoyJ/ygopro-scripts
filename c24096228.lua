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
-- 检索满足条件的卡片组
function c24096228.cfilter(c)
	return c:IsDiscardable() and c:IsType(TYPE_SPELL)
end
-- 将目标怪兽特殊召唤
function c24096228.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索满足条件的卡片组
	if chk==0 then return Duel.IsExistingMatchingCard(c24096228.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 将目标怪兽特殊召唤
	Duel.DiscardHand(tp,c24096228.cfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 检索满足条件的卡片组
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
-- 检索满足条件的卡片组
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
-- 检索满足条件的卡片组
function c24096228.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then
		local b=e:GetHandler():IsLocation(LOCATION_HAND)
		-- 返回玩家player的场上location可用的空格数
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if (b and ft>1) or (not b and ft>0) then
			-- 检索满足条件的卡片组
			return Duel.IsExistingTarget(c24096228.filter1,tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		else
			-- 检索满足条件的卡片组
			return Duel.IsExistingTarget(c24096228.filter2,tp,0,LOCATION_GRAVE,1,e:GetHandler(),e,tp,eg,ep,ev,re,r,rp)
		end
	end
	-- 向玩家提示“请选择效果的对象”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 返回玩家player的场上location可用的空格数
	if Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		-- 选择满足条件的目标卡片
		Duel.SelectTarget(tp,c24096228.filter1,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	else
		-- 选择满足条件的目标卡片
		Duel.SelectTarget(tp,c24096228.filter2,tp,0,LOCATION_GRAVE,1,1,nil,e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 从手卡丢弃1张魔法卡，选择对方墓地1张魔法卡才能发动。选择的魔法卡在自己场上的正确卡区域放置并使用。
function c24096228.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 返回当前连锁的所有的对象卡
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) then return end
	local tpe=tc:GetType()
	local te=tc:GetActivateEffect()
	local tg=te:GetTarget()
	local co=te:GetCost()
	local op=te:GetOperation()
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	-- 把当前正在处理的连锁的对象全部清除
	Duel.ClearTargetCard()
	if bit.band(tpe,TYPE_EQUIP+TYPE_CONTINUOUS)~=0 or tc:IsHasEffect(EFFECT_REMAIN_FIELD) then
		-- 返回玩家player的场上location可用的空格数
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
		-- 让玩家move_player把c移动到target_player的场上
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	elseif bit.band(tpe,TYPE_FIELD)~=0 then
		-- 让玩家move_player把c移动到target_player的场上
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
	-- 中断当前效果，使之后的效果处理视为不同时处理
	Duel.BreakEffect()
	-- 返回连锁chainc的信息
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
