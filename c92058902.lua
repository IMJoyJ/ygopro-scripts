--未来融合－フューチャー・フュージョン・ノヴァ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，包含「电子龙」的自己卡组的怪兽作为融合素材，把1只机械族·光属性的融合怪兽融合召唤。这张卡从场上离开时那只怪兽破坏。那只怪兽破坏时这张卡破坏。这张卡的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤，不用由这个效果特殊召唤的怪兽不能攻击宣言。
local s,id,o=GetID()
-- 注册卡片发动的初始化函数
function s.initial_effect(c)
	-- 记录这张卡上记载着「电子龙」的事实
	aux.AddCodeList(c,70095154)
	-- ①：作为这张卡的发动时的效果处理，包含「电子龙」的自己卡组的怪兽作为融合素材，把1只机械族·光属性的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：过滤自己卡组里可以作为融合素材且能送去墓地的怪兽
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤条件：过滤额外卡组可进行融合特殊召唤的机械族、光属性融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	if not (c:IsType(TYPE_FUSION) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_LIGHT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false)) then return false end
	-- 在素材检查逻辑中挂载必须包含特定卡片（电子龙）的自定义检测函数
	aux.FCheckAdditional=s.fcheck
	local res=c:CheckFusionMaterial(m,nil,chkf)
	-- 恢复默认的融合素材检测附加条件
	aux.FCheckAdditional=nil
	return res
end
-- 素材额外检查规则：选中的融合素材中必须包含至少1只「电子龙」
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionCode,1,nil,70095154)
end
-- 效果①的发动靶向：检查是否能从自己卡组凑齐素材，将机械族·光属性的融合怪兽融合召唤，并设置特殊召唤的操作信息
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己卡组中所有符合融合素材条件且能送去墓地的卡片组
		local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
		-- 检查自己额外卡组是否存在可以以卡组中的怪兽为融合素材特殊召唤的机械族·光属性融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在受连锁素材效果影响的代替融合材料
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查自己额外卡组是否存在可以通过特定连锁素材效果特殊召唤的机械族·光属性融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：预计特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：从卡组中选择满足融合条件的怪兽送入墓地，融合召唤1只机械族·光属性融合怪兽，并注册彼此破坏的联动效果，以及后续的特召与攻击限制
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	-- 获取自己卡组中所有符合融合素材条件且能送去墓地的卡片
	local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK,0,nil)
	-- 获取自己额外卡组中所有可以被融合召唤的机械族·光属性融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 检查是否存在受连锁素材效果影响的代替融合材料
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取可以通过特定连锁素材效果的怪兽特殊召唤的机械族·光属性融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	local fid=0
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 在融合素材检查逻辑中挂载必须包含「电子龙」的自定义检测函数
		aux.FCheckAdditional=s.fcheck
		-- 检查选择的融合怪兽是否可以通过常规卡组进行融合召唤
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从符合条件的卡组怪兽中选择一组融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材作为融合材料送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的特殊召唤与送去墓地不视为同时处理
			Duel.BreakEffect()
			-- 将选定的融合怪兽融合召唤特殊召唤到场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家使用特定连锁素材效果选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		-- 恢复默认的融合素材检测附加条件
		aux.FCheckAdditional=nil
		tc:CompleteProcedure()
		c:SetCardTarget(tc)
		fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
		if c:IsOnField() and e:IsHasType(EFFECT_TYPE_ACTIVATE) and c:IsRelateToChain() then
			-- 这张卡从场上离开时那只怪兽破坏。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
			e1:SetCode(EVENT_LEAVE_FIELD)
			e1:SetOperation(s.desop)
			e1:SetReset(RESET_EVENT+RESET_TOFIELD)
			c:RegisterEffect(e1)
			-- 那只怪兽破坏时这张卡破坏。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
			e2:SetRange(LOCATION_SZONE)
			e2:SetCode(EVENT_LEAVE_FIELD)
			e2:SetCondition(s.descon2)
			e2:SetOperation(s.desop2)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2)
			c:SetCardTarget(tc)
		end
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 这张卡的发动后，直到回合结束时自己不是机械族怪兽不能特殊召唤，
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD)
		e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e3:SetTargetRange(1,0)
		e3:SetTarget(s.splimit)
		e3:SetReset(RESET_PHASE+PHASE_END)
		-- 注册此卡发动后自己不能特殊召唤机械族以外怪兽的限制
		Duel.RegisterEffect(e3,tp)
		-- 不用由这个效果特殊召唤的怪兽不能攻击宣言。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD)
		e4:SetCode(EFFECT_CANNOT_ATTACK)
		e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e4:SetTargetRange(LOCATION_MZONE,0)
		e4:SetTarget(s.ftarget)
		e4:SetLabel(fid)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册不用由这个效果特殊召唤的怪兽不能攻击宣言的限制
		Duel.RegisterEffect(e4,tp)
	end
end
-- 限制攻击宣言过滤条件：如果是不用由这个效果特殊召唤的其他怪兽，则限制其不能攻击宣言
function s.ftarget(e,c)
	return e:GetLabel()~=c:GetFlagEffectLabel(id)
end
-- 联动破坏操作：在这张卡离场时，将由其效果特殊召唤的融合怪兽破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏由于这张卡离场而受牵连的融合怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 联动破坏触发条件：如果作为对象的融合怪兽因为效果而被破坏
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	return tc and eg:IsContains(tc) and tc:IsReason(REASON_DESTROY)
end
-- 联动破坏操作：当融合怪兽被破坏时，将这张卡破坏
function s.desop2(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏这张卡自身
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end
-- 特殊召唤怪兽限制条件：非机械族怪兽无法被特殊召唤
function s.splimit(e,c)
	return not c:IsRace(RACE_MACHINE)
end
