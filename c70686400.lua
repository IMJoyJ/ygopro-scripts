--ウィッチクラフト・テラコッタン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，以「魔女术赤陶偶」以外的自己墓地1张「魔女术」卡为对象才能发动。那张卡加入手卡，这张卡特殊召唤。这个回合，自己不是「魔女术」怪兽不能从额外卡组特殊召唤。
-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「魔女术」融合怪兽融合召唤。
local s,id,o=GetID()
-- 初始化卡片效果：注册①效果（手卡发动的起动效果，取墓地「魔女术」卡为对象，回收并特殊召唤自身，1回合1次）和②效果（场上发动的起动效果，进行「魔女术」融合怪兽的融合召唤，1回合1次）
function s.initial_effect(c)
	-- ①：这张卡在手卡存在的场合，以「魔女术赤陶偶」以外的自己墓地1张「魔女术」卡为对象才能发动。那张卡加入手卡，这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。自己的手卡·场上的怪兽作为融合素材，把1只「魔女术」融合怪兽融合召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"融合召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.fsptg)
	e2:SetOperation(s.fspop)
	c:RegisterEffect(e2)
end
-- 过滤函数：筛选「魔女术赤陶偶」以外的、可以加入手卡的自己墓地「魔女术」卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x128) and c:IsAbleToHand()
end
-- ①效果的对象与发动条件检测：对象须为自己墓地满足条件的卡；可发动条件为墓地存在可取为对象的「魔女术」卡、自己主要怪兽区有空位且这张卡可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 检测自己墓地是否存在可取为对象的、满足条件的「魔女术」卡
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 检测自己主要怪兽区是否有可特殊召唤的空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己墓地选择1张满足条件的「魔女术」卡作为效果对象
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：确定要将作为对象的卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
	-- 设置操作信息：确定要将这张卡（自身）特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：取回效果对象，若对象仍与连锁相关、不受王家长眠之谷影响，则将其加入手卡，成功加入手卡且自身仍与连锁相关的场合，把这张卡从手卡特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的第一个对象卡
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡存在、仍与当前连锁相关且不受王家长眠之谷的影响
	if tc and tc:IsRelateToChain() and aux.NecroValleyFilter()(tc)
		-- 将对象卡以效果原因加入手卡，并确认其已实际回到手卡
		and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND)
		and c:IsRelateToChain() then
		-- 把这张卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
	-- 这个回合，自己不是「魔女术」怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把这个特殊召唤限制效果注册为当前玩家的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 特殊召唤限制的具体内容：不是「魔女术」怪兽的额外卡组怪兽不能特殊召唤
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsSetCard(0x128) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤函数：筛选不受此效果影响的卡（用于确定可作为融合素材的怪兽）
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
-- 过滤函数：筛选额外卡组中可以用给定素材融合召唤的「魔女术」融合怪兽（需满足附加条件、可以融合特殊召唤且素材齐备）
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x128) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- ②效果的发动条件检测与操作信息设置：取得可用的融合素材，检测额外卡组是否存在可融合召唤的「魔女术」融合怪兽（不存在时再考虑连锁素材效果）；可发动时向对方提示所选效果并设置特殊召唤的操作信息
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 取得自己手卡·场上可用且不受此效果影响的融合素材
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		-- 检测额外卡组是否存在能用这些素材融合召唤的「魔女术」融合怪兽
		local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 取得自己受到的连锁素材效果（如「连锁素材」）
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 用连锁素材效果提供的素材和条件，再次检测额外卡组是否存在可融合召唤的「魔女术」融合怪兽
				res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 向对方玩家提示自己选择了发动哪个效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：预计从额外卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- ②效果的处理：收集可用融合素材与额外卡组中可融合召唤的「魔女术」融合怪兽（含连锁素材的场合），让玩家选择1只融合怪兽，再选择融合素材送去墓地，将其以融合召唤方式特殊召唤；使用连锁素材的场合改由该效果的处理完成召唤，最后完成召唤手续
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 取得自己手卡·场上可用且不受此效果影响的融合素材
	local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
	-- 取得额外卡组中能用这些素材融合召唤的全部「魔女术」融合怪兽
	local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 取得自己受到的连锁素材效果
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 用连锁素材效果提供的素材，取得额外卡组中可融合召唤的「魔女术」融合怪兽
		sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 向玩家提示「请选择要特殊召唤的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断使用通常素材进行融合召唤：所选怪兽在通常素材可召唤的列表中，且（不属于连锁素材列表、或玩家选择不使用连锁素材效果）
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从通常素材中选择该融合怪兽的融合素材
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			tc:SetMaterial(mat1)
			-- 把选择的融合素材作为融合素材以效果原因送去墓地
			Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果处理，使送去墓地与特殊召唤视为不同时处理（防止错时点问题）
			Duel.BreakEffect()
			-- 把该融合怪兽以融合召唤方式表侧表示特殊召唤到自己场上
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		elseif ce then
			-- 让玩家从连锁素材效果提供的素材中选择该融合怪兽的融合素材
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
