--冥王竜ヴァンダルギオン
-- 效果：
-- 对方控制的卡的发动用反击陷阱无效的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤成功时，把无效的卡种类的以下效果发动。
-- ●魔法：给与对方基本分1500分伤害。
-- ●陷阱：选择对方场上1张卡破坏。
-- ●效果怪兽：从自己墓地选择1只怪兽在自己场上特殊召唤。
function c24857466.initial_effect(c)
	-- 对方控制的卡的发动用反击陷阱无效的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_NEGATED)
	e2:SetRange(LOCATION_HAND)
	e2:SetOperation(c24857466.chop)
	c:RegisterEffect(e2)
	-- 这张卡可以从手卡特殊召唤。
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
	-- 这个方法特殊召唤成功时，把无效的卡种类的以下效果发动。●魔法：给与对方基本分1500分伤害。●陷阱：选择对方场上1张卡破坏。●效果怪兽：从自己墓地选择1只怪兽在自己场上特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(24857466,1))  --"给与对方基本分1500分伤害"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_CUSTOM+24857466)
	e4:SetTarget(c24857466.target)
	e4:SetOperation(c24857466.operation)
	c:RegisterEffect(e4)
end
-- 监视反击陷阱无效对方发动的卡的事件，若条件符合则记录被无效的卡类型（魔法/陷阱/怪兽）到本卡的标记中，为后续特殊召唤成功时选择对应效果做准备。
function c24857466.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if rp==tp then return end
	-- 从连锁信息中取得使这次发动被无效的原因效果和无效的玩家，判断是否为我方反击陷阱发动的无效。
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
-- 判断本卡是否记录过被反击陷阱无效的卡类型；若有则将类型值取出并清除标记，从而允许特殊召唤效果在连锁结束时发动。
function c24857466.hspcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local label=c:GetFlagEffectLabel(24857466)
	if label~=nil and label~=0 then
		e:SetLabel(label)
		c:SetFlagEffectLabel(24857466,0)
		return true
	else return false end
end
-- 特殊召唤的发动条件与发动时的处理：存在空位且此卡可以被特殊召唤时满足；发动时保存无效卡种类并登记特殊召唤操作信息。
function c24857466.hsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区域是否有空位，以供这张卡从手卡特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将之前记录的无效卡种类作为当前连锁的对象参数保存，供后续处理时读取。
	Duel.SetTargetParam(e:GetLabel())
	-- 登记操作信息：将这张卡进行特殊召唤，数量为1，不指定额外目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤的处理：若这张卡仍与发动效果关联，则将其表侧表示特殊召唤；成功后以无效卡种类为参数触发自定义事件，从而发动后续分类效果。
function c24857466.hspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤，并通过返回值判断特殊召唤是否成功（成功数不为0）。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 从当前连锁信息中取得之前保存的无效卡种类参数。
		local tpe=Duel.GetChainInfo(0,CHAININFO_TARGET_PARAM)
		-- 为本卡片触发一个自定义事件，事件参数为无效卡种类，用于启动后续的伤害、破坏或特殊召唤效果。
		Duel.RaiseSingleEvent(c,EVENT_CUSTOM+24857466,e,0,0,tp,tpe)
	end
end
-- 定义特殊召唤的过滤条件：选择墓地中能够被效果e由玩家tp特殊召唤的怪兽。
function c24857466.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 分类效果的发动阶段：根据被无效的卡种类（ev参数）分别设置目标与操作信息。魔法→给予对方1500伤害；陷阱→选择对方场上一张卡破坏；效果怪兽→从自己墓地选择一只怪兽特殊召唤。
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
		-- 将效果的对象玩家设为对方，即伤害的承受者。
		Duel.SetTargetPlayer(1-tp)
		-- 设置伤害参数为1500。
		Duel.SetTargetParam(1500)
		-- 登记伤害操作信息：向对方玩家造成1500分伤害。
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
	end
	if ev&TYPE_TRAP~=0 then
		cat=cat|CATEGORY_DESTROY
		prop=prop|EFFECT_FLAG_CARD_TARGET
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 从对方场上选择1张卡作为破坏对象（取对象）。
		local g1=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g1:GetCount()>0 then
			-- 登记破坏操作信息，目标为已选择的卡，数量1。
			Duel.SetOperationInfo(0,CATEGORY_DESTROY,g1,1,0,0)
		end
	end
	if ev&TYPE_MONSTER~=0 then
		cat=cat|CATEGORY_SPECIAL_SUMMON
		prop=prop|EFFECT_FLAG_CARD_TARGET
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己墓地选择1只满足特殊召唤条件的怪兽作为对象。
		local g2=Duel.SelectTarget(tp,c24857466.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g2:GetCount()>0 then
			-- 登记特殊召唤操作信息，目标为已选择的怪兽，数量1。
			Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g2,1,0,0)
		end
	end
	e:SetCategory(cat)
	e:SetProperty(prop)
	e:SetLabel(ev)
end
-- 分类效果的处理：若无效卡是魔法则造成伤害，是陷阱则破坏对象，是效果怪兽则特殊召唤对象；若前一操作成功则使用BreakEffect分隔处理，避免错过时点。
function c24857466.operation(e,tp,eg,ep,ev,re,r,rp)
	local typ=e:GetLabel()
	local res=0
	if typ&TYPE_SPELL~=0 then
		-- 从连锁信息中取得伤害对象玩家和伤害数值。
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 给予对方玩家1500分伤害，并将实际造成的伤害值记录到res。
		res=Duel.Damage(p,d,REASON_EFFECT)
	end
	if typ&TYPE_TRAP~=0 then
		-- 取得破坏操作信息中登记的目标卡组。
		local ex1,g1=Duel.GetOperationInfo(0,CATEGORY_DESTROY)
		if g1 then
			local tc1=g1:GetFirst()
			if tc1:IsRelateToEffect(e) then
				-- 若之前已造成伤害，则中断当前效果处理，使后续破坏作为新的一组处理，防止错过时点。
				if res~=0 then Duel.BreakEffect() end
				-- 破坏选定的卡，并将实际破坏数量赋给res。
				res=Duel.Destroy(tc1,REASON_EFFECT)
			end
		end
	end
	if typ&TYPE_MONSTER~=0 then
		-- 取得特殊召唤操作信息中登记的目标卡组。
		local ex2,g2=Duel.GetOperationInfo(0,CATEGORY_SPECIAL_SUMMON)
		if g2 then
			local tc2=g2:GetFirst()
			if tc2:IsRelateToEffect(e) then
				-- 若之前已有伤害或破坏处理成功，则中断效果处理，使特殊召唤作为新的一组处理，防止错过时点。
				if res~=0 then Duel.BreakEffect() end
				-- 将选定的墓地怪兽以表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc2,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
