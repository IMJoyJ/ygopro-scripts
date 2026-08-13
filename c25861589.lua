--アロマブレンド
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：丢弃1张手卡才能发动。从手卡·卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张在自己的魔法与陷阱区域表侧表示放置。
-- ②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材除外，把1只植物族融合怪兽融合召唤。自己基本分比对方多的场合，也能把自己墓地的植物族怪兽除外作为融合素材。
local s,id,o=GetID()
-- 定义「芳香混合」的初始效果函数：登记其记载的卡名，并注册①效果（从手卡·卡组放置三风之一）与②效果（除外自身进行植物族融合召唤）。
function c25861589.initial_effect(c)
	-- 将卡号15177750（恩惠之风）、92266279（湿润之风）、28265983（干渴之风）加入本卡的记载卡名列表，用于识别此卡文本中提到的卡名。
	aux.AddCodeList(c,15177750,92266279,28265983)
	-- 对应效果原文：‘这个卡名的①②的效果1回合各能使用1次。①：丢弃1张手卡才能发动。从手卡·卡组把「湿润之风」「干渴之风」「恩惠之风」的其中1张在自己的魔法与陷阱区域表侧表示放置。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"放置"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- 对应效果原文：‘②：把墓地的这张卡除外才能发动。自己的手卡·场上的怪兽作为融合素材除外，把1只植物族融合怪兽融合召唤。自己基本分比对方多的场合，也能把自己墓地的植物族怪兽除外作为融合素材。’
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+o)
	-- 设置②效果的发动代价：把墓地的这张卡自身除外（aux.bfgcost 实现了除外自身作为代价）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 定义①效果的代价函数：检查并执行‘丢弃1张手卡’。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：手卡中是否存在1张可丢弃的卡（且不能丢弃发动效果的本卡），若存在则代价可支付。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 实际丢弃：从手卡选1张可丢弃的卡，以代价+丢弃的理由送入墓地。
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 定义筛选函数：选择卡名为恩惠之风（15177750）、湿润之风（92266279）或干渴之风（28265983）且不是禁止卡的卡片。
function s.filter(c)
	return c:IsCode(15177750,92266279,28265983) and not c:IsForbidden()
end
-- 定义①效果的发动目标判定：若自己魔陷区有可用空位，且手卡·卡组存在上述三风之卡，则可以发动。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 取得自己魔法与陷阱区域的空位数。
		local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ft=ft-1 end
		-- 返回‘有空位且存在可放置的三风之卡’作为能否发动的条件。
		return ft>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil)
	end
end
-- 定义①效果的处理：从手卡·卡组选择1张三风之卡，表侧表示放置到自己的魔陷区。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 处理时再次确认魔陷区有空位，否则不处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要放置到场上的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)  --"请选择要放置到场上的卡"
	-- 让玩家从手卡·卡组选择1张符合条件的卡（三风之一）。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的卡移动到自己的魔陷区，表侧表示放置并使其效果适用。
		Duel.MoveToField(tc,tp,tp,LOCATION_SZONE,POS_FACEUP,true)
	end
end
-- 定义常规融合素材的筛选条件：可以除外且不受当前效果影响。
function s.filter1(c,e)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义墓地植物族素材的预筛选条件：植物族、可作为融合素材且可以除外（用于判定能否追加素材）。
function s.exfilter0(c)
	return c:IsRace(RACE_PLANT) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 定义墓地植物族素材的实际筛选条件：植物族、可作为融合素材、可除外且不受当前效果影响。
function s.exfilter1(c,e)
	return c:IsRace(RACE_PLANT) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
end
-- 定义融合怪兽候选的筛选条件：额外卡组的植物族融合怪兽，满足用当前素材可融合召唤，并且能被效果特殊召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_PLANT) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义融合素材组的附加检查：素材中位于墓地的卡数量不得超过10张。
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=10
end
-- 定义素材组的另一个附加检查：同样限制墓地来源素材不超过10张。
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=10
end
-- 定义②效果的发动目标判定：检查能否用当前融合素材（LP多时还包括墓地植物族）融合召唤出植物族融合怪兽；若存在连锁素材效果也一并考虑。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取当前可用的融合素材（手卡·场上以及受额外融合素材效果影响的卡），并筛掉不能除外的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsAbleToRemove,nil)
		-- 判断自己基本分是否比对方多，以决定能否使用墓地植物族作为融合素材。
		if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
			-- 若LP多，取得自己墓地中可作为融合素材且可除外的植物族怪兽组。
			local sg=Duel.GetMatchingGroup(s.exfilter0,tp,LOCATION_GRAVE,0,nil)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				-- 设置全局附加检查 FCheckAdditional，用于限制素材中来自墓地的卡数量。
				aux.FCheckAdditional=s.fcheck
				-- 设置全局附加检查 GCheckAdditional，同样用于素材组合法性检查。
				aux.GCheckAdditional=s.gcheck
			end
		end
		-- 检查额外卡组中是否存在能用当前素材融合召唤的植物族融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		-- 清除 FCheckAdditional，避免影响后续判断。
		aux.FCheckAdditional=nil
		-- 清除 GCheckAdditional。
		aux.GCheckAdditional=nil
		if not res then
			-- 获取连锁素材效果（若有），用于后续替代素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若存在连锁素材效果，则用其提供的素材再次检查是否存在可融合召唤的植物族融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本次效果将特殊召唤1只额外卡组的怪兽（以便其他卡进行时点或限制检测）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义②效果的处理：实际选择融合怪兽，选择素材（LP多时可包含墓地植物族），除外素材并融合召唤；支持与连锁素材效果互动。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取当前可用的融合素材，并筛掉不能除外或不受当前效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	local exmat=false
	-- 再次判断LP是否比对方多，以决定是否追加墓地植物族素材。
	if Duel.GetLP(tp)>Duel.GetLP(1-tp) then
		-- 若LP多，取得墓地中可作为融合素材、可除外且不受当前效果影响的植物族怪兽组。
		local sg=Duel.GetMatchingGroup(s.exfilter1,tp,LOCATION_GRAVE,0,nil,e)
		if sg:GetCount()>0 then
			mg1:Merge(sg)
			exmat=true
		end
	end
	if exmat then
		-- 设置附加检查函数（限制墓地素材数量）。
		aux.FCheckAdditional=s.fcheck
		-- 设置附加检查函数。
		aux.GCheckAdditional=s.gcheck
	end
	-- 筛选出能用当前素材融合召唤的植物族融合怪兽列表 sg1。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	-- 清除附加检查。
	aux.FCheckAdditional=nil
	-- 清除附加检查。
	aux.GCheckAdditional=nil
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，用其提供的素材筛选可融合召唤的怪兽，得到 sg2。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的融合怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		mg1:RemoveCard(tc)
		-- 判断分支：若所选融合怪兽属于常规素材可融合的 sg1，且（没有连锁素材、或该怪兽不在 sg2 中、或玩家选择不使用连锁素材），则走常规融合流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			if exmat then
				-- 进入常规素材选择前，重新设置附加检查函数。
				aux.FCheckAdditional=s.fcheck
				-- 重新设置附加检查函数。
				aux.GCheckAdditional=s.gcheck
			end
			-- 让玩家从常规素材组中选择选中融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			-- 选择完成后清除附加检查。
			aux.FCheckAdditional=nil
			-- 清除附加检查。
			aux.GCheckAdditional=nil
			tc:SetMaterial(mat1)
			local rg=mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE)
			mat1:Sub(rg)
			-- 将选中的融合素材（包括手卡/场上和墓地来源）全部除外，理由为效果+素材+融合。
			Duel.Remove(mat1+rg,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使除外素材和融合召唤成为两个独立的处理步骤，避免错失时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将融合怪兽特殊召唤到自己场上，表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 在连锁素材分支中，让玩家从连锁素材提供的素材组中选择融合怪兽所需的素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
