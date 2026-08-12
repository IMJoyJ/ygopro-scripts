--捕食惑星
-- 效果：
-- 「捕食惑星」的①的效果1回合只能使用1次。
-- ①：这张卡在魔法与陷阱区域存在，有捕食指示物放置的怪兽从场上离开的场合发动。从卡组把1张「捕食」卡加入手卡。
-- ②：把墓地的这张卡除外才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，不是「捕食植物」怪兽不能作为融合素材。
function c51858200.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：这张卡在魔法与陷阱区域存在，有捕食指示物放置的怪兽从场上离开的场合发动。（离场前的触发检测用永续效果）
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_LEAVE_FIELD_P)
	e0:SetRange(LOCATION_SZONE)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetOperation(c51858200.regop)
	c:RegisterEffect(e0)
	-- ①：这张卡在魔法与陷阱区域存在，有捕食指示物放置的怪兽从场上离开的场合发动。从卡组把1张「捕食」卡加入手卡。（「捕食惑星」的①的效果1回合只能使用1次）
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(51858200,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,51858200)
	e2:SetCondition(c51858200.thcon)
	e2:SetTarget(c51858200.thtg)
	e2:SetOperation(c51858200.thop)
	e2:SetLabelObject(e0)
	c:RegisterEffect(e2)
	-- ②：把墓地的这张卡除外才能发动。从自己的手卡·场上把融合怪兽卡决定的融合素材怪兽送去墓地，把那1只融合怪兽从额外卡组融合召唤。这个效果融合召唤的场合，不是「捕食植物」怪兽不能作为融合素材。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51858200,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_GRAVE)
	-- 以把墓地的这张卡除外作为发动代价
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c51858200.sptg)
	e3:SetOperation(c51858200.spop)
	c:RegisterEffect(e3)
end
c51858200.mentioned_counter={
	[0x1041]=true,
}
-- 过滤离场卡片中位于怪兽区域且放置有捕食指示物（0x1041）的怪兽
function c51858200.cfilter(c)
	return c:IsLocation(LOCATION_MZONE) and c:GetCounter(0x1041)>0
end
-- 离场前的卡片组中存在放置有捕食指示物的怪兽时设置标记1，否则设置标记0
function c51858200.regop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(c51858200.cfilter,1,nil) then
		e:SetLabel(1)
	else e:SetLabel(0) end
end
-- 发动条件：离场前检测到的标记为1（即有放置捕食指示物的怪兽从场上离开）
function c51858200.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetLabelObject():GetLabel()==1
end
-- 过滤卡组中属于「捕食」系列（0xf3）且可以加入手卡的卡
function c51858200.thfilter(c)
	return c:IsSetCard(0xf3) and c:IsAbleToHand()
end
-- 效果发动的对象设定：设置从卡组把1张卡加入手卡的操作信息
function c51858200.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理①效果：从卡组选择1张「捕食」卡加入手卡，并给对方确认
function c51858200.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家请选择要加入手卡的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张属于「捕食」系列且可以加入手卡的卡
	local g=Duel.SelectMatchingCard(tp,c51858200.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 把选择的卡以效果原因送去持有者的手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤属于「捕食植物」系列（0x10f3）且不受这个效果影响的卡（通常融合素材）
function c51858200.spfilter1(c,e)
	return c:IsSetCard(0x10f3) and not c:IsImmuneToEffect(e)
end
-- 过滤额外卡组中可以作为融合怪兽、可以用指定素材融合召唤并能被特殊召唤的融合怪兽
function c51858200.spfilter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 过滤可以作为融合素材且属于「捕食植物」系列（0x10f3）的怪兽（连锁素材用）
function c51858200.spfilter3(c)
	return c:IsCanBeFusionMaterial() and c:IsSetCard(0x10f3)
end
-- 发动的检测：确认额外卡组存在能以自己手卡·场上的「捕食植物」怪兽为素材融合召唤的融合怪兽（含连锁素材的场合），并设置特殊召唤的操作信息
function c51858200.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己可用的融合素材中属于「捕食植物」系列的怪兽
		local mg1=Duel.GetFusionMaterial(tp):Filter(Card.IsSetCard,nil,0x10f3)
		-- 检查额外卡组是否存在能以这些「捕食植物」怪兽为素材特殊召唤的融合怪兽
		local res=Duel.IsExistingMatchingCard(c51858200.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得玩家受到的连锁素材的效果（用于融合类卡）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp):Filter(c51858200.spfilter3,nil)
				local mf=ce:GetValue()
				-- 用连锁素材提供的融合素材检查额外卡组是否存在可以特殊召唤的融合怪兽
				res=Duel.IsExistingMatchingCard(c51858200.spfilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：预计从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 处理②效果：选择要以「捕食植物」怪兽为素材融合召唤的融合怪兽，将其融合素材从自己的手卡·场上送去墓地，把那1只融合怪兽从额外卡组融合召唤
function c51858200.spop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己可用的融合素材中不受效果影响的「捕食植物」怪兽
	local mg1=Duel.GetFusionMaterial(tp):Filter(c51858200.spfilter1,nil,e)
	-- 取得额外卡组中能以这些素材融合召唤并可特殊召唤的全部融合怪兽
	local sg1=Duel.GetMatchingGroup(c51858200.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得玩家受到的连锁素材的效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp):Filter(c51858200.spfilter3,nil)
		local mf=ce:GetValue()
		-- 取得额外卡组中能以连锁素材提供的素材融合召唤的全部融合怪兽
		sg2=Duel.GetMatchingGroup(c51858200.spfilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家请选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断选中的怪兽是否用通常素材融合召唤：若同时属于连锁素材候选，则询问玩家是否使用连锁素材的效果
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从手卡·场上的「捕食植物」怪兽中选择那1只融合怪兽决定的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 把选择的融合素材怪兽以效果·融合素材原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断效果处理，使之后的融合召唤与送墓视为不同时处理
			Duel.BreakEffect()
			-- 把那1只融合怪兽从额外卡组以表侧表示融合召唤
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			-- 让玩家从连锁素材提供的素材中选择那1只融合怪兽决定的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
