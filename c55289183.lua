--享楽の堕天使
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的主要阶段才能发动。把1只天使族怪兽表侧表示上级召唤。
-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降场上的天使族怪兽数量×500。
function c55289183.initial_effect(c)
	-- ①：自己·对方的主要阶段才能发动。把1只天使族怪兽表侧表示上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(55289183,0))
	e1:SetCategory(CATEGORY_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,55289183)
	e1:SetCondition(c55289183.sumcon)
	e1:SetTarget(c55289183.sumtg)
	e1:SetOperation(c55289183.sumop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。对方场上的全部怪兽的攻击力·守备力直到回合结束时下降场上的天使族怪兽数量×500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(55289183,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,55289184)
	e2:SetTarget(c55289183.atktg)
	e2:SetOperation(c55289183.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件函数：必须在主要阶段
function c55289183.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤函数：筛选手牌中可以进行上级召唤的天使族怪兽
function c55289183.sumfilter(c)
	return c:IsRace(RACE_FAIRY) and c:IsSummonable(true,nil,1)
end
-- 效果①的发动准备（Target）函数：检查手牌中是否存在可上级召唤的天使族怪兽，并设置召唤的操作信息
function c55289183.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手牌中是否存在至少1只满足过滤条件（可上级召唤的天使族）的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55289183.sumfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果包含召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果①的效果处理（Operation）函数：让玩家选择手牌中的1只天使族怪兽进行上级召唤
function c55289183.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 让玩家从手牌中选择1只满足过滤条件（可上级召唤的天使族）的怪兽
	local g=Duel.SelectMatchingCard(tp,c55289183.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行上级召唤（忽略每回合通常召唤次数限制，且至少需要1个祭品）
		Duel.Summon(tp,tc,true,nil,1)
	end
end
-- 过滤函数：筛选场上表侧表示的天使族怪兽
function c55289183.atkfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY)
end
-- 效果②的发动准备（Target）函数：检查场上是否存在表侧表示的天使族怪兽以及对方场上是否存在表侧表示的怪兽
function c55289183.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上（双方怪兽区）是否存在至少1只表侧表示的天使族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c55289183.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且检查对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
end
-- 效果②的效果处理（Operation）函数：计算场上天使族怪兽数量，并使对方场上所有表侧表示怪兽的攻击力·守备力直到回合结束时下降该数量×500
function c55289183.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上表侧表示的天使族怪兽数量
	local ct=Duel.GetMatchingGroupCount(c55289183.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 获取对方场上所有表侧表示的怪兽
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if ct>0 then
		local tc=g:GetFirst()
		while tc do
			local c=e:GetHandler()
			-- 对方场上的全部怪兽的攻击力……直到回合结束时下降场上的天使族怪兽数量×500。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			e1:SetValue(-500*ct)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
			tc=g:GetNext()
		end
	end
end
