--アロマリリス－ロザリーナ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只调整以外的「芳香」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，创建两个效果：①回复基本分效果和②特殊召唤效果
function c24689197.initial_effect(c)
	-- ①自己·对方回合，把这张卡从手卡丢弃，以自己场上1只「芳香」怪兽为对象才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"回复基本分"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
	-- ②这张卡召唤·特殊召唤的场合才能发动。从卡组把1只调整以外的「芳香」怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是植物族怪兽不能特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 费用处理函数，检查是否可以丢弃此卡作为费用
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将此卡送去墓地作为费用
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于筛选场上表侧表示的「芳香」怪兽且攻击力大于0
function s.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xc9) and c:GetAttack()>0
end
-- 效果目标选择函数，选择一个符合条件的场上「芳香」怪兽作为目标，并设置回复LP的信息
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否存在符合条件的场上「芳香」怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择一个符合条件的场上「芳香」怪兽作为目标
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local rec=math.ceil(tc:GetAttack()/2)
	-- 设置操作信息，表示将要回复LP
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec)
end
-- 效果处理函数，根据目标怪兽的攻击力回复对应数值的LP
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	local rec=math.ceil(tc:GetAttack()/2)
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
	-- 使玩家回复指定数值的LP
	Duel.Recover(tp,rec,REASON_EFFECT) end
end
-- 过滤函数，用于筛选卡组中符合条件的「芳香」怪兽（非调整）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xc9) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的目标选择函数，检查是否有满足条件的怪兽可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在符合条件的「芳香」怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要从卡组特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 特殊召唤效果处理函数，从卡组选择一只符合条件的怪兽特殊召唤，并设置后续限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的召唤区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组选择一只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
	-- 将选中的怪兽特殊召唤到场上
	Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) end
	-- 设置一个场上的效果，限制玩家在回合结束前不能特殊召唤非植物族怪兽
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetReset(RESET_PHASE+PHASE_END)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	-- 将该效果注册到场上
	Duel.RegisterEffect(e2,tp)
end
-- 限制效果的目标函数，判断目标怪兽是否为植物族
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsRace(RACE_PLANT)
end
