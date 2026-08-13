--白き森の聖徒リゼット
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只「白森林」怪兽或「蓟花」怪兽特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「蓟花」融合怪兽融合召唤。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「罪宝」卡加入手卡。
local s,id,o=GetID()
-- 初始化效果注册：效果原文「这个卡名的①②③的效果1回合各能使用1次。」；创建并注册效果①（手牌展示特召白森林/蓟花）、②（融合召唤蓟花融合怪兽）、③（作为同调素材后检索罪宝），三者各自1回合1次。
function s.initial_effect(c)
	-- ①：把手卡的这张卡给对方观看才能发动。从手卡把1只「白森林」怪兽或「蓟花」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「蓟花」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。从卡组把1张「罪宝」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"检索效果"
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BE_MATERIAL)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
s.fusion_effect=true
-- 效果①的发动代价：这张卡必须处于手卡且非公开状态，才能通过发动将其公开给对方观看。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 筛选手卡中可作为效果①特殊召唤对象的怪兽：持有「白森林」或「蓟花」字段，且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1b1,0x1bc) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动目标判定：确认自己主要怪兽区有空位，且手卡存在满足条件的「白森林/蓟花」怪兽，满足条件才可发动。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的主要怪兽区域（用于特殊召唤）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手卡中是否存在至少1只符合条件的「白森林」或「蓟花」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 登记操作信息：本次效果将进行1只怪兽的特殊召唤，来源为手牌。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果①的实际处理：主要怪兽区有空位时，从手卡选择1只符合条件的「白森林/蓟花」怪兽，以表侧表示特殊召唤到自己的怪兽区。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认主要怪兽区域仍有空位，防止发动后场地被占满导致无法特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 显示选择提示，要求玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 玩家从手卡中选出1只满足s.spfilter条件的怪兽（「白森林」或「蓟花」，且可被特殊召唤）。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧攻击表示特殊召唤到自己的场上（不限制召唤方式，通常为效果特殊召唤）。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
-- 融合素材过滤器：排除对该融合效果免疫的怪兽，确保素材能正常被融合效果使用。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽候选过滤器：必须是「蓟花」融合怪兽、可以以融合召唤方式特殊召唤，且能用给定的素材组m构成融合素材。
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1bc) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 效果②发动目标判定：检查额外卡组是否存在可融合召唤的「蓟花」融合怪兽；先检查通常融合素材，若无则检查是否有连锁素材（追加融合素材效果）可用。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取玩家当前可用的通常融合素材（手卡·场上的怪兽及额外融合素材效果提供的卡），并去除对效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组中是否存在能使用上述素材组融合召唤的「蓟花」融合怪兽。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取当前玩家适用的连锁素材效果（如「融合」相关的替代素材/追加素材效果）。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 若通常素材无法融合，则使用连锁素材效果提供的素材组再次检查额外卡组是否存在可融合的「蓟花」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 登记操作信息：本次效果将进行融合召唤，从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 效果②的实际处理：从可融合的「蓟花」融合怪兽中选择1只，选择融合素材并将素材送去墓地，以融合召唤方式特殊召唤；若使用连锁素材则调用对应效果完成融合。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 处理时获取当前玩家可用的通常融合素材，并排除对效果免疫的卡。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 从额外卡组中筛选出所有能使用通常素材组融合召唤的「蓟花」融合怪兽，作为可选目标。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果（如果有），用于处理使用额外素材的融合召唤。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 如果有连锁素材，获取其提供的素材组，并筛选出能用该素材组融合召唤的「蓟花」融合怪兽。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		::cancel::
		-- 显示选择提示，要求玩家选择要融合召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断所选融合怪兽是否优先使用通常素材：若它属于通常素材组，且（不属于连锁素材组，或玩家选择不使用连锁素材），则按通常融合处理；否则进入连锁素材分支。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材组中选择该融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat1==0 then goto cancel end
			tc:SetMaterial(mat1)
			-- 将所选融合素材送去墓地，理由为效果+作为融合素材+融合召唤。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使融合素材送墓和融合怪兽特殊召唤不在同一时点处理，避免错失时点。
			Duel.BreakEffect()
			-- 以融合召唤（SUMMON_TYPE_FUSION）方式将选择的「蓟花」融合怪兽特殊召唤到自己的场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce~=nil then
			-- 从连锁素材效果提供的素材组中选择融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat2==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 效果③的触发条件：该卡作为同调素材被送去墓地后位于墓地，且此次作为素材的原因是同调召唤（REASON_SYNCHRO）。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 检索过滤器：从卡组中寻找持有「罪宝」字段且能够加入手卡的卡。
function s.thfilter(c)
	return c:IsSetCard(0x19e) and c:IsAbleToHand()
end
-- 效果③的目标判定：确认卡组中存在符合条件的「罪宝」卡，并登记操作信息为从卡组加入手牌。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张符合条件的「罪宝」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果将执行从卡组将1张卡加入手牌（CATEGORY_TOHAND）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的实际处理：从卡组选择1张「罪宝」卡加入手牌，并向对方确认加入手牌的卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，要求玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选出1张满足s.thfilter条件的「罪宝」卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的「罪宝」卡加入其持有者的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示此次加入手牌的卡，以确认检索行为。
		Duel.ConfirmCards(1-tp,g)
	end
end
