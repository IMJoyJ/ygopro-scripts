--見えざる手マキブエル
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：把手卡的这张卡给对方观看才能发动。包含手卡的这张卡的自己的手卡·场上的怪兽作为融合素材，把1只「不可见之手」融合怪兽融合召唤。
-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
-- ③：这张卡在墓地存在的状态，幻想魔族融合怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 定义卡片的初始效果注册函数：创建并注册①的起动效果（融合召唤）、②的永续效果（战斗破坏免疫）、③的墓地诱发效果（回手），并分别设定类型、范围、次数限制、代价、目标条件和处理函数。
function s.initial_effect(c)
	-- 这个卡名的①③的效果1回合各能使用1次。①：把手卡的这张卡给对方观看才能发动。包含手卡的这张卡的自己的手卡·场上的怪兽作为融合素材，把1只「不可见之手」融合怪兽融合召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.fspcost)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)
	-- ②：这张卡和怪兽进行战斗的场合，那2只不会被那次战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这个卡名的①③的效果1回合各能使用1次。③：这张卡在墓地存在的状态，幻想魔族融合怪兽被送去自己墓地的场合才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"回到手卡"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.thcon)
	e3:SetTarget(s.thtg)
	e3:SetOperation(s.thop)
	c:RegisterEffect(e3)
end
-- ①的发动代价检查：需要展示手牌的这张卡，这里确认该卡当前处于非公开状态，满足“把手卡的这张卡给对方观看”的发动前提。
function s.fspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic() end
end
-- 过滤函数：排除对当前效果免疫的怪兽，避免选择不能受此效果影响的卡作为融合素材。
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 融合怪兽选择条件：必须为融合怪兽、属于「不可见之手」字段、满足追加条件f、能被融合召唤特殊召唤，且可以以素材组m为素材、包含gc（手牌这张卡）进行融合。
function s.filter2(c,e,tp,m,f,gc,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x1d3) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,gc,chkf)
end
-- ①的发动条件检查：确认额外卡组存在能用通常素材或连锁素材融合召唤的「不可见之手」融合怪兽（素材必须包含手牌这张卡），存在则允许发动，并设置特殊召唤类别的操作信息。
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local chkf=tp
		-- 获取玩家tp可用的融合素材集合（手卡·场上的怪兽，以及额外融合素材效果），并剔除对当前效果免疫的卡。
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检查额外卡组是否存在1只符合条件的「不可见之手」融合怪兽，它可用mg1为素材且必须包含手牌这张卡c进行融合召唤。
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,c,chkf)
		if not res then
			-- 获取连锁素材效果；若玩家tp处于连锁素材适用中则返回该效果，否则返回nil，用于扩展融合素材。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 改用连锁素材提供的素材组mg2（及追加条件mf）再次检查额外卡组是否存在符合条件的「不可见之手」融合怪兽。
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,c,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：本效果处理时将从额外卡组特殊召唤1只怪兽，分类为特殊召唤，供其他卡进行连锁响应检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ①效果处理：确认发动卡仍有效且不免疫；重新取得通常/连锁素材并筛选可融合的「不可见之手」融合怪兽；玩家选择1只；若用通常素材，则选择素材送墓、中断时点后融合召唤；若用连锁素材，则调用连锁素材处理；最后完成融合召唤。
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local chkf=tp
	if not c:IsRelateToChain() or c:IsImmuneToEffect(e) then return end
	-- 处理阶段再次取得通常融合素材组（不含免疫此效果的卡），用于本次实际融合。
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 取得所有能用通常素材mg1融合召唤的符合条件的「不可见之手」融合怪兽集合。
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,c,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取连锁素材效果，若存在则用于支持使用额外素材进行融合。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 取得使用连锁素材组mg2（及额外条件mf）时可融合召唤的所有符合条件的「不可见之手」融合怪兽集合。
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,c,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家从可融合召唤的怪兽中选择1只进行特殊召唤（HINTMSG_SPSUMMON提示）。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 分支判断：若所选怪兽可用通常素材融合，且（无连锁素材或该怪兽不在连锁素材可选集中，或玩家选择不使用连锁素材），则走通常融合流程；否则若存在连锁素材则走连锁素材流程。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材组mg1中选择融合怪兽tc所需的素材，必须包含手牌这张卡c。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,c,chkf)
			tc:SetMaterial(mat1)
			-- 将选择的融合素材以效果+融合素材理由送去墓地。
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果链，使后续融合召唤的处理错开时点，避免漏发时点。
			Duel.BreakEffect()
			-- 将融合怪兽tc以融合召唤方式表侧表示特殊召唤到tp场上。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材组mg2中选择融合怪兽tc所需的素材（必须包含手牌这张卡c）。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,c,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- ②效果的目标筛选：这张卡或这张卡的战斗对象（GetBattleTarget）获得战斗破坏抗性。
function s.indtg(e,c)
	local tc=e:GetHandler()
	return c==tc or c==tc:GetBattleTarget()
end
-- ③触发条件用过滤：目标是幻想魔族融合怪兽且控制者为tp。
function s.cfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_ILLUSION) and c:IsControler(tp)
end
-- ③的发动条件：本次送去墓地的卡中不包含这张卡自身，且至少有1只幻想魔族融合怪兽被送去自己墓地。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return not eg:IsContains(e:GetHandler()) and eg:IsExists(s.cfilter,1,nil,tp)
end
-- ③的发动目标：检查这张卡能否加入手卡，可则设置回手牌操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本次效果处理将这张卡加入持有者手卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ③的效果处理：若这张卡仍与连锁相关且不受王家长眠之谷影响，则将这张卡加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与当前连锁相关，且通过王家长眠之谷的移动限制检查，才能执行回手。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将这张卡返回持有者手卡，原因为效果处理。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
