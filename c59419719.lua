--化石融合－フォッシル・フュージョン
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：从自己·对方的墓地把「化石」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个效果从双方墓地把怪兽除外的场合，那只特殊召唤的怪兽不会成为怪兽的效果的对象。
-- ②：这张卡在墓地存在，自己场上的表侧表示的「化石」融合怪兽被战斗·效果破坏的场合才能发动。墓地的这张卡加入手卡。
function c59419719.initial_effect(c)
	-- ①：从自己·对方的墓地把「化石」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个效果从双方墓地把怪兽除外的场合，那只特殊召唤的怪兽不会成为怪兽的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59419719,0))  --"融合召唤"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c59419719.target)
	e1:SetOperation(c59419719.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的表侧表示的「化石」融合怪兽被战斗·效果破坏的场合才能发动。墓地的这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59419719,1))  --"墓地回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_CUSTOM+59419719)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,59419719)
	e2:SetCondition(c59419719.thcon)
	e2:SetTarget(c59419719.thtg)
	e2:SetOperation(c59419719.thop)
	c:RegisterEffect(e2)
	if not c59419719.global_check then
		c59419719.global_check=true
		-- ①：从自己·对方的墓地把「化石」融合怪兽卡决定的融合素材怪兽除外，把那1只融合怪兽从额外卡组融合召唤。这个效果从双方墓地把怪兽除外的场合，那只特殊召唤的怪兽不会成为怪兽的效果的对象。②：这张卡在墓地存在，自己场上的表侧表示的「化石」融合怪兽被战斗·效果破坏的场合才能发动。墓地的这张卡加入手卡。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_DESTROYED)
		ge1:SetCondition(c59419719.regcon)
		ge1:SetOperation(c59419719.regop)
		-- 注册全局环境效果，用于检测场上的「化石」融合怪兽是否被破坏。
		Duel.RegisterEffect(ge1,0)
	end
end
-- 过滤函数：过滤在自己场上表侧表示存在、因战斗或效果被破坏的「化石」融合怪兽。
function c59419719.cfilter(c,tp)
	return c:IsPreviousSetCard(0x149) and c:GetPreviousTypeOnField()&TYPE_FUSION~=0
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:IsPreviousControler(tp) and c:IsPreviousLocation(LOCATION_MZONE)
end
-- 破坏事件注册效果的发动条件：检查是否有满足条件的怪兽被破坏，并记录被破坏怪兽的控制者。
function c59419719.regcon(e,tp,eg,ep,ev,re,r,rp)
	local v=0
	if eg:IsExists(c59419719.cfilter,1,nil,0) then v=v+1 end
	if eg:IsExists(c59419719.cfilter,1,nil,1) then v=v+2 end
	if v==0 then return false end
	e:SetLabel(({0,1,PLAYER_ALL})[v])
	return true
end
-- 破坏事件注册效果的操作：触发自定义事件，向玩家发送破坏信息。
function c59419719.regop(e,tp,eg,ep,ev,re,r,rp)
	-- 触发自定义事件，传递被破坏的卡片组以及控制者标签。
	Duel.RaiseEvent(eg,EVENT_CUSTOM+59419719,re,r,rp,ep,e:GetLabel())
end
-- 过滤函数：过滤墓地中可以作为融合素材且可以除外的怪兽。
function c59419719.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
-- 过滤函数：过滤额外卡组中可以进行融合召唤的「化石」融合怪兽。
function c59419719.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x149) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
-- 融合召唤效果的发动准备：检查是否存在可融合召唤的怪兽，并设置特殊召唤与除外的操作信息。
function c59419719.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		-- 获取双方墓地中可作为融合素材除外的怪兽组。
		local mg1=Duel.GetMatchingGroup(c59419719.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
		-- 检查额外卡组是否存在可以使用双方墓地素材进行融合召唤的「化石」融合怪兽。
		local res=Duel.IsExistingMatchingCard(c59419719.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			-- 获取玩家受到的连锁素材效果。
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				-- 检查在连锁素材效果适用下，是否存在可融合召唤的「化石」融合怪兽。
				res=Duel.IsExistingMatchingCard(c59419719.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		return res
	end
	-- 设置操作信息：从额外卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：从墓地除外卡片。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_GRAVE)
end
-- 融合召唤效果的处理：选择并融合召唤1只「化石」融合怪兽，若从双方墓地除外素材则赋予抗性。
function c59419719.activate(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	-- 获取双方墓地中可作为融合素材除外的怪兽组。
	local mg1=Duel.GetMatchingGroup(c59419719.filter1,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil)
	-- 获取额外卡组中可以使用双方墓地素材进行融合召唤的「化石」融合怪兽组。
	local sg1=Duel.GetMatchingGroup(c59419719.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	-- 获取玩家受到的连锁素材效果。
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		-- 获取在连锁素材效果适用下，可以融合召唤的「化石」融合怪兽组。
		sg2=Duel.GetMatchingGroup(c59419719.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tg=sg:Select(tp,1,1,nil)
		local tc=tg:GetFirst()
		-- 判断是否使用本卡自身的效果进行融合召唤（而非连锁素材等其他效果）。
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
			-- 让玩家从双方墓地中选择所选融合怪兽所需的融合素材。
			local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			local res=mat1:IsExists(Card.IsControler,1,nil,tp) and mat1:IsExists(Card.IsControler,1,nil,1-tp)
			tc:SetMaterial(mat1)
			-- 将选定的融合素材怪兽表侧表示除外。
			Duel.Remove(mat1,POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			-- 中断当前效果，使后续的特殊召唤处理与除外处理不视为同时进行。
			Duel.BreakEffect()
			-- 将该融合怪兽在自己场上表侧表示融合召唤。
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			if res then
				-- 这个效果从双方墓地把怪兽除外的场合，那只特殊召唤的怪兽不会成为怪兽的效果的对象。②：这张卡在墓地存在，自己场上的表侧表示的「化石」融合怪兽被战斗·效果破坏的场合才能发动。墓地的这张卡加入手卡。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(59419719,2))  --"「化石融合」效果适用中"
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
				e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetValue(c59419719.efilter)
				tc:RegisterEffect(e1,true)
			end
		else
			-- 在连锁素材等效果适用时，让玩家选择对应的融合素材。
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
-- 过滤函数：用于使怪兽不受怪兽效果影响（不成为怪兽效果的对象）。
function c59419719.efilter(e,re,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 墓地回收效果的发动条件：检查被破坏的「化石」融合怪兽是否属于自己。
function c59419719.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ev==tp or ev==PLAYER_ALL
end
-- 墓地回收效果的发动准备：检查墓地的这张卡是否可以加入手卡，并设置回收的操作信息。
function c59419719.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置操作信息：将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 墓地回收效果的处理：将墓地的这张卡加入手卡。
function c59419719.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡加入持有者的手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
