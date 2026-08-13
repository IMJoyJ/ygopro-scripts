--バスターソニック・ウォリアー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：「废品战士」「爆裂模式」或者有那其中任意种的卡名记述的卡在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「同调士」怪兽或1张「爆裂模式」加入手卡。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。这个回合中，自己场上的怪兽的攻击力上升500。
local s,id,o=GetID()
-- 为该卡注册三个效果：①手牌起动效果，满足条件时可特殊召唤自身；②召唤/特殊召唤成功时从卡组把1只「同调士」怪兽或1张「爆裂模式」加入手牌；③作为同调素材送去墓地时，这个回合中自己场上的怪兽攻击力上升500。
function s.initial_effect(c)
	-- 在卡片c上登记代码列表，标记本卡效果文本中记述了「废品战士」(60800381)与「爆裂模式」(80280737)，用于后续aux.IsCodeOrListed判定「有那其中任意种的卡名记述的卡」。
	aux.AddCodeList(c,60800381,80280737)
	-- ①：「废品战士」「爆裂模式」或者有那其中任意种的卡名记述的卡在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「同调士」怪兽或1张「爆裂模式」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡作为同调素材送去墓地的场合才能发动。这个回合中，自己场上的怪兽的攻击力上升500。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"攻击力上升"
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_BE_MATERIAL)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.atkcon)
	e4:SetOperation(s.atkop)
	c:RegisterEffect(e4)
end
-- 定义①效果的过滤函数：筛选出表侧表示且卡名为「废品战士」/「爆裂模式」或效果文本中记述了二者之一的卡。
function s.cfilter(c)
	-- 判断卡c是否为表侧表示，并且是「废品战士」「爆裂模式」之一，或卡名记述了其中任意一种。
	return c:IsFaceup() and (aux.IsCodeOrListed(c,60800381) or aux.IsCodeOrListed(c,80280737))
end
-- ①效果的发动条件：检查自己场上是否存在至少1张满足s.cfilter的卡（即「废品战士」「爆裂模式」或记述其卡名的卡）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 在自己场上（LOCATION_ONFIELD）检索是否存在至少1张满足s.cfilter的卡，并以此作为①效果可否发动的条件。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果发动时的目标合法性检查：当chk==0时，确认自己主要怪兽区有空位且这张卡可以被效果特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动时检查自己场上是否还有可用的怪兽区域，用于特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，声明本连锁将特殊召唤这张卡，供其他卡进行对应/判定（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的实际处理：若这张卡仍与当前连锁相关（仍在手牌且未被无效），则将其特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧攻击表示特殊召唤到自己场上，参数false,false表示按常规检查召唤条件与苏生限制。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义②效果的检索过滤函数：从卡组选择1只「同调士」怪兽（0x1017）或1张「爆裂模式」（80280737），且该卡能够加入手牌。
function s.filter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1017) or c:IsCode(80280737)) and c:IsAbleToHand()
end
-- ②效果发动时的目标检查：确认卡组中存在检索对象，并设置将1张卡从卡组加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在②效果发动时检查卡组中是否存在至少1张满足s.filter的检索对象。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，声明此效果将把1张卡从卡组加入手牌（处理时再选择，因此targets为nil）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：从卡组选择1只「同调士」怪兽或1张「爆裂模式」加入手牌，并展示给对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp发送“请选择要加入手牌的卡”的选择提示，配合后续选择操作。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中选择1张满足s.filter的卡，返回选中的组对象g。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡g以效果原因（REASON_EFFECT）加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对方玩家（1-tp）确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡位于墓地且作为同调素材被使用（原因是同调召唤REASON_SYNCHRO）。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ③效果处理：为自己场上所有怪兽设置攻击力上升500的效果，该效果持续到结束阶段。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 这个回合中，自己场上的怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的攻击力上升500效果注册到己方场上，使其在本回合内实际生效。
	Duel.RegisterEffect(e1,tp)
end
