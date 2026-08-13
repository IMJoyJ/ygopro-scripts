--諸刃の活人剣術
-- 效果：
-- ①：以自己墓地2只「六武众」怪兽为对象才能发动。那些怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏，自己受到破坏的怪兽的攻击力合计数值的伤害。
function c21007444.initial_effect(c)
	-- ①：以自己墓地2只「六武众」怪兽为对象才能发动。那些怪兽攻击表示特殊召唤。这个效果特殊召唤的怪兽在这个回合的结束阶段破坏，自己受到破坏的怪兽的攻击力合计数值的伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c21007444.target)
	e1:SetOperation(c21007444.activate)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：对象必须是「六武众」系列怪兽，且能够以表侧攻击表示被特殊召唤。
function c21007444.filter(c,e,tp)
	return c:IsSetCard(0x103d) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 目标检测函数：若正在连锁确认对象，则验证该对象是否为己方墓地的「六武众」且可特殊召唤；若为发动时点检查，则确认己方不受青眼精灵龙限制、有足够怪兽区空间且墓地存在至少2只满足条件的对象。
function c21007444.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c21007444.filter(chkc,e,tp) end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,59822133)
		-- 同时确认自己场上至少有2个可用的主要怪兽区域，用于容纳2只特殊召唤的怪兽。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>1
		-- 确认自己墓地存在至少2只满足特殊召唤条件的「六武众」怪兽，并且能够作为效果的对象。
		and Duel.IsExistingTarget(c21007444.filter,tp,LOCATION_GRAVE,0,2,nil,e,tp) end
	-- 给操作者显示选择提示：请选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择2只满足条件的「六武众」怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,c21007444.filter,tp,LOCATION_GRAVE,0,2,2,nil,e,tp)
	-- 向系统登记本次连锁的处理信息：该效果包含特殊召唤，对象为g中的2只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,2,0,0)
end
-- 效果处理函数：取得发动时的对象并过滤仍关联的卡；根据可用怪兽区数量决定实际特召数量；逐只以表侧攻击表示特殊召唤，成功后为每只怪兽设置标识；最后注册一个结束阶段时破坏这些怪兽并给予自己伤害的延迟效果。
function c21007444.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本连锁发动时选择的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 获取自己场上当前可用的怪兽区域数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if sg:GetCount()==0 or ft<=0 or (sg:GetCount()>1 and Duel.IsPlayerAffectedByEffect(tp,59822133)) then return end
	if ft<sg:GetCount() then
		-- 若可用怪兽区不足，则提示操作者选择要实际特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		sg=sg:FilterSelect(tp,c21007444.filter,ft,ft,nil,e,tp)
	end
	if sg:GetCount()>0 then
		local tc=sg:GetFirst()
		local fid=e:GetHandler():GetFieldID()
		while tc do
			-- 将tc以表侧攻击表示特殊召唤到己方场上，作为同批次特殊召唤的一步；若成功则继续执行后续处理。
			if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_ATTACK) then
				tc:RegisterFlagEffect(21007444,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
			end
			tc=sg:GetNext()
		end
		-- 完成这一批次的多只怪兽特殊召唤，并触发相关时点。
		Duel.SpecialSummonComplete()
		sg:KeepAlive()
		-- 这个效果特殊召唤的怪兽在这个回合的结束阶段破坏，自己受到破坏的怪兽的攻击力合计数值的伤害。
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
		-- 将结束阶段的延迟效果注册到当前玩家场上，使其在回合结束时执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判断怪兽是否为本次效果特殊召唤的怪兽：通过比较其标志效果标签是否为记录的唯一标识fid。
function c21007444.desfilter(c,fid)
	return c:GetFlagEffectLabel(21007444)==fid
end
-- 结束阶段延迟效果的发动条件：检查记录的对象组中是否仍存在本次特殊召唤且未被破坏的怪兽；若没有则清除该组并重置效果，否则效果生效。
function c21007444.descon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(c21007444.desfilter,1,nil,e:GetLabel()) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return true end
end
-- 结束阶段处理：取得本次特殊召唤并仍存在于场上的怪兽，将它们破坏；根据实际被破坏的怪兽的攻击力合计数值，给予自己（发动者）效果伤害。
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
		-- 将这些被标记的怪兽全部以效果破坏。
		Duel.Destroy(dg,REASON_EFFECT)
		-- 获取刚才被破坏实际操作的卡片组，用于判定哪些怪兽确实被破坏。
		local og=Duel.GetOperatedGroup()
		if og:IsContains(tg1) then dam=dam+at1 end
		if tg2 and og:IsContains(tg2) then dam=dam+at2 end
		-- 若合计伤害不为0，则给予自己（发动者）相应数值的效果伤害。
		if dam~=0 then Duel.Damage(tp,dam,REASON_EFFECT) end
	end
end
