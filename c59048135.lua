--昇華する紋章
-- 效果：
-- 只要这张卡在场上存在，场上的念动力族超量怪兽不会成为魔法·陷阱卡的效果的对象。此外，1回合1次，自己的主要阶段时从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。从卡组把「升华的纹章」以外的1张名字带有「纹章」的魔法·陷阱卡加入手卡。这个效果发动的回合，自己不是念动力族超量怪兽以及名字带有「纹章兽」的怪兽不能召唤·特殊召唤。
function c59048135.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，自己的主要阶段时从手卡丢弃1只名字带有「纹章兽」的怪兽才能发动。从卡组把「升华的纹章」以外的1张名字带有「纹章」的魔法·陷阱卡加入手卡。这个效果发动的回合，自己不是念动力族超量怪兽以及名字带有「纹章兽」的怪兽不能召唤·特殊召唤。
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
	-- 添加一个自定义活动计数器，用于记录本回合不满足过滤条件（即不是念动力族超量怪兽且不是「纹章兽」怪兽）的通常召唤次数。
	Duel.AddCustomActivityCounter(59048135,ACTIVITY_SUMMON,c59048135.counterfilter)
	-- 添加一个自定义活动计数器，用于记录本回合不满足过滤条件（即不是念动力族超量怪兽且不是「纹章兽」怪兽）的特殊召唤次数。
	Duel.AddCustomActivityCounter(59048135,ACTIVITY_SPSUMMON,c59048135.counterfilter)
end
-- 计数器过滤函数，判断卡片是否为念动力族超量怪兽或名字带有「纹章兽」的怪兽。
function c59048135.counterfilter(c)
	return (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ) or c:IsSetCard(0x76)) and c:IsFaceup()
end
-- 对象抗性效果的目标过滤函数，筛选场上的念动力族超量怪兽。
function c59048135.etarget(e,c)
	return c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)
end
-- 对象抗性效果的价值函数，限制不能成为魔法·陷阱卡的效果的对象。
function c59048135.evalue(e,re,rp)
	return re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤手牌中可丢弃的名字带有「纹章兽」的怪兽卡。
function c59048135.cfilter(c)
	return c:IsSetCard(0x76) and c:IsType(TYPE_MONSTER) and c:IsDiscardable()
end
-- 检索效果的发动代价（Cost）与发动条件判断函数。
function c59048135.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，判断本回合是否未进行过不符合限制条件的通常召唤。
	if chk==0 then return Duel.GetCustomActivityCount(59048135,tp,ACTIVITY_SUMMON)==0
		-- 判断本回合是否未进行过不符合限制条件的特殊召唤。
		and Duel.GetCustomActivityCount(59048135,tp,ACTIVITY_SPSUMMON)==0
		-- 判断手牌中是否存在至少1张满足条件的名字带有「纹章兽」的怪兽。
		and Duel.IsExistingMatchingCard(c59048135.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1只名字带有「纹章兽」的怪兽丢弃作为发动的代价。
	Duel.DiscardHand(tp,c59048135.cfilter,1,1,REASON_COST+REASON_DISCARD,nil)
	-- 这个效果发动的回合，自己不是念动力族超量怪兽以及名字带有「纹章兽」的怪兽不能召唤·特殊召唤。从卡组把「升华的纹章」以外的1张名字带有「纹章」的魔法·陷阱卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetReset(RESET_PHASE+PHASE_END)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c59048135.splimit)
	-- 向玩家注册不能特殊召唤特定怪兽以外怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_CANNOT_SUMMON)
	-- 向玩家注册不能通常召唤特定怪兽以外怪兽的限制效果。
	Duel.RegisterEffect(e2,tp)
end
-- 召唤/特殊召唤限制的过滤函数，限制不能召唤·特殊召唤念动力族超量怪兽及「纹章兽」怪兽以外的怪兽。
function c59048135.splimit(e,c)
	return not (c:IsRace(RACE_PSYCHO) and c:IsType(TYPE_XYZ)) and not c:IsSetCard(0x76)
end
-- 过滤卡组中「升华的纹章」以外的「纹章」魔法·陷阱卡。
function c59048135.filter(c)
	return c:IsSetCard(0x92) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(59048135) and c:IsAbleToHand()
end
-- 检索效果的发动目标（Target）判断与操作信息设置函数。
function c59048135.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动条件检查时，判断卡组中是否存在满足条件的「纹章」魔法·陷阱卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c59048135.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前处理的连锁的操作信息，表示该效果会将卡组中的1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理（Operation）函数。
function c59048135.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足条件的「纹章」魔法·陷阱卡。
	local g=Duel.SelectMatchingCard(tp,c59048135.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
