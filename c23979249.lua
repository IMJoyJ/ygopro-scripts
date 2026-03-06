--武神－アラスダ
-- 效果：
-- 自己的场上·墓地的名字带有「武神」的怪兽从游戏中除外的场合，这张卡可以从手卡表侧守备表示特殊召唤。此外，这张卡在场上表侧表示存在，名字带有「武神」的卡用抽卡以外的方法从自己卡组加入手卡的场合，那个回合的结束阶段时才能发动1次。从卡组抽1张卡，那之后选1张手卡丢弃。「武神-荒樔田」在自己场上只能有1只表侧表示存在。
function c23979249.initial_effect(c)
	c:SetUniqueOnField(1,0,23979249)
	-- 效果原文：自己的场上·墓地的名字带有「武神」的怪兽从游戏中除外的场合，这张卡可以从手卡表侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23979249,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_REMOVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c23979249.spcon)
	e1:SetTarget(c23979249.sptg)
	e1:SetOperation(c23979249.spop)
	c:RegisterEffect(e1)
	-- 效果原文：此外，这张卡在场上表侧表示存在，名字带有「武神」的卡用抽卡以外的方法从自己卡组加入手卡的场合，那个回合的结束阶段时才能发动1次。从卡组抽1张卡，那之后选1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c23979249.regcon)
	e2:SetOperation(c23979249.regop)
	c:RegisterEffect(e2)
	-- 效果原文：「武神-荒樔田」在自己场上只能有1只表侧表示存在。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(23979249,1))  --"抽卡"
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c23979249.drcon)
	e3:SetTarget(c23979249.drtg)
	e3:SetOperation(c23979249.drop)
	c:RegisterEffect(e3)
end
-- 规则层面：判断除外的怪兽是否为「武神」卡且来自自己场上或墓地
function c23979249.cfilter(c,tp)
	return c:IsSetCard(0x88) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_MZONE+LOCATION_GRAVE)
end
-- 规则层面：判断是否有满足条件的除外怪兽
function c23979249.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23979249.cfilter,1,nil,tp)
end
-- 规则层面：判断是否可以将此卡特殊召唤
function c23979249.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 规则层面：设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 规则层面：执行特殊召唤操作
function c23979249.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 规则层面：将此卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 规则层面：判断加入手卡的卡是否为「武神」卡且来自自己卡组且不是因抽卡效果
function c23979249.regfilter(c,tp)
	return c:IsSetCard(0x88) and c:IsControler(tp) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_DECK) and not c:IsReason(REASON_DRAW)
end
-- 规则层面：判断是否有满足条件的加入手卡的卡
function c23979249.regcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c23979249.regfilter,1,nil,tp)
end
-- 规则层面：为自身注册一个标记，表示可以发动抽卡效果
function c23979249.regop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(23979249,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- 规则层面：判断是否拥有标记以发动抽卡效果
function c23979249.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(23979249)>0
end
-- 规则层面：设置抽卡和丢弃手卡的操作信息
function c23979249.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 规则层面：判断玩家是否可以抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 规则层面：设置连锁的目标玩家
	Duel.SetTargetPlayer(tp)
	-- 规则层面：设置连锁的目标参数
	Duel.SetTargetParam(1)
	-- 规则层面：设置抽卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	-- 规则层面：设置丢弃手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 规则层面：执行抽卡和丢弃手卡操作
function c23979249.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 规则层面：执行抽卡操作
	if Duel.Draw(p,d,REASON_EFFECT)~=0 then
		-- 规则层面：洗切玩家手牌
		Duel.ShuffleHand(tp)
		-- 规则层面：中断当前效果处理
		Duel.BreakEffect()
		-- 规则层面：丢弃玩家一张手牌
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
	end
end
