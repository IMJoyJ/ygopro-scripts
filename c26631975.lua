--ダイノルフィア・ドメイン
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，把基本分支付一半才能发动。从自己的手卡·卡组·场上把「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
function c26631975.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，把基本分支付一半才能发动。从自己的手卡·卡组·场上把「恐啡肽狂龙」融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,26631975+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c26631975.condition)
	e1:SetCost(c26631975.cost)
	e1:SetTarget(c26631975.target)
	e1:SetOperation(c26631975.operation)
	c:RegisterEffect(e1)
	-- ②：自己基本分是2000以下，对方把魔法·陷阱·怪兽的效果发动时，把墓地的这张卡除外才能发动。这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(c26631975.cdcon)
	-- 设置②效果的发动代价为把墓地的这张卡除外（调用 aux.bfgcost 完成除外自身作为 COST）。
	e2:SetCost(aux.bfgcost)
	e2:SetOperation(c26631975.cdop)
	c:RegisterEffect(e2)
end
-- 定义①效果的发动条件：必须处于主要阶段（自己或对方的主要阶段）才能发动。
function c26631975.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前阶段是否为主要阶段1或主要阶段2，若是则条件成立。
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 定义①效果的发动代价：支付当前基本分的一半。chk==0 时返回 true 表示满足代价条件。
function c26631975.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 实际令玩家 tp 支付当前基本分的一半（向下取整）作为发动代价。
	Duel.PayLPCost(tp,math.floor(Duel.GetLP(tp)/2))
end
-- 定义卡组侧融合素材的过滤条件：必须是怪兽、可以作为融合素材、且能被送去墓地。
function c26631975.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToGrave()
end
-- 定义素材过滤条件：排除对当前效果免疫的卡，保证素材能被效果正常处理。
function c26631975.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 定义融合召唤对象的过滤条件：必须是「恐啡肽狂龙」字段的融合怪兽、能以融合召唤形式特殊召唤、且能用给定素材组满足其融合素材要求；若有追加素材效果还需满足该追加条件。
function c26631975.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x173) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 定义①效果的发动目标：在发动时确认能否从额外卡组选出可用素材融合召唤的「恐啡肽狂龙」融合怪兽，素材来源包含通常融合素材（手卡·场上等）以及卡组中可送墓的怪兽；若存在连锁素材效果也一并检查。
function c26631975.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家 tp 当前可用的融合素材组（通常包括手卡·场上的怪兽及额外融合素材效果提供的卡）。
		local mg1=Duel.GetFusionMaterial(tp)
		-- 获取玩家 tp 卡组中可作为融合素材的怪兽组，条件为 filter0（怪兽、可作融合素材、可送墓）。
		local mg2=Duel.GetMatchingGroup(c26631975.filter0,tp,LOCATION_DECK,0,nil)
		mg1:Merge(mg2)
		-- 检查额外卡组中是否存在满足 filter2 的融合怪兽，该怪兽能使用 mg1 加卡组素材组成的素材组进行融合召唤。
		local res=Duel.IsExistingMatchingCard(c26631975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家 tp 当前适用的连锁素材效果（替代融合素材的特殊效果），用于后续追加素材来源。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg3=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 在普通素材无法融合召唤时，继续检查使用连锁素材效果提供的素材组 mg3 能否融合召唤符合条件的「恐啡肽狂龙」融合怪兽。
				res=Duel.IsExistingMatchingCard(c26631975.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg3,mf,chkf)
			end
		end
		return res
	end
	-- 设置本连锁的操作信息：从额外卡组特殊召唤1只怪兽，供效果发动/处理相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 定义①效果的处理：从手卡·卡组·场上选取融合素材并送去墓地，将选择的1只「恐啡肽狂龙」融合怪兽从额外卡组以融合召唤的方式特殊召唤；若使用连锁素材效果则按该效果处理。
function c26631975.operation(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取可用的融合素材组，并过滤掉对当前效果免疫的卡（filter1）。
	local mg1=Duel.GetFusionMaterial(tp):Filter(c26631975.filter1,nil,e)
	-- 获取卡组中可作为融合素材的怪兽组（同 target 中的 mg2，供处理阶段使用）。
	local mg2=Duel.GetMatchingGroup(c26631975.filter0,tp,LOCATION_DECK,0,nil)
	mg1:Merge(mg2)
	-- 从额外卡组筛选出所有可用 mg1 素材组融合召唤的「恐啡肽狂龙」融合怪兽，作为普通融合候选组 sg1。
	local sg1=Duel.GetMatchingGroup(c26631975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg3=nil
	local sg2=nil
	-- 获取玩家 tp 当前适用的连锁素材效果（同发动时检查）。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg3=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 若存在连锁素材效果，则用其素材组 mg3 筛选出可融合召唤的「恐啡肽狂龙」融合怪兽候选组 sg2。
		sg2=Duel.GetMatchingGroup(c26631975.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg3,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家 tp 显示选择要特殊召唤的卡片的提示信息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断玩家选择的融合怪兽是否使用普通素材组 sg1，且（不在 sg2 中或玩家拒绝使用连锁素材效果）；是则执行普通融合流程，否则执行连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从普通素材组 mg1 中为选中的融合怪兽 tc 选择一组融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材按效果、融合素材、融合召唤的原因送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使后续特殊召唤作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 以融合召唤方式将选中的融合怪兽 tc 表侧攻击表示特殊召唤到玩家 tp 场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 若走连锁素材流程，则让玩家从连锁素材效果提供的素材组 mg3 中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg3,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 定义②效果的发动条件：自己基本分在2000以下，且对方发动了魔法·陷阱·怪兽的效果。
function c26631975.cdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：自己 LP 小于等于2000，且效果发动方 rp 是对方玩家。
	return Duel.GetLP(tp)<=2000 and rp==1-tp
end
-- 定义②效果的处理：给自己适用两个效果，将对方效果对自己造成的效果伤害变为0，并无效效果伤害，持续到回合结束。
function c26631975.cdop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合，对方的效果发生的对自己的效果伤害变成0。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CHANGE_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c26631975.damval1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将 e1（变更伤害数值的效果）注册到玩家 tp 的场上，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_NO_EFFECT_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_END)
	-- 将 e2（无效效果伤害的效果）注册到玩家 tp 的场上，持续到回合结束。
	Duel.RegisterEffect(e2,tp)
end
-- 定义伤害变更回调：若伤害为效果伤害且由对方玩家造成，则将伤害值改为0；否则维持原伤害值。
function c26631975.damval1(e,re,val,r,rp,rc)
	if bit.band(r,REASON_EFFECT)~=0 and rp==1-e:GetOwnerPlayer() then return 0
	else return val end
end
