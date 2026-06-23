--白き森の罪宝
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上有恶魔族·幻想魔族·魔法师族怪兽的其中任意种存在的场合，可以从以下效果选择1个发动。
-- ●从手卡把1只恶魔族·幻想魔族·魔法师族怪兽特殊召唤。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
local s,id,o=GetID()
-- 创建主效果，允许发动，条件为场上有恶魔族·幻想魔族·魔法师族怪兽，可选择从手卡特殊召唤或融合召唤
function s.initial_effect(c)
	-- ①：自己场上有恶魔族·幻想魔族·魔法师族怪兽的其中任意种存在的场合，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动效果"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fscon)
	e1:SetTarget(s.fstg)
	e1:SetOperation(s.fsop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让怪兽的效果发动而被送去墓地的场合才能发动。这张卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 判断是否满足发动条件：场上有恶魔族·幻想魔族·魔法师族怪兽
function s.fscon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在至少1只同时满足‘正面表示’和‘种族为幻想魔族/魔法师族/恶魔族’的怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,1,nil,RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND)
end
-- 筛选手卡中可特殊召唤的恶魔族·幻想魔族·魔法师族怪兽
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_ILLUSION+RACE_SPELLCASTER+RACE_FIEND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 筛选可融合召唤的融合怪兽
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 设置发动效果的处理流程，判断是否能发动并选择发动方式
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否有足够的怪兽区
	local res1=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的恶魔族·幻想魔族·魔法师族怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp)
	local chkf=tp
	-- 获取玩家可用的融合素材，并排除免疫效果的怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
	-- 检查额外卡组中是否存在满足条件的融合怪兽
	local res2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res2 then
		-- 获取当前连锁中的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 再次检查额外卡组中是否存在满足条件的融合怪兽
			res2=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	if chk==0 then return res1 or res2 end
	local op=0
	if res1 and not res2 then
		-- 提示对方选择了“从手卡特殊召唤”
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"从手卡特殊召唤"
		op=1
	end
	if res2 and not res1 then
		-- 提示对方选择了“融合召唤”
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,3))  --"融合召唤"
		op=2
	end
	if res1 and res2 then
		-- 让玩家选择发动方式
		op=aux.SelectFromOptions(tp,
			{res1,aux.Stringid(id,2),1},  --"从手卡特殊召唤"
			{res2,aux.Stringid(id,3),2})  --"融合召唤"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 设置操作信息：将要特殊召唤1只手卡怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	elseif op==2 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
		-- 设置操作信息：将要特殊召唤1只额外卡组融合怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 执行发动效果的处理流程，根据选择的发动方式执行特殊召唤
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 检查手卡是否有足够的怪兽区
		if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 选择1只满足条件的手卡怪兽
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
			if g:GetCount()>0 then
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	elseif e:GetLabel()==2 then
		local chkf=tp
		-- 获取玩家可用的融合素材，并排除免疫效果的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(aux.NOT(Card.IsImmuneToEffect),nil,e)
		-- 获取满足条件的融合怪兽
		local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2,sg2=nil,nil
		-- 获取当前连锁中的融合素材效果
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 获取满足条件的融合怪兽
			sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if #sg1>0 or (sg2~=nil and #sg2>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			::cancel::
			-- 提示玩家选择要特殊召唤的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tc=sg:Select(tp,1,1,nil):GetFirst()
			-- 判断是否使用第一种融合方式
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				-- 选择融合素材
				local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				if #mat==0 then goto cancel end
				tc:SetMaterial(mat)
				-- 将融合素材送入墓地
				Duel.SendtoGrave(mat,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果
				Duel.BreakEffect()
				-- 将选中的融合怪兽特殊召唤到场上
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce~=nil then
				-- 选择融合素材
				local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				if #mat==0 then goto cancel end
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat)
			end
			tc:CompleteProcedure()
		end
	end
end
-- 判断是否满足盖放条件：此卡因支付费用而送入墓地且是怪兽效果发动
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 设置盖放效果的处理流程
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsSSetable() end
	-- 设置操作信息：将要盖放此卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,c,1,0,0)
end
-- 执行盖放效果的处理流程
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否还在场上且未受王家长眠之谷影响，若满足则盖放
	if c:IsRelateToEffect(e) and aux.NecroValleyFilter()(c) then Duel.SSet(tp,c) end
end
