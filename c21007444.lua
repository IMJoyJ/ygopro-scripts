--諸刃の活人剣術
-- 效果：
-- ①：以自己墓地2只「六武众」怪兽为对象才能发动。那些怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏，自己受到破坏的怪兽的攻击力合计数值的伤害。
function c21007444.initial_effect(c)
	-- 效果原文内容：①：以自己墓地2只「六武众」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21007444.target)
	e1:SetOperation(c21007444.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的「六武众」怪兽，这些怪兽可以被攻击表示特殊召唤。
function c21007444.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 检测是否满足发动条件：未被【青眼精灵龙】效果影响、场上怪兽区有足够空位、自己墓地存在2只符合条件的怪兽。
function c21007444.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21007444.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 检测场上怪兽区是否有至少1个空位（因为要特殊召唤2只怪兽）。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 检测自己墓地是否存在2只符合条件的「六武众」怪兽。
		and Duel.IsExistingTarget(c21007444.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择2只符合条件的墓地怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c21007444.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 设置效果操作信息，表示将特殊召唤2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理：获取连锁中选择的目标怪兽组，过滤出与效果相关的怪兽，检查是否有足够空位，若不足则进行选择，然后依次特殊召唤这些怪兽。
function c21007444.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选择的目标怪兽组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 获取玩家场上怪兽区的可用空位数。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or ft<=0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<sg:GetCount() then
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:FilterSelect(tp,c21007444.filter,ft,ft,nil,e,tp)
	end
	if sg:GetCount()>0 then
		local tc=sg:GetFirst()
		local fid=e:GetHandler():GetFieldID()
		while tc do
			-- 尝试特殊召唤一张怪兽。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
				tc:RegisterFlagEffect(21007444,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			end
			tc=sg:GetNext()
		end
		-- 完成所有特殊召唤步骤。
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 效果原文内容：那些怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏，自己受到破坏的怪兽的攻击力合计数值的伤害。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetReset(RESET_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetCondition(c21007444.descon)
		e1:SetOperation(c21007444.desop)
		e1:SetLabel(fid)
		e1:SetLabelObject(sg)
		-- 注册一个在结束阶段触发的持续效果，用于处理特殊召唤怪兽的破坏和伤害计算。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断怪兽是否属于本次特殊召唤的怪兽组。
function c21007444.desfilter(c,fid)
	return c:GetFlagEffectLabel(21007444)==fid
end
-- 判断是否还有属于本次特殊召唤的怪兽需要处理。
function c21007444.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c21007444.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 处理结束阶段效果：筛选出本次特殊召唤的怪兽，计算其攻击力总和，并对玩家造成相应伤害。
function c21007444.desop(e,tp,eg,ep,ev,re,r,rp)
	local sg=e:GetLabelObject()
	local dg=sg:Filter(c21007444.desfilter,nil,e:GetLabel())
	sg:DeleteGroup()
	if dg:GetCount()>0 then
		local tg1=dg:GetFirst()
		local at1=tg1:GetAttack()
		local tg2=dg:GetNext()
		local at2=0
		local dam=0
		if tg2 then at2=tg2:GetAttack() end
		-- 将符合条件的怪兽从场上破坏。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 获取实际被操作的卡片组。
		local og=Duel.GetOperatedGroup()
		if og:IsContains(tg1) then dam=dam+at1 end
		if tg2 and og:IsContains(tg2) then dam=dam+at2 end
		-- 如果计算出的伤害值不为0，则对玩家造成该数值的伤害。
		if dam~=0 then Duel.Damage(tp,dam,REASON_EFFECT) end
	end
end
