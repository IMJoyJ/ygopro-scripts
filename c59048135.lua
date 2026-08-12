--昇華する紋章
-- 效果：
-- 只要这张卡在场上存在，场上的念动力族超量怪兽不会成为魔法·陷阱卡的效果的对象。此外，1回合1次，自己的主要阶段时从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。从卡组把「升华的纹章」以外的1张名字带有「纹章」的魔法·陷阱卡加入手卡。这个效果发动的回合，自己不是念动力族超量怪兽以及名字带有「纹章兽」的怪兽不能召唤·特殊召唤。
function c59048135.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，自己的主要阶段时从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。从卡组把「升华的纹章」以外的1张名字带有「纹章」的魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(59048135,0))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetCost(c59048135.thcost)
	e2:SetTarget(c59048135.thtg)
	e2:SetOperation(c59048135.thop)
	c:RegisterEffect(e2)
	-- 只要这张卡在场上存在，场上的念动力族超量怪兽不会成为魔法·陷阱卡的效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(c59048135.etarget)
	e3:SetValue(c59048135.evalue)
	c:RegisterEffect(e3)
	-- 注册通常召唤的自定义活动计数器，用于限制本回合非念动力族超量或非「纹章兽」怪兽的通常召唤
	Duel.AddCustomActivityCounter(59048135,ACTIVITY_SUMMON,c59048135.counterfilter)
	-- 注册特殊召唤的自定义活动计数器，用于限制本回合非念动力族超量或非「纹章兽」怪兽的特殊召唤
	Duel.AddCustomActivityCounter(59048135,ACTIVITY_SPSUMMON,c59048135.counterfilter)
end
-- 自定义活动计数器过滤函数，判断怪兽是否为念动力族超量怪兽或「纹章兽」怪兽
function c59048135.counterfilter(c)
	return (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ) or c:IsSetCard(0x76)) and c:IsFaceup()
end
-- 效果影响的目标过滤，仅适用于念动力族超量怪兽
function c59048135.etarget(e,c)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- 限制效果来源必须为魔法·陷阱卡的效果
function c59048135.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤手卡中用于丢弃的「纹章兽」怪兽
function c59048135.cfilter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 效果发动的代价检查（确认本回合未召唤或特殊召唤过受限怪兽，且手卡有可丢弃的「纹章兽」怪兽）
function c59048135.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在可行性检查时，确认本回合至今没有进行过非念动力族超量或非「纹章兽」怪兽的通常召唤
	if chk==0 then return Duel.GetCustomActivityCount(59048135,tp,ACTIVITY_SUMMON)==0
		-- 确认本回合至今没有进行过非念动力族超量或非「纹章兽」怪兽的特殊召唤
		and Duel.GetCustomActivityCount(59048135,tp,ACTIVITY_SPSUMMON)==0
		-- 并确认手卡中存在至少1张可用于丢弃的「纹章兽」怪兽
		and Duel.IsExistingMatchingCard(c59048135.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手卡丢弃1只「纹章兽」怪兽作为发动代价
	Duel.DiscardHand(tp,c59048135.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
	-- 这个效果发动的回合，自己不是念动力族超量怪兽以及名字带有「纹章兽」的怪兽不能召唤·特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59048135.splimit)
	-- 对发动效果的玩家注册本回合不能特殊召唤受限以外怪兽的效果
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 对发动效果的玩家注册本回合不能通常召唤受限以外怪兽的效果
	Duel.RegisterEffect(e2,tp)
end
-- 限制召唤·特殊召唤的怪兽过滤，限制只能召唤或特殊召唤念动力族超量怪兽或「纹章兽」怪兽
function c59048135.splimit(e,c)
	return not (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)) and not c:IsSetCard(0x76)
end
-- 过滤卡组中「升华的纹章」以外的「纹章」魔法·陷阱卡
function c59048135.filter(c)
	return c:IsSetCard(0x92) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(59048135) and c:IsAbleToHand()
end
-- 检索效果的靶子过滤与操作信息设置
function c59048135.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在可行性检查时，确认卡组中存在除「升华的纹章」以外的「纹章」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c59048135.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为“从卡组将1张卡加入手卡”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的具体处理（从卡组将1张满足条件的「纹章」魔法·陷阱卡加入手卡）
function c59048135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张符合条件的「纹章」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,c59048135.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认选择的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
