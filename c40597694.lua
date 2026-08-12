--スキャッター・フュージョン
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：对方场上有怪兽存在的场合才能发动。岩石族以外的「宝石骑士」融合怪兽卡决定的融合素材怪兽从自己卡组送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡从场上离开时那只怪兽破坏。这个效果的发动后，直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
function c40597694.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：对方场上有怪兽存在的场合才能发动。岩石族以外的「宝石骑士」融合怪兽卡决定的融合素材怪兽从自己卡组送去墓地，把那1只融合怪兽从额外卡组融合召唤。这张卡从场上离开时那只怪兽破坏。这个效果的发动后，直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,40597694)
	e2:SetCondition(c40597694.condition)
	e2:SetTarget(c40597694.target)
	e2:SetOperation(c40597694.operation)
	c:RegisterEffect(e2)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetOperation(c40597694.desop)
	c:RegisterEffect(e3)
end
-- 对方场上有怪兽存在的场合才能发动。
function c40597694.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方场上有怪兽存在
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤满足融合素材条件的怪兽（可被送去墓地）
function c40597694.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤满足融合素材条件的怪兽（可被送去墓地，且不被效果免疫）
function c40597694.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave() and not c:IsImmuneToEffect(e)
end
-- 过滤满足融合召唤条件的「宝石骑士」融合怪兽（非岩石族）
function c40597694.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and not c:IsRace(RACE_ROCK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 判断是否满足发动条件，包括是否有符合条件的融合怪兽可特殊召唤
function c40597694.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取满足条件的卡组怪兽作为融合素材
		local mg1=Duel.GetMatchingGroup(c40597694.filter0,tp,LOCATION_DECK,0,nil)
		-- 检查是否有符合条件的融合怪兽
		local res=Duel.IsExistingMatchingCard(c40597694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前连锁的融合素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查是否有符合条件的融合怪兽（使用连锁素材）
				res=Duel.IsExistingMatchingCard(c40597694.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，表示将特殊召唤融合怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤操作，选择融合怪兽并处理融合素材
function c40597694.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取满足条件的卡组怪兽作为融合素材
	local mg1=Duel.GetMatchingGroup(c40597694.filter1,tp,LOCATION_DECK,0,nil,e)
	-- 获取满足条件的额外卡组融合怪兽
	local sg1=Duel.GetMatchingGroup(c40597694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取当前连锁的融合素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取满足条件的额外卡组融合怪兽（使用连锁素材）
		sg2=Duel.GetMatchingGroup(c40597694.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用原融合素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果
			Duel.BreakEffect()
			-- 将融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 选择融合怪兽的融合素材（使用连锁素材）
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
		e:GetHandler():SetCardTarget(tc)
	end
	-- 设置直到回合结束时自己不是「宝石骑士」怪兽不能从额外卡组特殊召唤的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c40597694.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果，使自己不能特殊召唤非宝石骑士融合怪兽
	Duel.RegisterEffect(e1,tp)
end
-- 限制非宝石骑士融合怪兽从额外卡组特殊召唤
function c40597694.splimit(e,c)
	return not c:IsSetCard(0x1047) and c:IsLocation(LOCATION_EXTRA)
end
-- 当卡片离开场上时，破坏目标怪兽
function c40597694.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
