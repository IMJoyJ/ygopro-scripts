--太陽の魔術師エダ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·反转的场合才能发动。从手卡·卡组把「太阳之魔术师 埃达」以外的1只守备力1500的魔法师族怪兽里侧守备表示特殊召唤。
-- ②：对方主要阶段才能发动。选自己场上1只里侧表示的魔法师族怪兽变成表侧攻击表示或者表侧守备表示。
function c96352326.initial_effect(c)
	-- ①：这张卡召唤·反转的场合才能发动。从手卡·卡组把「太阳之魔术师 埃达」以外的1只守备力1500的魔法师族怪兽里侧守备表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96352326,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,96352326)
	e1:SetTarget(c96352326.sptg)
	e1:SetOperation(c96352326.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP)
	c:RegisterEffect(e2)
	-- ②：对方主要阶段才能发动。选自己场上1只里侧表示的魔法师族怪兽变成表侧攻击表示或者表侧守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(96352326,1))  --"改变表示形式"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,96352327)
	e3:SetCondition(c96352326.poscon)
	e3:SetTarget(c96352326.postg)
	e3:SetOperation(c96352326.posop)
	c:RegisterEffect(e3)
end
-- 过滤「太阳之魔术师 埃达」以外的、守备力1500的魔法师族怪兽，且能被里侧守备表示特殊召唤的卡片
function c96352326.spfilter(c,e,tp)
	return c:IsRace(RACE_SPELLCASTER) and c:IsDefense(1500) and not c:IsCode(96352326)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果①（特殊召唤）的发动准备与可行性检查函数
function c96352326.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 在发动准备阶段，检查手卡或卡组是否存在至少1只满足条件的怪兽
		and Duel.IsExistingMatchingCard(c96352326.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁处理的操作信息，表示该效果包含从手卡或卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果①（特殊召唤）的效果处理函数
function c96352326.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，如果自己场上没有可用的怪兽区域空位，则不处理效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家发送提示信息，要求选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡或卡组选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c96352326.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的怪兽以里侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认被里侧特殊召唤的怪兽
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 效果②（改变表示形式）的发动条件检查函数
function c96352326.poscon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的游戏阶段
	local ph=Duel.GetCurrentPhase()
	-- 检查当前是否为对方回合的主要阶段1或主要阶段2
	return Duel.GetTurnPlayer()~=tp and (ph==PHASE_MAIN1 or ph==PHASE_MAIN2)
end
-- 过滤自己场上里侧表示的魔法师族怪兽
function c96352326.filter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsFacedown()
end
-- 效果②（改变表示形式）的发动准备与可行性检查函数
function c96352326.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己场上是否存在至少1只里侧表示的魔法师族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c96352326.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理的操作信息，表示该效果包含改变1张卡表示形式的操作
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 效果②（改变表示形式）的效果处理函数
function c96352326.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择自己场上1只里侧表示的魔法师族怪兽
	local g=Duel.SelectMatchingCard(tp,c96352326.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家选择将该怪兽变成表侧攻击表示还是表侧守备表示
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		-- 改变该怪兽的表示形式为玩家选择的表示形式
		Duel.ChangePosition(tc,pos)
	end
end
