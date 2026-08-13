--エンディミオンの侍女ヴェール
-- 效果：
-- 这个卡名在规则上也当作「魔女术」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：魔法卡的效果发动的回合的自己主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。从卡组把1张「魔女术」魔法·陷阱卡或「次元魔法」加入手卡。
-- ③：只要自己的场上或墓地有「圣月之皇太子 雷古勒斯」存在，这张卡的攻击力上升2300。
local s,id,o=GetID()
-- 定义这张卡的所有效果：注册①起动效果（手牌特殊召唤）、②诱发选发效果（特殊召唤成功时检索）、③永续攻击力上升效果，并注册自定义连锁计数器记录魔法卡效果发动。
function s.initial_effect(c)
	-- 通过代码列表记录本卡与「次元魔法」（28553439）和「圣月之皇太子 雷古勒斯」（96228804）的卡名关联，用于规则上视为「魔女术」以及相关效果判定。
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
	-- 注册一个以ACTIVITY_CHAIN为计数类型的自定义计数器，当玩家发动魔法卡效果时计数器增加，用于①效果的发动条件判定。
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
-- 计数器过滤函数：若当前发动的效果不是魔法卡效果则返回true（不计数），是魔法卡效果则返回false（使计数器+1）。
function s.chainfilter(re,tp,cid)
	return not re:IsActiveType(TYPE_SPELL)
end
-- ①效果的发动条件：本回合内自己或对方发动过魔法卡效果（通过自定义计数器的计数判断）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合自己或对方发动魔法卡效果的自定义计数是否大于0，任一大于0即满足条件。
	return Duel.GetCustomActivityCount(id,tp,ACTIVITY_CHAIN)>0 or Duel.GetCustomActivityCount(id,1-tp,ACTIVITY_CHAIN)>0
end
-- ①效果的target函数：在发动合法性检查时，确认自己主要怪兽区有空位，并且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置本连锁的操作信息：将这张卡特殊召唤，数量为1，用于后续相关效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与当前连锁相关，则将其从手卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己场上（不检查额外条件）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②检索的过滤条件：卡片属于「魔女术」系列的魔法·陷阱卡，或卡号为28553439的「次元魔法」，且可以加入手卡。
function s.thfilter(c)
	return (c:IsSetCard(0x128) and c:IsType(TYPE_SPELL+TYPE_TRAP) or c:IsCode(28553439)) and c:IsAbleToHand()
end
-- ②效果的target函数：检查卡组中是否存在1张符合条件的卡；若存在，设置操作信息为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足s.thfilter的卡片。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡（不取对象，数量预计为1）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果处理：提示选择后从卡组选1张符合条件的卡，将其加入手卡，并向对手展示。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向操作玩家发送选择提示，要求选择1张要加入手卡的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足s.thfilter的卡。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡以效果原因加入其持有者的手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到的卡展示给对手确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③攻击力上升的判定过滤器：卡片为表侧表示（含墓地区域）且卡名为「圣月之皇太子 雷古勒斯」。
function s.atkfilter(c)
	return c:IsFaceupEx() and c:IsCode(96228804)
end
-- ③永续效果的条件：这张卡的控制者场上或墓地存在1张满足s.atkfilter的「圣月之皇太子 雷古勒斯」。
function s.atkcon(e)
	local c=e:GetHandler()
	-- 检查这张卡的控制者场上或墓地是否存在至少1张符合条件的「圣月之皇太子 雷古勒斯」。
	return Duel.IsExistingMatchingCard(s.atkfilter,c:GetControler(),LOCATION_ONFIELD+LOCATION_GRAVE,0,1,nil)
end
