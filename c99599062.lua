--地縛融合
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。这张卡在场地区域没有卡存在的场合，不在自己·对方的主要阶段不能发动。
-- ①：自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
-- ②：场地区域有卡存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从自己的手卡·墓地把1只「地缚」怪兽特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（魔法卡发动时进行融合召唤）与②效果（墓地发动，除外自身特殊召唤「地缚」怪兽并附加融合·同调以外不能从额外卡组特殊召唤的限制）。
function s.initial_effect(c)
	-- ①：自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：场地区域有卡存在的场合，自己主要阶段把墓地的这张卡除外才能发动。从自己的手卡·墓地把1只「地缚」怪兽特殊召唤。这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动COST：将墓地的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetCondition(s.condition1)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- ②效果的发动条件：自己回合的主要阶段，且双方场地区域有卡存在。
function s.condition1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前阶段，用于判断是否为主要阶段1或主要阶段2。
	local ph=Duel.GetCurrentPhase()
	-- 判定当前回合玩家为自己，并且处于主要阶段1或主要阶段2，从而满足『自己主要阶段』的发动时机。
	return Duel.GetTurnPlayer()==tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
		-- 检查双方场地区域是否存在至少1张卡，作为②效果可发动的另一条件。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 定义可特殊召唤的怪兽：必须是「地缚」系列怪兽，并且能够被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x21) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果发动时（chk==0）需要满足：自己场上有空余的怪兽区域，且手卡·墓地存在符合条件的「地缚」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动确认阶段，检查自己场上是否存在可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 同时检查手卡·墓地是否存在至少1只满足s.spfilter的「地缚」怪兽，以保证有可特殊召唤的目标。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：包含特殊召唤，预计从手卡·墓地特殊召唤1只怪兽（不取对象，处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- ②效果处理：从手卡·墓地选择1只符合条件的「地缚」怪兽特殊召唤；随后给自己玩家附加本回合不能从额外卡组特殊召唤融合·同调以外怪兽的自肃效果。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用怪兽区域，若有则进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 弹出卡片选择提示，提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从自己的手卡·墓地选择1只满足过滤条件且不受王家长眠之谷影响的「地缚」怪兽，并取得该卡对象。
		local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
		if tc then
			-- 将选择的怪兽以表侧表示特殊召唤到自己的怪兽区域。
			Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是融合·同调怪兽不能从额外卡组特殊召唤。①：自己的手卡·场上的怪兽作为融合素材，把1只暗属性融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述的额外卡组特殊召唤限制效果注册给当前玩家，使其本回合生效。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的判定：从额外卡组特殊召唤的怪兽若不是融合怪兽且不是同调怪兽，则禁止特殊召唤。
function s.splimit(e,c)
	return not (c:IsType(TYPE_SYNCHRO) or c:IsType(TYPE_FUSION)) and c:IsLocation(LOCATION_EXTRA)
end
-- ①效果的发动条件：场地区域有卡存在，或者当前处于任一方的主要阶段（等价于场地无卡时仅限自己·对方的主要阶段发动）。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于后续判断是否为主要阶段。
	local ph=Duel.GetCurrentPhase()
	-- 检查双方场地区域是否存在至少1张卡，若存在则该分条件成立。
	return Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
		or ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 过滤融合素材：排除对当前效果免疫的怪兽，这些卡不能作为融合素材使用。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义可作为融合召唤目标的融合怪兽：必须是暗属性融合怪兽，能通过融合召唤方式特殊召唤，且用给定素材能通过融合素材判定。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsAttribute(ATTRIBUTE_DARK) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ①效果发动时检查额外卡组是否存在可被当前素材融合召唤的暗属性融合怪兽；若通常素材不足，再检查代替融合素材效果，最后设置特殊召唤操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的全部融合素材（手卡·场上的怪兽及额外融合素材效果提供的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 检查额外卡组中是否存在至少1只可以使用mg1作为融合素材来融合召唤的暗属性融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家可能适用的代替融合素材效果（如连锁素材），没有则为nil。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 使用代替素材组mg2再次检查额外卡组是否存在可融合召唤的暗属性融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置①效果的操作信息：类别为特殊召唤（融合召唤），预计从额外卡组特殊召唤1只融合怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行融合召唤处理：选择1只暗属性融合怪兽，根据情况选择通常素材或代替素材，将素材送去墓地并特殊召唤该融合怪兽。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用融合素材，并过滤掉对当前效果免疫的卡牌，得到普通融合素材组。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 从额外卡组筛选出可以用普通素材融合召唤的全部暗属性融合怪兽，作为可选目标集合sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取代替融合素材效果（若存在），用于扩展可用的融合素材。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用代替素材组筛选出额外卡组中可融合召唤的暗属性融合怪兽，作为备选目标集合sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 弹出选择提示，让玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中怪兽是否属于普通素材可选且玩家不使用代替素材：若是，则走通常融合流程；否则走代替素材融合流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 在通常融合流程中，从普通可用素材中为选中的融合怪兽选择一组满足条件的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地（效果·素材·融合召唤原因）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使素材送墓与融合召唤分属不同时点，避免错过诱发效果时点。
			Duel.BreakEffect()
			-- 将选中的融合怪兽以融合召唤方式表侧表示特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在代替素材融合流程中，从代替素材集合中为选中的融合怪兽选择一组融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
