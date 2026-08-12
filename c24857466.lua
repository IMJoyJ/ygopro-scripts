--冥王竜ヴァンダルギオン
-- 效果：
-- 对方控制的卡的发动用反击陷阱无效的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，把无效的卡种类的以下效果发动。
-- ●魔法：给与对方基本分1500分伤害。
-- ●陷阱：选择对方场上1张卡破坏。
-- ●效果怪兽：从自己墓地选择1只怪兽在自己场上特殊召唤。
function c24857466.initial_effect(c)
	-- 对方控制的卡的发动用反击陷阱无效的场合，这张卡可以从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c24857466.chop)
	c:RegisterEffect(e2)
	-- 这个方法特殊召唤成功时，把无效的卡种类的以下效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(24857466,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_CHAIN_END)
	e3:SetRange(LOCATION_HAND)
	e3:SetCondition(c24857466.hspcon)
	e3:SetTarget(c24857466.hsptg)
	e3:SetOperation(c24857466.hspop)
	c:RegisterEffect(e3)
	-- ●魔法：给与对方基本分1500分伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24857466,1))  --"给与对方基本分1500分伤害"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+24857466)
	e4:SetTarget(c24857466.target)
	e4:SetOperation(c24857466.operation)
	c:RegisterEffect(e4)
end
-- 记录连锁被无效时的发动卡类型，用于后续特殊召唤后的效果触发判断。
function c24857466.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp then return end
	-- 获取当前被无效的连锁的无效原因效果和无效玩家。
	local de,dp=Duel.GetChainInfo(ev,CHAININFO_DISABLE_REASON,CHAININFO_DISABLE_PLAYER)
	if de and dp==tp and de:GetHandler():IsType(TYPE_COUNTER) then
		local ty=re:GetActiveType()
		local flag=c:GetFlagEffectLabel(24857466)
		if not flag then
			c:RegisterFlagEffect(24857466,RESET_EVENT+RESETS_STANDARD,0,0,ty)
			e:SetLabelObject(de)
		elseif de~=e:GetLabelObject() then
			e:SetLabelObject(de)
			c:SetFlagEffectLabel(24857466,ty)
		else
			c:SetFlagEffectLabel(24857466,flag|ty)
		end
	end
end
-- 检查是否满足特殊召唤条件，即是否有记录的无效卡类型。
function c24857466.hspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=c:GetFlagEffectLabel(24857466)
	if label~=nil and label~=0 then
		e:SetLabel(label)
		c:SetFlagEffectLabel(24857466,0)
		return true
	else return false end
end
-- 判断是否满足特殊召唤的条件，包括场上是否有空位和自身是否可以特殊召唤。
function c24857466.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤时的参数为无效卡的类型。
	Duel.SetTargetParam(e:GetLabel())
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，并在成功后触发自定义事件。
function c24857466.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 获取当前处理的连锁的目标参数。
		local tpe=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 触发自定义事件，用于后续效果处理。
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+24857466,e,0,0,tp,tpe)
	end
end
-- 用于筛选可以特殊召唤的怪兽。
function c24857466.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 根据无效卡类型设置对应的效果处理信息。
function c24857466.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then
		if ev==TYPE_TRAP then
			return chkc:IsControler(1-tp) and chkc:IsOnField()
		elseif ev==TYPE_MONSTER then
			return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c24857466.spfilter(chkc,e,tp)
		else
			return false
		end
	end
	if chk==0 then return true end
	local cat=0
	local prop=0
	if ev&TYPE_SPELL~=0 then
		cat=cat|CATEGORY_DAMAGE
		prop=prop|EFFECT_FLAG_PLAYER_TARGET
		-- 设置伤害目标为对方玩家。
		Duel.SetTargetPlayer(1-tp)
		-- 设置伤害值为1500。
		Duel.SetTargetParam(1500)
		-- 设置伤害操作信息。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
	if ev&TYPE_TRAP~=0 then
		cat=cat|CATEGORY_DESTROY
		prop=prop|EFFECT_FLAG_CARD_TARGET
		-- 提示选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上的1张卡作为破坏对象。
		local g1=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g1:GetCount()>0 then
			-- 设置破坏操作信息。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		end
	end
	if ev&TYPE_MONSTER~=0 then
		cat=cat|CATEGORY_SPECIAL_SUMMON
		prop=prop|EFFECT_FLAG_CARD_TARGET
		-- 提示选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只怪兽作为特殊召唤对象。
		local g2=Duel.SelectTarget(tp,c24857466.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 设置特殊召唤操作信息。
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
		end
	end
	e:SetCategory(cat)
	e:SetProperty(prop)
	e:SetLabel(ev)
end
-- 根据无效卡类型执行对应的效果处理。
function c24857466.operation(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	local res=0
	if typ&TYPE_SPELL~=0 then
		-- 获取伤害的目标玩家和伤害值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 对目标玩家造成指定伤害。
		res=Duel.Damage(p,d,REASON_EFFECT)
	end
	if typ&TYPE_TRAP~=0 then
		-- 获取破坏操作信息。
		local ex1,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
		if g1 then
			local tc1=g1:GetFirst()
			if tc1:IsRelateToEffect(e) then
				-- 如果已造成伤害，则中断当前效果处理。
				if res~=0 then Duel.BreakEffect() end
				-- 破坏指定的卡。
				res=Duel.Destroy(tc1,REASON_EFFECT)
			end
		end
	end
	if typ&TYPE_MONSTER~=0 then
		-- 获取特殊召唤操作信息。
		local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
		if g2 then
			local tc2=g2:GetFirst()
			if tc2:IsRelateToEffect(e) then
				-- 如果已造成伤害，则中断当前效果处理。
				if res~=0 then Duel.BreakEffect() end
				-- 将指定怪兽特殊召唤到场上。
				Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
