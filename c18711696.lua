--バスターソニック・ウォリアー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：「废品战士」「爆裂模式」或者有那其中任意种的卡名记述的卡在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只「同调士」怪兽或1张「爆裂模式」加入手卡。
-- ③：这张卡作为同调素材送去墓地的场合才能发动。这个回合中，自己场上的怪兽的攻击力上升500。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果，分别对应①②③效果
function s.initial_effect(c)
	-- 记录该卡具有「废品战士」和「爆裂模式」的卡名
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
-- 定义用于判断场上是否存在指定卡名的怪兽的过滤函数
function s.cfilter(c)
	-- 判断怪兽是否正面表示且具有「废品战士」或「爆裂模式」的卡名
	return c:IsFaceup() and (aux.IsCodeOrListed(c,60800381) or aux.IsCodeOrListed(c,80280737))
end
-- 判断场上是否存在满足条件的怪兽，用于①效果的发动条件
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在满足条件的怪兽，用于①效果的发动条件
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①效果的发动时的处理函数，判断是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断目标怪兽是否可以特殊召唤到场上
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时要特殊召唤的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理函数，将卡片特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行将卡片特殊召唤到场上的操作
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义用于检索「同调士」怪兽或「爆裂模式」的过滤函数
function s.filter(c)
	return (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1017) or c:IsCode(80280737)) and c:IsAbleToHand()
end
-- ②效果的发动时的处理函数，判断是否可以检索卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡片信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理函数，选择并检索卡片
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件函数，判断是否为同调素材并送去墓地
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- ③效果的发动处理函数，使场上怪兽攻击力上升500
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 创建并注册攻击力上升的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetValue(500)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将攻击力上升效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
