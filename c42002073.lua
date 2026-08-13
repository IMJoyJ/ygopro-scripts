--EMトランプ・ガール
-- 效果：
-- ←4 【灵摆】 4→
-- 【怪兽效果】
-- ①：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：这张卡在灵摆区域被破坏的场合，以自己墓地1只龙族融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
function c42002073.initial_effect(c)
	-- 使这张卡获得灵摆怪兽属性，注册灵摆召唤与灵摆卡发动等基础规则处理。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，自己主要阶段才能发动。融合怪兽卡决定的包含这张卡的融合素材怪兽从自己场上送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c42002073.target)
	e2:SetOperation(c42002073.operation)
	c:RegisterEffect(e2)
	-- ②：这张卡在灵摆区域被破坏的场合，以自己墓地1只龙族融合怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽在结束阶段破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e6:SetCode(EVENT_DESTROYED)
	e6:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e6:SetCondition(c42002073.spcon)
	e6:SetTarget(c42002073.sptg)
	e6:SetOperation(c42002073.spop)
	c:RegisterEffect(e6)
end
-- 过滤融合素材：素材必须位于场上且不免疫本次效果。
function c42002073.filter1(c,e)
	return c:IsOnField() and not c:IsImmuneToEffect(e)
end
-- 检查额外卡组的怪兽是否可作为融合召唤对象：必须是融合怪兽、满足额外素材代替条件（如有）、能够以融合召唤方式特殊召唤，并且能用给定素材m（且必须包含gc）进行融合召唤。
function c42002073.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- 效果发动合法性检测：检查是否存在可用场上素材或连锁素材进行融合召唤的额外卡组怪兽；满足时登记操作信息。
function c42002073.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取当前玩家可用的融合素材，并仅保留场上的卡，以符合“从自己场上送去墓地”的要求。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 用场上素材检查额外卡组是否存在可融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(c42002073.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取当前玩家可用的连锁素材效果，作为代替融合素材的候选来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用连锁素材提供的代替素材，再次检查额外卡组是否存在可融合召唤的怪兽。
				res=Duel.IsExistingMatchingCard(c42002073.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 登记本次效果将进行特殊召唤（融合召唤）的操作信息，数量为1，位置为额外卡组。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果处理：先确认发动的这张卡仍有效且不免疫；然后分别获取普通场上素材和连锁素材，合并可融合召唤的怪兽列表供玩家选择；按选择使用普通素材或连锁素材进行融合召唤。
function c42002073.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToEffect(e) or c:IsImmuneToEffect(e) then return end
	-- 获取当前玩家可用的融合素材，并过滤出位于场上且不免疫本次效果的卡作为候选素材。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c42002073.filter1,nil,e)
	-- 用普通场上素材检索额外卡组中所有可融合召唤的融合怪兽，形成候选组sg1。
	local sg1=Duel.GetMatchingGroup(c42002073.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（代替素材），用于扩展可选融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材提供的代替素材检索额外卡组中所有可融合召唤的融合怪兽，形成候选组sg2。
		sg2=Duel.GetMatchingGroup(c42002073.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，让玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的融合怪兽应使用哪组素材：若它属于普通素材可选的怪兽，且（没有连锁素材或不在连锁素材组中，或玩家选择不使用连锁素材），则用普通素材；否则用连锁素材。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通场上素材组中选择融合召唤tc所需的融合素材，且素材中必须包含这张卡（扑克少女）。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，原因是效果并作为融合召唤的素材。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续融合召唤视为另一次处理，避免错失时点并正确触发召唤成功时的诱发效果。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧攻击表示特殊召唤到持有者场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 使用连锁素材时，让玩家从代替素材组中选择融合素材，且必须包含这张卡。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果②的发动条件：这张卡被破坏前所在区域是灵摆区域。
function c42002073.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_PZONE)
end
-- 墓地检索条件：被检索的怪兽必须是龙族融合怪兽，且能够被当前效果特殊召唤。
function c42002073.spfilter(c,e,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②发动时的合法性检测：自己主要怪兽区有空位，且墓地存在符合条件的龙族融合怪兽；若指定对象，则对象必须在墓地且满足检索条件。
function c42002073.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c42002073.spfilter(chkc,e,tp) end
	-- 检查自己主要怪兽区是否有空位，空位不足则不能发动特殊召唤效果。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查墓地是否存在1只符合条件的龙族融合怪兽，作为特殊召唤对象。
		and Duel.IsExistingTarget(c42002073.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 弹出选择提示，让玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的龙族融合怪兽作为效果对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c42002073.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记本次操作信息：将特殊召唤对象g，数量1，用于时点检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②处理：特殊召唤对象怪兽；若成功，给该怪兽登记标记，并注册结束阶段破坏该怪兽的效果。
function c42002073.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象（墓地那只龙族融合怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 确认对象仍与效果相关且特殊召唤成功（返回值非0），才继续处理结束阶段破坏效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(42002073,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 这个效果特殊召唤的怪兽在结束阶段破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetLabel(fid)
		e1:SetLabelObject(tc)
		e1:SetCondition(c42002073.descon)
		e1:SetOperation(c42002073.desop)
		-- 将结束阶段破坏怪兽的诱发效果注册到场上的效果管理器中，由当前玩家控制，在结束阶段时执行。
		Duel.RegisterEffect(e1,tp)
	end
end
-- 结束阶段破坏效果的发动条件：核对怪兽身上登记的标记是否为本效果设置的那个；若不是则重置该效果不再破坏，若是则保持有效。
function c42002073.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(42002073)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
-- 结束阶段处理：破坏标签对象所记录的怪兽。
function c42002073.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果破坏被特殊召唤的怪兽（该怪兽记录在效果标签对象中）。
	Duel.Destroy(e:GetLabelObject(),REASON_EFFECT)
end
