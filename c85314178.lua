--祈りの女王－コスモクイーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场地魔法卡发动的场合才能发动。这张卡从手卡守备表示特殊召唤。
-- ②：可以以场地区域1张表侧表示卡为对象，那个控制者对应的以下效果发动。
-- ●自己：作为对象的卡破坏，和破坏的卡卡名不同的1张场地魔法卡从卡组加入手卡。
-- ●对方：作为对象的卡的效果直到回合结束时无效，从卡组把1张场地魔法卡加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手卡特召）和②效果（破坏/无效场地区域卡并检索场地魔法）。
function s.initial_effect(c)
	-- ①：场地魔法卡发动的场合才能发动。这张卡从手卡守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：可以以场地区域1张表侧表示卡为对象，那个控制者对应的以下效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DISABLE+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：有场地魔法卡发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_FIELD)
end
-- ①效果的发动准备与合法性检测：检查自身是否能特殊召唤以及怪兽区域是否有空位。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁处理中的操作信息：特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理：将自身以表侧守备表示特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧守备表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
-- 筛选可作为②效果对象的卡片：若是对方的卡，需可被无效且卡组有场地魔法；若是自己的卡，需卡组有不同名场地魔法。
function s.desfilter(c,tp)
	local code=c:GetCode()
	if c:IsControler(1-tp) then code=nil end
	-- 判定目标卡是否符合条件：对方场上的表侧表示卡（需可无效且卡组有场地魔法），或自己场上的卡（需卡组有不同名场地魔法）。
	return c:IsControler(1-tp) and aux.NegateAnyFilter(c) and c:IsFaceup() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,nil) or c:IsControler(tp) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
-- 筛选卡组中可加入手卡的场地魔法卡（若指定code，则需与code不同名）。
function s.thfilter(c,code)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand() and (not code or not c:IsCode(code))
end
-- ②效果的发动准备：选择场地区域1张表侧表示卡作为对象，并根据控制者设置对应的操作信息（破坏或无效，以及检索场地魔法）。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查场地区域是否存在可作为②效果对象的表侧表示卡。
	if chk==0 then return Duel.IsExistingTarget(s.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil,tp) end
	-- 提示玩家选择要作为对象的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择场地区域的1张表侧表示卡作为效果的对象。
	local tc=Duel.SelectTarget(tp,s.desfilter,tp,LOCATION_FZONE,LOCATION_FZONE,1,1,nil,tp):GetFirst()
	if tc:IsControler(tp) then
		-- 若对象是自己的卡，设置操作信息为破坏该卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	else
		-- 若对象是对方的卡，设置操作信息为无效该卡的效果。
		Duel.SetOperationInfo(0,CATEGORY_DISABLE,tc,1,0,0)
	end
	-- 设置操作信息为从卡组将1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：根据对象卡的控制者，执行对应的破坏并检索不同名场地，或者无效其效果并检索场地。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		local code=tc:GetCode()
		if tc:IsControler(tp) then
			-- 尝试破坏作为对象的自己的卡，并判断是否破坏成功。
			if Duel.Destroy(tc,REASON_EFFECT)>0 then
				-- 从卡组选择1张与被破坏的卡卡名不同的场地魔法卡。
				local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,code)
				if g:GetCount()>0 then
					-- 将选择的场地魔法卡加入手卡。
					Duel.SendtoHand(g,nil,REASON_EFFECT)
					-- 向对方玩家展示加入手卡的卡片。
					Duel.ConfirmCards(1-tp,g)
				end
			end
		elseif tc:IsFaceup() and tc:IsCanBeDisabledByEffect(e) then
			-- 无效与该对象卡相关的连锁。
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 作为对象的卡的效果直到回合结束时无效
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
			-- 立即刷新场上卡片的无效状态。
			Duel.AdjustInstantly()
			-- 从卡组选择1张场地魔法卡。
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,nil)
			if g:GetCount()>0 then
				-- 将选择的场地魔法卡加入手卡。
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				-- 向对方玩家展示加入手卡的卡片。
				Duel.ConfirmCards(1-tp,g)
			end
		end
	end
end
