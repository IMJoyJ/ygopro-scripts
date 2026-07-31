--Mixousia the Confounder
local s,id,o=GetID()
-- 初始化卡片效果：注册融合召唤手续、①改变场上怪兽属性、②对方主要阶段除外素材融合召唤、③墓地改变自身属性效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 注册融合召唤手续：魔法师族怪兽＋魔法师族以外的怪兽
	aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),aux.FilterBoolFunction(aux.NOT(Card.IsRace),RACE_SPELLCASTER),true)
	-- ①：1回合1次，以场上1只表侧表示怪兽为对象才能发动。宣言那只怪兽持有的属性以外的1个属性。那只怪兽的属性变成宣言的属性。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.costg)
	e1:SetOperation(s.cosop)
	c:RegisterEffect(e1)
	-- ②：对方主要阶段才能发动。包含自己场上的这张卡，从自己的场上·墓地把融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_REMOVE+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.fspcon)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- ③：这张卡在墓地存在的场合才能发动。宣言这张卡持有的属性以外的1个属性。这张卡的属性直到回合结束时变成宣言的属性。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.atttg)
	e3:SetOperation(s.attop)
	c:RegisterEffect(e3)
end
-- 属性变更过滤条件：表侧表示且未拥有全部属性的怪兽
function s.cosfilter(c)
	return c:IsFaceup() and c:GetAttribute()~=ATTRIBUTE_ALL
end
-- ①效果发动准备：选择场上1只怪兽为对象，并宣言其未持有的属性
function s.costg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cosfilter(chkc) end
	-- 发动条件检查：场上是否存在符合条件的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cosfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要改变属性的表侧表示怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只怪兽作为对象
	local g=Duel.SelectTarget(tp,s.cosfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言对象怪兽当前不持有的1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~g:GetFirst():GetAttribute())
	e:SetLabel(att)
end
-- ①效果处理：将对象怪兽的属性变成宣言的属性
function s.cosop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToChain() and tc:IsFaceup() then
		-- 那只怪兽的属性变成宣言的属性。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- ②效果发动条件：对方回合的主要阶段
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合的主要阶段
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 融合素材过滤条件：可作为融合素材且可除外的怪兽
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 融合目标过滤条件：可用指定素材（含自身）融合召唤的融合怪兽
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ②效果发动准备：设置融合召唤的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取场上符合条件的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter1,nil,e)
		-- 获取墓地符合条件的融合素材
		local mg2=Duel.GetMatchingGroup(s.filter1,tp,LOCATION_GRAVE,0,nil,e)
		mg1:Merge(mg2)
		-- 检查额外卡组是否存在可包含自身融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 检查是否存在改变融合素材范围的全局效果（如连锁素材）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在特殊融合效果下是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：将场上·墓地包含此卡的素材除外，进行融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 获取场上可除外的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter1,nil,e)
	-- 获取墓地不受王谷影响且可除外的融合素材
	local mg2=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter1),tp,LOCATION_GRAVE,0,nil,e)
	mg1:Merge(mg2)
	-- 获取常规情况下可融合召唤的怪兽集合
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取全局特殊融合效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取特殊融合效果下可融合召唤的怪兽集合
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否按常规规则进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 提示玩家选择包含此卡在内的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材表侧表示除外
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 连接效果块（分隔素材除外与特殊召唤）
			Duel.BreakEffect()
			-- 将选中的融合怪兽进行融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 按特殊融合效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ③效果发动准备：宣言自身当前不持有的属性，并设置离墓操作信息
function s.atttg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家宣言此卡当前不持有的1个属性
	local att=Duel.AnnounceAttribute(tp,1,ATTRIBUTE_ALL&~e:GetHandler():GetAttribute())
	e:SetLabel(att)
	-- 设置连锁操作信息：此卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
-- ③效果处理：直到回合结束时将此卡的属性变成宣言的属性
function s.attop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否关联连锁且不受王谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 这张卡的属性直到回合结束时变成宣言的属性。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
