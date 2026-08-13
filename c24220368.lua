--ジェムナイト・ディスパージョン
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己的手卡·场上的怪兽作为融合素材，把1只「宝石骑士」融合怪兽融合召唤。自己墓地有「宝石骑士融合」存在的场合，卡组·额外卡组的岩石族以外的「宝石骑士」怪兽也能有最多2只作为融合素材。
-- ●自己的卡组·除外状态的1只「宝石」怪兽加入手卡。这个回合的主要阶段内，对方受到的效果伤害变成一半。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：登记关联卡名“宝石骑士融合”，并创建①效果（可在融合召唤与加入手卡两个选项中选择1个发动），设置为魔法卡发动、自由时点，指定目标和操作函数后注册到卡片上。
function s.initial_effect(c)
	-- 将“宝石骑士融合”（卡号1264319）登记为此卡记载的卡名，用于后续相关效果识别。
	aux.AddCodeList(c,1264319)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON|CATEGORY_SEARCH|CATEGORY_TOHAND|CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 定义追加素材过滤器：选择卡组·额外卡组中岩石族以外的“宝石骑士”怪兽，要求是可作融合素材且能送去墓地，对应“卡组·额外卡组的岩石族以外的「宝石骑士」怪兽”。
function s.filter0(c)
	return c:IsSetCard(0x1047) and not c:IsRace(RACE_ROCK)
		and c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 过滤掉对当前效果免疫的卡片，保证其可作为融合素材被该效果使用。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤可作为融合对象的“宝石骑士”融合怪兽：必须是融合怪兽、宝石骑士字段、满足连锁素材追加条件f（若有）、可被融合召唤特殊召唤，且能用给定素材m完成融合召唤。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1047) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤可检索的“宝石”怪兽：卡组或除外状态中表侧的“宝石”怪兽且可以加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x47) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 额外检查函数：限制融合素材中来自卡组·额外卡组的卡不超过2张。
function s.fcheck(tp,sg,fc)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
end
-- 素材组检查函数：同样限制卡组·额外卡组的素材不超过2张。
function s.gcheck(sg)
	return sg:FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)<=2
end
-- 效果发动时的目标处理：检测融合召唤（含追加素材/连锁素材）和检索“宝石”怪兽两个选项是否可用；若都可用则让玩家选择，并根据选择设置效果标签、本回合使用标志和操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	-- 获取玩家可用的融合素材（手卡·场上的怪兽及受额外效果影响的素材），并排除不受当前效果影响的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 检查自己墓地是否存在“宝石骑士融合”（卡号1264319），以决定是否允许使用卡组·额外卡组的追加素材。
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1264319) then
		-- 获取卡组·额外卡组中满足filter0条件的“岩石族以外的宝石骑士怪兽”作为潜在追加素材。
		local sg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil)
		mg1:Merge(sg)
		-- 设置融合素材选择时的额外检查函数，限制追加素材中来自卡组·额外卡组的卡不超过2张。
		aux.FCheckAdditional=s.fcheck
		-- 设置素材组的额外检查函数，限制合计最多2张来自卡组·额外卡组的素材。
		aux.GCheckAdditional=s.gcheck
	end
	-- 检查额外卡组是否存在能用当前素材mg1融合召唤的宝石骑士融合怪兽，以判断融合召唤选项是否可行。
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	-- 清除之前设置的额外融合素材检查函数，避免影响后续判断。
	aux.FCheckAdditional=nil
	-- 清除素材组额外检查函数。
	aux.GCheckAdditional=nil
	if not res then
		-- 获取当前玩家适用的“连锁素材”效果（若有），用于在常规素材不足时尝试用替代素材融合召唤。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材提供的素材组mg2和条件mf，再次检查额外卡组是否存在可融合召唤的宝石骑士融合怪兽。
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
	-- 确认融合召唤选项有效：既有可融合怪兽，又满足该选项本回合尚未使用（或在cost确认阶段暂不检查次数）。
	local b1=res and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	-- 检查卡组·除外状态中是否存在可加入手卡的“宝石”怪兽，判断检索选项是否可行。
	local b2=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,nil)
		-- 结合“1回合各能选择1次”限制，确认检索选项本回合未被使用过（或在cost确认阶段暂不检查次数）。
		and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and not b2 then
		-- 当只有融合召唤选项可行时，向对方玩家提示选择了“融合召唤”。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"融合召唤"
		op=1
	end
	if b2 and not b1 then
		-- 当只有加入手卡选项可行时，向对方玩家提示选择了“加入手卡”。
		Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,2))  --"加入手卡"
		op=2
	end
	if b1 and b2 then
		-- 当两个选项都可行时，让玩家从“融合召唤”和“加入手卡”中选择一个选项。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1)},  --"融合召唤"
			{b2,aux.Stringid(id,2)})  --"加入手卡"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON|CATEGORY_FUSION_SUMMON|CATEGORY_DECKDES)
			-- 注册本回合“融合召唤”选项已使用的标志，回合结束阶段重置，用于同名卡效果1回合1次限制。
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：效果可能将1只额外卡组的怪兽特殊召唤（融合召唤）。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
			-- 注册本回合“加入手卡”选项已使用的标志，回合结束阶段重置，用于同名卡效果1回合1次限制。
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置操作信息：效果可能从卡组·除外区将1张卡加入手卡。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_REMOVED)
	end
end
-- 效果处理时的操作：若选择融合召唤，则重新获取素材、选择融合怪兽并完成融合召唤；若选择加入手卡，则检索1张“宝石”怪兽加入手卡并展示，同时注册“对方受到的效果伤害变成一半”的持续效果。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local chkf=tp
		-- 效果处理时重新获取可用的融合素材，排除对当前效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		local exmat=false
		-- 处理时再次检查墓地是否有“宝石骑士融合”，以决定是否加入卡组·额外卡组的追加素材。
		if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,1264319) then
			-- 处理时获取卡组·额外卡组中可作为追加素材的“岩石族以外的宝石骑士怪兽”。
			local sg=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_DECK+LOCATION_EXTRA,0,nil,e)
			if sg:GetCount()>0 then
				mg1:Merge(sg)
				exmat=true
			end
		end
		if exmat then
			-- 融合召唤处理前设置额外检查函数，限制追加素材中卡组·额外卡组的卡不超过2张。
			aux.FCheckAdditional=s.fcheck
			-- 设置素材组额外检查函数，同样限制卡组·额外卡组素材数量。
			aux.GCheckAdditional=s.gcheck
		end
		-- 使用通常可用素材mg1筛选出可以融合召唤的宝石骑士融合怪兽集合。
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		-- 完成筛选后清除额外检查函数。
		aux.FCheckAdditional=nil
		-- 清除素材组额外检查函数。
		aux.GCheckAdditional=nil
		local mg2=nil
		local sg2=nil
		-- 获取“连锁素材”效果，若存在则可用于替代/补充融合素材。
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			-- 使用连锁素材提供的素材组mg2和条件mf，筛选出可融合召唤的宝石骑士融合怪兽集合。
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			-- 提示玩家选择要融合召唤的特殊召唤怪兽。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			mg1:RemoveCard(tc)
			-- 判断所选怪兽应使用通常素材还是连锁素材：若它属于通常素材可融合范围且玩家未选择使用连锁素材，则使用通常素材流程；否则使用连锁素材流程。
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
				if exmat then
					-- 使用通常素材流程前设置额外检查函数，限制追加素材数量。
					aux.FCheckAdditional=s.fcheck
					-- 设置素材组额外检查函数。
					aux.GCheckAdditional=s.gcheck
				end
				-- 让玩家从通常可用素材mg1中选择融合怪兽tc所需的融合素材。
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				-- 选择素材后清除额外检查函数。
				aux.FCheckAdditional=nil
				-- 清除素材组额外检查函数。
				aux.GCheckAdditional=nil
				tc:SetMaterial(mat1)
				-- 将选择的融合素材以效果·素材·融合的原因送去墓地，作为融合素材。
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				-- 中断当前效果处理，使后续特殊召唤成为独立时点，以便正确触发时点。
				Duel.BreakEffect()
				-- 将选定的融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上。
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			elseif ce~=nil then
				-- 使用连锁素材时，让玩家从连锁素材组mg2中选择所需的融合素材。
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要加入手卡的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组·除外状态中选择1张满足条件的“宝石”怪兽。
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK+LOCATION_REMOVED,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡加入持有者手卡（原因为效果）。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家展示加入手卡的卡。
			Duel.ConfirmCards(1-tp,g)
		end
		-- 检查是否已注册“本回合对方受到的效果伤害变成一半”的适用标志，避免重复适用。
		if Duel.GetFlagEffect(tp,51831560)==0 then
			-- 注册标志，记录本回合已适用过伤害减半效果，回合结束时重置。
			Duel.RegisterFlagEffect(tp,51831560,RESET_PHASE+PHASE_END,0,1)
			-- 这个回合的主要阶段内，对方受到的效果伤害变成一半。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetCode(EFFECT_CHANGE_DAMAGE)
			e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
			e1:SetTargetRange(0,1)
			e1:SetCondition(s.damcon)
			e1:SetValue(s.damval)
			e1:SetReset(RESET_PHASE+PHASE_END)
			-- 将伤害减半的持续效果注册到玩家tp，使其生效。
			Duel.RegisterEffect(e1,tp)
		end
	end
end
-- 伤害减半效果的适用条件：当前阶段为战斗阶段以外的主要阶段1或主要阶段2（即主要阶段内）。
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于条件判断。
	local ph=Duel.GetCurrentPhase()
	return ph==PHASE_MAIN1 or ph==PHASE_MAIN2
end
-- 伤害值变更函数：当伤害为效果伤害时，将伤害值除以2并向上取整；否则不改变。实现“对方受到的效果伤害变成一半”。
function s.damval(e,re,val,r,rp,rc)
	if r&REASON_EFFECT==REASON_EFFECT then
		return math.ceil(val/2)
	else return val end
end
