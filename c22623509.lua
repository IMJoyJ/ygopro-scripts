--エンディミオンの侍女ヴェール
-- 效果：
-- 这个卡名在规则上也当作「魔女术」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法卡的效果发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「魔女术」魔法·陷阱卡或「次元魔法」加入手卡。
-- ③：只要自己的场上或墓地有「圣月之皇太子 雷古勒斯」存在，这张卡的攻击力上升2300。
local s,id,o=GetID()
-- 初始化效果函数，注册三个效果并设置计数器
function s.initial_effect(c)
	-- 将卡名28553439和96228804添加到该卡的代码列表中，使其在规则上也当作「魔女术」卡使用
	aux.AddCodeList(c,28553439,96228804)
	-- ①：魔法卡的效果发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「魔女术」魔法·陷阱卡或「次元魔法」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ③：只要自己的场上或墓地有「圣月之皇太子 雷古勒斯」存在，这张卡的攻击力上升2300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.atkcon)
	e3:SetValue(2300)
	c:RegisterEffect(e3)
	-- 设置一个计数器，用于记录该卡在每回合发动的连锁次数
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数，用于判断是否为魔法卡的连锁
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL)
end
-- ①效果的发动条件：在魔法卡的效果发动的回合的自己主要阶段才能发动
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否在当前回合或对方回合有发动过魔法卡的连锁
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- ①效果的发动时点处理函数，检查是否满足特殊召唤条件
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理时的操作信息，表示将特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的发动处理函数，将此卡特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 执行特殊召唤操作，将此卡以正面表示特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 检索效果的过滤函数，用于筛选「魔女术」魔法·陷阱卡或「次元魔法」
function s.thfilter(c)
	return (c:IsSetCard(0x128) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(28553439)) and c:IsAbleToHand()
end
-- ②效果的发动时点处理函数，检查是否满足检索条件
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的操作信息，表示将从卡组检索卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的发动处理函数，选择并检索卡牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 攻击力上升效果的过滤函数，用于判断是否为「圣月之皇太子 雷古勒斯」
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsCode(96228804)
end
-- ③效果的发动条件函数，判断场上或墓地是否存在「圣月之皇太子 雷古勒斯」
function s.atkcon(e)
	local c=e:GetHandler()
	-- 检查场上或墓地是否存在「圣月之皇太子 雷古勒斯」
	return Duel.IsExistingMatchingCard(s.atkfilter,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
