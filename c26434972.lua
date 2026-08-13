--刻まれし魔の憐歌
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
local s,id,o=GetID()
-- 初始化效果：创建并注册两个效果。e1为①效果（发动魔法卡，赋予本回合战斗保护），e2为②效果（墓地除外自身，进行「刻魔」融合召唤）。
function s.initial_effect(c)
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不会被战斗破坏"
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	-- 设置①效果的发动条件为aux.bpcon，即只能在战斗阶段或可进入战斗阶段的时点发动。
	e1:SetCondition(aux.bpcon)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCountLimit(1,id)
	-- 设置②效果的发动COST：将墓地中的这张卡除外（aux.bfgcost实现）。
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(s.fstg)
	e2:SetOperation(s.fsop)
	c:RegisterEffect(e2)
end
s.fusion_effect=true
-- 定义①效果的发动条件判定函数：通过flag检查本回合尚未发动过该①效果，满足条件才能发动。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性检查（chk==0）时，返回Duel.GetFlagEffect(tp,id)==0，即本回合没有发动过①效果。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
end
-- ①效果处理：给己方场上恶魔族·光属性怪兽附加不会被战斗破坏的效果，给自己附加战斗伤害减半的效果，并登记本回合发动过①效果的flag。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTarget(s.ptfilter)
	e1:SetValue(1)
	-- 将“恶魔族·光属性怪兽不会被战斗破坏”的场地效果注册给己方，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	-- ①：这个回合中，自己的恶魔族·光属性怪兽不会被战斗破坏，自己受到的战斗伤害变成一半。②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将“自己受到的战斗伤害减半”的效果注册给己方玩家，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
	-- 登记本回合已经发动过①效果的flag，回合结束阶段重置。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
end
-- 定义①效果的适用对象过滤条件：己方场上的表侧表示的恶魔族·光属性怪兽。
function s.ptfilter(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end
-- 定义用作额外融合素材的卡的判定：该卡在魔法与陷阱区域当作装备魔法卡使用，且装备对象是表侧的「刻魔」怪兽，并且该卡原本是怪兽卡。
function s.mttg(e,c)
	local tc=c:GetEquipTarget()
	return tc and tc:IsFaceup() and tc:IsSetCard(0x1b0) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 定义额外融合素材的归属限制：素材卡必须由效果发动者控制，防止使用对方场上的卡作为素材。
function s.fuslimit(e,c,sumtype)
	if not c then return false end
	return c:IsControler(e:GetHandlerPlayer())
end
-- 定义可选融合怪兽的条件：卡名属于「刻魔」的融合怪兽，能够以融合召唤方式特殊召唤，且当前可用素材能满足其融合素材要求。
function s.filter(c,e,tp,m,f,chkf)
	return c:IsSetCard(0x1b0) and c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤掉对当前效果免疫的卡，这些卡不能作为融合素材。
function s.filter2(c,e)
	return not c:IsImmuneToEffect(e)
end
-- ②效果的目标判定：临时允许魔法陷阱区中符合条件的装备魔法化怪兽作为融合素材，检查额外卡组是否存在可融合召唤的「刻魔」融合怪兽；若没有，再检查连锁素材，并设置特殊召唤的操作信息。
function s.fstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
		local me=Effect.CreateEffect(e:GetHandler())
		me:SetType(EFFECT_TYPE_FIELD)
		me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
		me:SetTargetRange(LOCATION_SZONE,0)
		me:SetTarget(s.mttg)
		me:SetValue(s.fuslimit)
		-- 将“魔法陷阱区中符合条件的当作装备魔法卡的怪兽可作为融合素材”的额外融合素材效果暂时注册到场上。
		Duel.RegisterEffect(me,tp)
		local chkf=tp
		-- 取得当前可用的融合素材（场上怪兽及额外融合素材效果提供的卡），并过滤掉对效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter2,nil,e)
		-- 检查额外卡组是否存在1张满足条件的「刻魔」融合怪兽，能用当前素材进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家适用的连锁素材效果（如果有），用于检查是否能通过连锁素材提供额外的融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在使用连锁素材提供的素材的情况下，再次检查额外卡组是否存在可融合召唤的「刻魔」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		me:Reset()
		return res
	end
	-- 将本次效果的操作信息设定为特殊召唤1只怪兽到己方额外卡组区域（CATEGORY_SPECIAL_SUMMON），用于后续连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的实际处理：临时允许额外素材，收集可融合素材和可选融合怪兽，选择要融合召唤的「刻魔」融合怪兽，选择素材并送墓，进行融合召唤；若适用连锁素材则按连锁素材处理。
function s.fsop(e,tp,eg,ep,ev,re,r,rp)
	-- ②：把墓地的这张卡除外才能发动。自己场上的怪兽作为融合素材，把1只「刻魔」融合怪兽融合召唤。那个时候，「刻魔」怪兽装备的自己的魔法与陷阱区域的当作装备魔法卡使用的融合素材怪兽也能作为融合素材使用。
	local me=Effect.CreateEffect(e:GetHandler())
	me:SetType(EFFECT_TYPE_FIELD)
	me:SetCode(EFFECT_EXTRA_FUSION_MATERIAL)
	me:SetTargetRange(LOCATION_SZONE,0)
	me:SetTarget(s.mttg)
	me:SetValue(s.fuslimit)
	-- 在效果处理时也临时注册“魔法陷阱区中符合条件的当作装备魔法卡的怪兽可作为融合素材”的效果。
	Duel.RegisterEffect(me,tp)
	local chkf=tp
	-- 取得场上融合素材（含额外素材），排除对效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsOnField,nil):Filter(s.filter2,nil,e)
	-- 选出额外卡组中所有可用当前素材融合召唤的「刻魔」融合怪兽。
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取连锁素材效果（若有），以扩展可用素材范围。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材，则用连锁素材提供的素材选出额外的可融合召唤的「刻魔」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 弹出选择提示，要求玩家从候选的融合怪兽中选择要特殊召唤的1只。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 若所选融合怪兽可用普通素材融合，且玩家不使用连锁素材（或不存在连锁素材候选），则走普通召唤流程；否则使用连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 在普通融合召唤流程中，让玩家从mg1中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat1==0 then goto cancel end
			tc:SetMaterial(mat1)
			-- 将选择的融合素材送去墓地，作为融合召唤的素材（原因包含效果、素材、融合）。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使后续的融合召唤处理作为一个新的时点（避免错过特殊召唤成功时点）。
			Duel.BreakEffect()
			-- 将选择的「刻魔」融合怪兽以融合召唤方式特殊召唤到己方场上，表侧表示。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 在连锁素材流程中，让玩家从mg3中选择融合素材，并使用连锁素材效果提供的操作进行融合召唤。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
	me:Reset()
end
