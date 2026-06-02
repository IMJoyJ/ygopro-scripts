--星辰砲手ファイメナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。自己的手卡·场上的怪兽作为融合素材，把1只龙族·魔法师族的融合怪兽融合召唤。
-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：自己·对方的主要阶段，把这张卡从手卡丢弃才能发动。自己的手卡·场上的怪兽作为融合素材，把1只龙族·魔法师族的融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合效果"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.fspcon)
	e1:SetCost(s.fspcost)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡成为融合召唤的素材送去墓地的场合才能发动。从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"盖放魔陷"
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己·对方的主要阶段
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- 效果①的发动代价：把这张卡从手卡丢弃
function s.fspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡丢弃并送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：过滤不受效果影响的怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：过滤可以融合召唤的龙族·魔法师族融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_DRAGON+RACE_SPELLCASTER) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果①的发动目标：检查是否存在合法的融合召唤目标并设置操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local c=e:GetHandler()
		local chkf=tp
		-- 获取玩家手卡·场上可用作融合素材的卡片，并排除不受效果影响的卡
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		if mg1:IsContains(c) then
			mg1:RemoveCard(c)
		end
		-- 检查额外卡组是否存在可以融合召唤的龙族·魔法师族融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家当前受到的连锁素材效果
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在受连锁素材效果影响下，检查额外卡组是否存在可以融合召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果①的效果处理：让玩家选择并融合召唤1只龙族·魔法师族融合怪兽
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家可用作融合素材的卡片，并排除不受效果影响的卡
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用玩家手卡·场上怪兽作为素材融合召唤的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果影响下可以融合召唤的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 检查是否能够使用自有素材融合召唤，或者让玩家选择是否适用连锁素材效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合召唤所需的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使后续的特殊召唤动作与前面的素材送墓不视为同时处理
			Duel.BreakEffect()
			-- 特殊召唤融合召唤的目标怪兽
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 从连锁素材允许的卡片组中选择融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果②的发动条件：此卡成为融合召唤的素材送去墓地
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_FUSION and not c:IsReason(REASON_RETURN)
end
-- 过滤函数：过滤卡组中可盖放的「星辰」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1c9) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- 效果②的发动目标：检查卡组中是否存在可盖放的「星辰」魔法·陷阱卡
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时，检查卡组中是否存在可盖放的「星辰」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- 效果②的效果处理：从卡组把1张「星辰」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查我方的魔陷区域是否有空位，若无则结束效果处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组检索并选择1张满足条件的「星辰」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的魔法·陷阱卡盖放在我方魔法与陷阱区域
		Duel.SSet(tp,tc)
	end
end
