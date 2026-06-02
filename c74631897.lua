--神芸なる知恵の乙女
-- 效果：
-- 「神艺」怪兽×2
-- 「神艺智慧少女」1回合1次用融合召唤以及以下方法才能特殊召唤。
-- ●把手卡1张魔法·陷阱卡丢弃，把自己的手卡·场上1只7星以上的「神艺」怪兽解放的场合可以从额外卡组特殊召唤。
-- ①：这张卡特殊召唤的场合才能发动。从卡组把1张「神艺」魔法·陷阱卡在自己场上盖放。
-- ②：对方回合才能发动1次。自己场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册该卡的效果手续：①特殊召唤成功时注册效果标记（以确保同名卡1回合1次召唤限制），②设定融合召唤的召唤限制，③设定用丢弃手卡魔陷、解放自己手卡/场上7星以上「神艺」怪兽从额外卡组特殊召唤的手续，④特殊召唤成功的场合从卡组盖放「神艺」魔法·陷阱卡，⑤在对方回合把场上怪兽作为融合素材融合召唤融合怪兽。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定融合素材：需要2只「神艺」怪兽
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
-- 获取符合特召解放要求的场上或手卡的卡片组（优先考虑包含外部解放效果的卡）
function s.getrg(tp,sc)
	-- 获取玩家拥有的所有可解放的卡片组（包含手卡）
	local rg=Duel.GetReleaseGroup(tp,true,REASON_SPSUMMON)
	local mrg=rg:Filter(Card.IsHasEffect,nil,EFFECT_EXTRA_RELEASE)
	if mrg:GetCount()>0 then
		return mrg:Filter(s.spfilter,nil,tp,sc)
	else
		return rg:Filter(s.spfilter,nil,tp,sc)
	end
end
-- 限制仅在未被特召且使用融合召唤的合法手段时才能进行该特殊召唤
function s.splimit(e,se,sp,st)
	-- 检验当前召唤类型为融合召唤，且本回合该玩家没有进行过此特召
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION and Duel.GetFlagEffect(sp,id)==0
end
-- 特殊召唤成功时触发，用以注册已特召的全局标记
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_FUSION) or c:GetFlagEffect(id)>0
end
-- 注册该玩家本回合已经特召过此卡的标记效果
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 为玩家注册本回合已特召该卡的标记效果，维持至回合结束
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 过滤可解放卡：属于「神艺」且为7星以上的怪兽，由自己控制或者是表侧表示，且能做特召素材、满足额外区域位置要求
function s.spfilter(c,tp,sc)
	return c:IsFusionSetCard(0x1cd) and c:IsLevelAbove(7)
		and (c:IsControler(tp) or c:IsFaceup())
		-- 验证该怪兽被解放后额外区域是否仍有空格可供此卡出场
		and Duel.GetLocationCountFromEx(tp,tp,c,sc)>0
		and c:IsCanBeFusionMaterial(sc,SUMMON_TYPE_SPECIAL)
end
-- 过滤特召的成本卡：手卡中的魔法·陷阱卡且必须是可丢弃送墓的
function s.cfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsDiscardable(REASON_SPSUMMON)
end
-- 规则特殊召唤的启用条件判定：未标记过此特召，场上/手卡有可解放的「神艺」怪兽，且手卡有可丢弃的魔法·陷阱卡
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 若本回合已特召过此卡，则不满足规则特召的条件
	if Duel.GetFlagEffect(tp,id)>0 then return false end
	local rg=s.getrg(tp,c)
	-- 判定场上/手卡是否有符合解放条件的怪兽，以及手卡是否有符合丢弃条件的魔法·陷阱卡
	return rg:GetCount()>0 and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 规则特殊召唤的操作准备（让玩家选择要丢弃的手卡魔陷以及被解放的怪兽，并暂存组）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	local g=s.getrg(tp,c)
	-- 获取手卡中所有符合丢弃条件的魔法·陷阱卡
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
-- 用于筛选未标记解放特征的卡（通常是作为被丢弃的成本卡）
function s.disfilter(c)
	return c:GetFlagEffect(id+o)==0
end
-- 规则特殊召唤的效果处理（注册特召过的标记，并执行丢弃手牌和解放怪兽的成本，完成特殊召唤）
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD-RESET_TOFIELD+RESET_PHASE+PHASE_END,0,1)
	local g=e:GetLabelObject()
	local dg=g:Filter(s.disfilter,nil)
	g:Sub(dg)
	-- 将丢弃的魔法·陷阱卡送去墓地
	Duel.SendtoGrave(dg,REASON_SPSUMMON+REASON_DISCARD)
	-- 解放选择的7星以上「神艺」怪兽
	Duel.Release(g,REASON_SPSUMMON)
	g:DeleteGroup()
end
-- 过滤卡组中的「神艺」魔法·陷阱卡（必须满足可在场上盖放的条件）
function s.setfilter(c)
	return c:IsSetCard(0x1cd) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSSetable()
end
-- ①号盖放效果的发动准备（检测卡组中是否有符合盖放条件的卡，并向对方发送提示信息）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可盖放的「神艺」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方提示该卡的效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- ①号盖放效果的效果处理（从卡组中选择一张符合条件的「神艺」魔法·陷阱卡并在场上盖放）
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组中检索并选择一张「神艺」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.setfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 在自己场上盖放所选的卡
		Duel.SSet(tp,tc)
	end
end
-- ②号融合效果的发动条件判定（必须是对方回合）
function s.fspcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前是否为对方回合
	return Duel.GetTurnPlayer()==1-tp
end
-- 融合素材过滤条件：在场上且不能是不受效果影响的卡
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e) and c:IsOnField()
end
-- 融合怪兽过滤条件：属于融合怪兽类型，能特殊召唤，且能以当前的素材进行融合召唤
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②号融合效果的发动准备（检查自己场上是否有素材可以融合召唤额外卡组的融合怪兽）
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取自己场上拥有的可作为融合素材的卡片组
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil)
		-- 检查额外卡组中是否存在可用自己场上素材进行融合召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检测玩家是否受到连锁素材（如「链素材」）等其他效果的影响
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若有连锁素材等效果影响，检查该前提下是否存在可特召的融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方提示该卡的效果发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置融合召唤特殊召唤操作的信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②号融合效果的效果处理（让玩家从额外卡组选择融合怪兽，并从场上选择素材送墓以融合召唤）
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 效果处理中：获取场上可用于融合的素材卡片并过滤抗性
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 效果处理中：获取额外卡组符合召唤条件的融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 效果处理中：获取其他适用的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 效果处理中：获取适用其他连锁素材效果时能召唤的融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规融合素材或询问使用连锁素材
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，以便融合怪兽入场
			Duel.BreakEffect()
			-- 将选择的融合怪兽特殊召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材中选择素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
