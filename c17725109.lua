--青眼龍轟臨
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己的卡组·墓地·除外状态的1只「青眼」怪兽守备表示特殊召唤。自己场上没有「青眼白龙」存在的场合，这个效果不是「青眼白龙」不能特殊召唤。这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
-- ②：把墓地的这张卡除外才能发动。包含「青眼」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
local s,id,o=GetID()
-- 注册这张卡的①②效果：①效果为魔法卡发动，可从卡组·墓地·除外区守备表示特殊召唤1只「青眼」怪兽并附加额外召唤限制；②效果为墓地起动效果，除外自身进行融合召唤；两个效果共享1回合1次的发动限制。
function s.initial_effect(c)
	-- 将「青眼白龙」的卡号记录到这张卡的效果外文本，用于判定是否记载「青眼白龙」卡名。
	aux.AddCodeList(c,89631139)
	-- ①：自己的卡组·墓地·除外状态的1只「青眼」怪兽守备表示特殊召唤。自己场上没有「青眼白龙」存在的场合，这个效果不是「青眼白龙」不能特殊召唤。这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。包含「青眼」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_FUSION_SUMMON+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动代价：将墓地中的这张卡除外。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 定义①效果可特殊召唤的怪兽过滤条件：必须是「青眼」怪兽且可被表侧守备表示特殊召唤；若自己场上没有「青眼白龙」，则只能选择「青眼白龙」。
function s.spfilter(c,e,tp)
	-- 检查自己场上是否存在表侧表示的「青眼白龙」，用于放宽选择范围。
	local sp=Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsCode),tp,LOCATION_ONFIELD,0,1,nil,89631139)
	return c:IsFaceupEx() and c:IsSetCard(0xdd)
		and (sp or c:IsCode(89631139))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ①效果的发动条件：自己主要怪兽区有空位，且卡组·墓地·除外区存在符合特殊召唤条件的「青眼」怪兽。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组·墓地·除外区是否存在满足s.spfilter条件的「青眼」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 设置特殊召唤的操作信息，表明该效果会从卡组·墓地·除外区特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：若有空位则选择符合条件的「青眼」怪兽表侧守备特殊召唤；随后给发动玩家附加“这个回合不能从额外卡组特殊召唤非龙族怪兽”的自肃效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 主要怪兽区没有空位时，效果处理失败并终止。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家弹出“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组·墓地·除外区选择1只满足s.spfilter且不受王家长眠之谷影响的「青眼」怪兽。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_DECK+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧守备表示特殊召唤。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
	-- 这个回合，自己不是龙族怪兽不能从额外卡组特殊召唤。②：把墓地的这张卡除外才能发动。包含「青眼」怪兽的自己的手卡·场上的怪兽作为融合素材，把1只融合怪兽融合召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将自肃效果注册到当前玩家，使该玩家这回合不能从额外卡组特殊召唤非龙族怪兽。
	Duel.RegisterEffect(e1,tp)
end
-- 定义自肃效果的限制条件：不能从额外卡组特殊召唤非龙族怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_DRAGON) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤不能免疫此效果的怪兽，免疫此效果的怪兽不能作为融合素材。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义可作为融合召唤对象的融合怪兽条件：必须是融合怪兽，在当前素材下满足融合召唤条件，且能被融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 追加检查融合素材：所选素材中必须存在至少1只「青眼」怪兽。
function s.fcheck(tp,sg,fc)
	return sg:IsExists(Card.IsFusionSetCard,1,nil,0xdd)
end
-- ②效果的发动条件判定：确认额外卡组是否存在能用自己手卡·场上的怪兽（含「青眼」怪兽）作为素材融合召唤的融合怪兽；若存在连锁素材等替代素材也一并检查。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的融合素材组（包括手卡·场上的怪兽及额外融合素材效果提供的素材）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 设置融合素材的追加检查条件：素材组合必须包含「青眼」怪兽。
		aux.FCheckAdditional=s.fcheck
		-- 检查额外卡组中是否存在能用当前通常素材融合召唤的融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除之前设置的素材追加检查，避免影响后续判断。
		aux.FCheckAdditional=nil
		if not res then
			-- 获取连锁素材等提供替代融合素材的效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在替代素材，检查使用替代素材时额外卡组是否有可融合召唤的融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息，标明将进行融合召唤特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果处理：选择1只融合怪兽，以自己手卡·场上的包含「青眼」怪兽的素材进行融合召唤；若使用连锁素材则按连锁素材效果处理。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的融合素材，并排除免疫此效果的怪兽。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 设置素材追加检查：素材组必须包含「青眼」怪兽。
	aux.FCheckAdditional=s.fcheck
	-- 获取额外卡组中所有能用当前通常素材融合召唤的融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除素材追加检查条件。
	aux.FCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材等替代融合素材的效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 使用替代素材时，获取额外卡组中所有能融合召唤的融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 根据所选融合怪兽是否能使用通常素材、是否使用替代素材来决定执行通常融合流程还是替代素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 选择通常素材前，设置素材必须包含「青眼」怪兽的追加检查。
			aux.FCheckAdditional=s.fcheck
			-- 让玩家从通常素材中选择1组合法的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 清除素材追加检查条件。
			aux.FCheckAdditional=nil
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送入墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使之后的融合召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 将融合怪兽以表侧攻击表示融合召唤到玩家场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 使用连锁素材时，让玩家从连锁素材效果提供的素材中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
