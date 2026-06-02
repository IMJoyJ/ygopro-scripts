--神芸なる知恵の乙女
-- 效果：
-- 「神艺」怪兽×2
-- 「神艺智慧少女」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●把手卡1张魔法·陷阱卡丢弃，把自己的手卡·场上1只7星以上的「神艺」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「神艺」魔法·陷阱卡在自己场上盖放。
-- ②：对方回合才能发动1次。自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册卡片初始效果（融合召唤手续、特殊召唤限制、特殊召唤成功时注册回合内已特召标记、额外卡组规则特召、①效果：特召成功时盖放卡组「神艺」魔陷、②效果：对方回合融合召唤）
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加融合召唤手续：需要2只「神艺」怪兽作为融合素材
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1cd),2,true)
	-- 「神艺智慧少女」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(s.condition)
	e0:SetOperation(s.regop)
	c:RegisterEffect(e0)
	-- 「神艺智慧少女」1回合1次用融合召唤以及以下方法才能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.splimit)
	c:RegisterEffect(e2)
	-- ●把手卡1张魔法·陷阱卡丢弃，把自己的手卡·场上1只7星以上的「神艺」怪兽解放的场合可以从额外卡组特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_SPSUMMON_PROC)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e3:SetRange(LOCATION_EXTRA)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「神艺」魔法·陷阱卡在自己场上盖放。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))  --"盖放"
	e4:SetCategory(CATEGORY_SSET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetTarget(s.settg)
	e4:SetOperation(s.setop)
	c:RegisterEffect(e4)
	-- ②：对方回合才能发动1次。自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e5:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_QUICK_O)
	e5:SetCode(EVENT_FREE_CHAIN)
	e5:SetRange(LOCATION_MZONE)
	e5:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e5:SetCountLimit(1)
	e5:SetCondition(s.fspcon)
	e5:SetTarget(s.fsptg)
	e5:SetOperation(s.fspop)
	c:RegisterEffect(e5)
end
-- 获取玩家可解放的、用于特殊召唤该卡的怪兽组（包含受额外解放效果影响的卡）
function s.getrg(tp,sc)
	-- 获取玩家可解放（非上级召唤用）的卡片组，包含手卡
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON)
	local mrg=rg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	if mrg:GetCount()>0 then
		return mrg:Filter(s.spfilter,nil,tp,sc)
	else
		return rg:Filter(s.spfilter,nil,tp,sc)
	end
end
-- 限制特殊召唤方式：必须是融合召唤，且该回合该玩家未特殊召唤过同名卡
function s.splimit(e,se,sp,st)
	-- 检查特殊召唤类型是否为融合召唤，且该玩家本回合未注册过该卡的特殊召唤标记
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 检查该卡是否通过融合召唤特殊召唤，或者本回合已经注册过特殊召唤标记
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 特殊召唤成功时，为玩家注册本回合已特殊召唤该卡的全局标记
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册全局标记，持续到回合结束，用于限制每回合只能特殊召唤1次
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤满足特殊召唤解放条件的卡：7星以上的「神艺」怪兽，且解放后能腾出额外怪兽区域的空格
function s.spfilter(c,tp,sc)
	return c:IsFusionSetCard(0x1cd) and c:IsLevelAbove(7)
		and (c:IsControler(tp) or c:IsFaceup())
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 过滤满足丢弃条件的卡：手卡中的魔法·陷阱卡
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable(REASON_SPSUMMON)
end
-- 规则特殊召唤的条件：本回合未特殊召唤过该卡，且存在可解放的怪兽和可丢弃的手卡魔陷
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若本回合已特殊召唤过该卡，则不能特殊召唤
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	local rg=s.getrg(tp,c)
	-- 检查是否存在可解放的怪兽，且手卡中是否存在可丢弃的魔法·陷阱卡
	return rg:GetCount()>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 规则特殊召唤的选择目标处理：选择要丢弃的手卡魔陷和要解放的怪兽，并保存为标签对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=s.getrg(tp,c)
	-- 获取手卡中所有满足丢弃条件的魔法·陷阱卡组
	local g2=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g2:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		-- 提示玩家选择要解放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		local tc2=g:SelectUnselect(nil,tp,false,true,1,1)
		if tc2 then
			tc2:RegisterFlagEffect(id+o,RESET_EVENT+RESETS_STANDARD,0,1)
			local sg=Group.FromCards(tc,tc2)
			sg:KeepAlive()
			e:SetLabelObject(sg)
			return true
		end
	end
	return false
end
-- 过滤出未被标记为解放目标的卡（即需要丢弃的卡）
function s.disfilter(c)
	return c:GetFlagEffect(id+o)==0
end
-- 规则特殊召唤的执行操作：注册本回合已特召标记，将选择的魔陷丢弃，将选择的怪兽解放
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	local dg=g:Filter(s.disfilter,nil)
	g:Sub(dg)
	-- 将作为特召消耗而丢弃的魔法·陷阱卡送去墓地
	Duel.SendtoGrave(dg,REASON_SPSUMMON+REASON_DISCARD)
	-- 解放作为特召消耗的怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤满足盖放条件的卡：卡组中的「神艺」魔法·陷阱卡
function s.setfilter(c)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的靶向处理：检查卡组中是否存在可盖放的「神艺」魔陷，并向对方提示发动效果
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可盖放的「神艺」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了盖放卡片的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①效果的执行操作：从卡组选择1张「神艺」魔法·陷阱卡在自己场上盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 让玩家从卡组选择1张满足盖放条件的「神艺」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- ②效果的发动条件：只能在对方回合发动
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为对方
	return Duel.GetTurnPlayer()==1-tp
end
-- 过滤不受效果影响且在场上的融合素材怪兽
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsOnField()
end
-- 过滤可进行融合召唤的额外卡组融合怪兽
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的靶向处理：检查自己场上的怪兽是否能作为素材融合召唤融合怪兽，并设置特殊召唤的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上可用的融合素材怪兽组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组是否存在可以使用场上素材进行融合召唤的怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果下，额外卡组是否存在可融合召唤的怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示发动了融合召唤的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁操作信息：从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的执行操作：选择1只融合怪兽，并使用场上的怪兽作为素材进行融合召唤
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取自己场上不受该效果影响的可用融合素材怪兽组
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 获取额外卡组中可以使用场上素材进行融合召唤的怪兽组
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果下，额外卡组中可融合召唤的怪兽组
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 检查是否使用场上的素材进行常规融合召唤（而非使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择一组满足融合召唤条件的场上素材怪兽
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选作融合素材的怪兽送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使之后的特殊召唤处理视为不同时处理
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤方式表侧表示特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁素材效果下，让玩家选择一组满足融合召唤条件的素材怪兽
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
