--剛鬼シーク・オーガ
-- 效果：
-- 「刚鬼」怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「刚鬼」怪兽用抽卡以外的方法从卡组加入自己手卡的场合才能发动。从手卡把「刚鬼」怪兽任意数量特殊召唤（相同等级最多1只）。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「刚鬼」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化效果：注册连接召唤手续，以及①效果（手卡特殊召唤）和②效果（融合召唤）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续：需要2只「刚鬼」怪兽作为连接素材。
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfc),2,2)
	-- ①：「刚鬼」怪兽用抽卡以外的方法从卡组加入自己手卡的场合才能发动。从手卡把「刚鬼」怪兽任意数量特殊召唤（相同等级最多1只）。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「刚鬼」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合效果"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 过滤从卡组加入自己手卡的「刚鬼」怪兽（非抽卡、非公开状态）。
function s.trigfilter(c,tp)
	return c:IsSetCard(0xfc) and c:IsControler(tp) and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
		and c:IsType(TYPE_MONSTER) and not c:IsStatus(STATUS_TO_HAND_WITHOUT_CONFIRM)
end
-- 检查是否有满足条件的「刚鬼」怪兽从卡组加入手卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.trigfilter,1,nil,tp)
end
-- 过滤手卡中可以特殊召唤的「刚鬼」怪兽。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xfc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果的发动准备：检查怪兽区域空位以及手卡中是否存在可特殊召唤的「刚鬼」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只可以特殊召唤的「刚鬼」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息（从手卡特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- ①效果的处理：从手卡选择任意数量等级互不相同的「刚鬼」怪兽特殊召唤，并对这些怪兽施加“只要在场上表侧表示存在，自己只能特殊召唤「刚鬼」怪兽”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域空格数量。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 获取手卡中所有可以特殊召唤的「刚鬼」怪兽。
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if g:GetCount()==0 then return end
	-- 提示玩家选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家选择1到ft张等级互不相同的怪兽。
	local sg=g:SelectSubGroup(tp,aux.dlvcheck,false,1,ft)
	-- 将选中的怪兽以表侧表示特殊召唤，若成功则执行后续处理。
	if Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 遍历所有成功特殊召唤的怪兽。
		for tc in aux.Next(sg) do
			-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「刚鬼」怪兽不能特殊召唤。自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「刚鬼」融合怪兽融合召唤。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetDescription(aux.Stringid(id,2))  --"「刚鬼 酋长食人魔」的效果特殊召唤"
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetAbsoluteRange(tp,1,0)
			e1:SetTarget(s.splimit)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
			tc:RegisterEffect(e1,true)
		end
	end
end
-- 限制只能特殊召唤「刚鬼」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0xfc)
end
-- 过滤不受效果影响的怪兽（用于融合素材筛选）。
function s.spfilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可以进行融合召唤的「刚鬼」融合怪兽。
function s.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0xfc) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动准备：检查是否能用手卡·场上的怪兽作为素材融合召唤1只「刚鬼」融合怪兽。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家手卡·场上可用于融合召唤的素材怪兽。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
		-- 检查额外卡组是否存在可以使用当前素材融合召唤的「刚鬼」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 检查是否存在可适用的连锁融合效果（如「连锁素材」）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁融合效果下，额外卡组是否存在可融合召唤的「刚鬼」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置特殊召唤的操作信息（从额外卡组特殊召唤1只怪兽）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：选择1只「刚鬼」融合怪兽，将手卡·场上的怪兽送去墓地作为融合素材，从额外卡组融合召唤。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取玩家手卡·场上可用于融合召唤的素材怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.spfilter1,nil,e)
	-- 获取额外卡组中可以使用当前素材融合召唤的「刚鬼」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 检查是否存在可适用的连锁融合效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁融合效果下，额外卡组中可融合召唤的「刚鬼」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判定是否使用常规融合方式（而非连锁融合效果）进行融合召唤。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家选择用于融合召唤该怪兽的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选中的融合素材送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理不与送去墓地同时处理。
			Duel.BreakEffect()
			-- 将融合怪兽以融合召唤的方式特殊召唤到场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 在连锁融合效果适用时，让玩家选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
