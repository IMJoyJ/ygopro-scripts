--EM天空の魔術師
-- 效果：
-- ←8 【灵摆】 8→
-- 这个卡名的灵摆效果1回合只能使用1次。
-- ①：只让从额外卡组特殊召唤的自己场上的表侧表示的融合·同调·超量怪兽1只被战斗或者对方的效果破坏时才能发动。那只怪兽在自己场上特殊召唤。那之后，这张卡破坏。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动。这张卡以外的自己场上的怪兽种类在这个回合让以下效果各适用。
-- ●融合：这张卡可以直接攻击。
-- ●同调：对方不能把怪兽的效果发动。
-- ●超量：这张卡的攻击力变成原本攻击力的2倍。
-- ●灵摆：结束阶段，从卡组把1只灵摆怪兽加入手卡。
function c58092907.initial_effect(c)
	-- 注册灵摆怪兽的灵摆属性（灵摆召唤、灵摆卡的发动等）
	aux.EnablePendulumAttribute(c)
	-- ①：只让从额外卡组特殊召唤的自己场上的表侧表示的融合·同调·超量怪兽1只被战斗或者对方的效果破坏时才能发动。那只怪兽在自己场上特殊召唤。那之后，这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(58092907,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1,58092907)
	e1:SetCondition(c58092907.spcon)
	e1:SetTarget(c58092907.sptg)
	e1:SetOperation(c58092907.spop)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动。这张卡以外的自己场上的怪兽种类在这个回合让以下效果各适用。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(58092907,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,58092908)
	e2:SetCondition(c58092907.mecon)
	e2:SetTarget(c58092907.metg)
	e2:SetOperation(c58092907.meop)
	c:RegisterEffect(e2)
	if not c58092907.global_check then
		c58092907.global_check=true
		-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡召唤·特殊召唤的回合的自己主要阶段才能发动。
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		ge1:SetLabel(58092907)
		-- 设置全局效果的操作为注册召唤/特殊召唤的回合标记
		ge1:SetOperation(aux.sumreg)
		-- 在全局环境注册该召唤检测效果
		Duel.RegisterEffect(ge1,0)
		local ge2=ge1:Clone()
		ge2:SetCode(EVENT_SPSUMMON_SUCCESS)
		ge2:SetLabel(58092907)
		-- 在全局环境注册该特殊召唤检测效果
		Duel.RegisterEffect(ge2,0)
	end
end
-- 过滤满足“从额外卡组特殊召唤的自己场上的表侧表示的融合·同调·超量怪兽被战斗或对方效果破坏”条件的卡片
function c58092907.spfilter(c,tp,rp)
	return (c:IsReason(REASON_BATTLE) or (c:IsReason(REASON_EFFECT) and rp==1-tp)) and c:IsPreviousLocation(LOCATION_MZONE)
		and c:IsPreviousControler(tp) and c:IsSummonLocation(LOCATION_EXTRA)
		and bit.band(c:GetPreviousTypeOnField(),TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)~=0 and c:IsPreviousPosition(POS_FACEUP)
end
-- 检查是否“只让”1只满足条件的怪兽被破坏
function c58092907.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:GetCount()==1 and eg:IsExists(c58092907.spfilter,1,nil,tp,rp)
end
-- 过滤可以特殊召唤到自己场上的目标怪兽，并排除不合法的状态或控制权
function c58092907.spfilter2(c,e,tp)
	if c:IsLocation(LOCATION_HAND+LOCATION_DECK) or (not c:IsLocation(LOCATION_GRAVE) and c:IsFacedown())
		or not c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsControler(1-tp) then return false end
	if c:IsLocation(LOCATION_EXTRA) then
		-- 检查从额外卡组特殊召唤该怪兽所需的额外怪兽区域或连接端空格是否足够
		return Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
	else
		-- 检查自己场上是否有可用的常规怪兽区域
		return Duel.GetMZoneCount(tp)>0
	end
end
-- 灵摆效果的发动准备，将破坏的怪兽设为效果处理对象，并注册特殊召唤分类的操作信息
function c58092907.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ec=eg:GetFirst()
	if chk==0 then return c58092907.spfilter2(ec,e,tp) end
	-- 将被破坏的怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(ec)
	-- 设置当前连锁的操作信息为特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,ec,1,0,0)
end
-- 灵摆效果的处理：特殊召唤目标怪兽，之后破坏这张卡
function c58092907.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁设定的目标怪兽
	local ec=Duel.GetFirstTarget()
	-- 若目标怪兽仍与效果有关联，则将其在自己场上表侧表示特殊召唤
	if ec:IsRelateToEffect(e) and Duel.SpecialSummon(ec,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理，使后续的破坏处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 破坏作为灵摆卡发动的这张卡
		Duel.Destroy(c,REASON_EFFECT)
	end
end
-- 过滤自己场上表侧表示的融合、同调或超量怪兽
function c58092907.mefilter1(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_SYNCHRO+TYPE_XYZ)
end
-- 过滤自己场上表侧表示的灵摆怪兽
function c58092907.mefilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_PENDULUM)
end
-- 过滤卡组中可以加入手牌的灵摆怪兽
function c58092907.thfilter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 检查这张卡是否在当前回合被召唤或特殊召唤
function c58092907.mecon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(58092907)>0
end
-- 怪兽效果的发动准备，检查场上是否存在其他种类的怪兽以满足适用效果的条件，并注册检索分类的操作信息
function c58092907.metg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在这张卡以外的表侧表示的融合、同调或超量怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c58092907.mefilter1,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 或者自己场上是否存在这张卡以外的表侧表示的灵摆怪兽
		or (Duel.IsExistingMatchingCard(c58092907.mefilter2,tp,LOCATION_MZONE,0,1,e:GetHandler())
		-- 并且卡组中存在至少1只灵摆怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_PENDULUM)) end
	-- 设置当前连锁的操作信息为从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 过滤场上表侧表示且属于指定怪兽种类的卡片
function c58092907.cfilter(c,type)
	return c:IsFaceup() and c:IsType(type)
end
-- 怪兽效果的处理：根据场上存在的其他怪兽种类，分别适用对应的效果
function c58092907.meop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上除这张卡以外的所有表侧表示的融合、同调、超量怪兽
	local g=Duel.GetMatchingGroup(c58092907.mefilter1,tp,LOCATION_MZONE,0,aux.ExceptThisCard(e))
	local b1=c:IsRelateToEffect(e) and g:IsExists(c58092907.cfilter,1,nil,TYPE_FUSION)
	local b2=g:IsExists(c58092907.cfilter,1,nil,TYPE_SYNCHRO)
	local b3=c:IsRelateToEffect(e) and c:IsFaceup() and g:IsExists(c58092907.cfilter,1,nil,TYPE_XYZ)
	-- 检查自己场上是否存在除这张卡以外的表侧表示的灵摆怪兽
	local b4=Duel.IsExistingMatchingCard(c58092907.mefilter2,tp,LOCATION_MZONE,0,1,aux.ExceptThisCard(e))
		-- 并且卡组中存在可以检索的灵摆怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_DECK,0,1,nil,TYPE_PENDULUM)
	if b1 then
		-- ●融合：这张卡可以直接攻击。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
	if b2 then
		-- ●同调：对方不能把怪兽的效果发动。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_CANNOT_ACTIVATE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(0,1)
		e2:SetValue(c58092907.actlimit)
		e2:SetReset(RESET_PHASE+PHASE_END)
		-- 注册限制对方玩家发动怪兽效果的全局效果
		Duel.RegisterEffect(e2,tp)
	end
	if b3 then
		-- ●超量：这张卡的攻击力变成原本攻击力的2倍。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_SET_ATTACK_FINAL)
		e3:SetValue(c:GetBaseAttack()*2)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
	if b4 then
		-- ●灵摆：结束阶段，从卡组把1只灵摆怪兽加入手卡。
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e4:SetCode(EVENT_PHASE+PHASE_END)
		e4:SetCountLimit(1)
		e4:SetCondition(c58092907.thcon)
		e4:SetOperation(c58092907.thop)
		e4:SetReset(RESET_PHASE+PHASE_END)
		-- 注册在结束阶段触发检索效果的延迟处理效果
		Duel.RegisterEffect(e4,tp)
	end
end
-- 限制对方发动的效果类型为怪兽效果
function c58092907.actlimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- 结束阶段检索效果的发动条件：卡组中存在可检索的灵摆怪兽
function c58092907.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查卡组中是否存在可以加入手牌的灵摆怪兽
	return Duel.IsExistingMatchingCard(c58092907.thfilter,tp,LOCATION_DECK,0,1,nil)
end
-- 结束阶段检索效果的处理：从卡组选择1只灵摆怪兽加入手牌
function c58092907.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示发动该效果的卡片为“娱乐伙伴 天空之魔术师”
	Duel.Hint(HINT_CARD,0,58092907)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1只灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c58092907.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
