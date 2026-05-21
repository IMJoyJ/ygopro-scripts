--アイス・ドール
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①、②、③的注册以及特殊召唤计数器的设置。
function s.initial_effect(c)
	-- 记录该卡片效果中记载了「冰偶镜」（卡号65569724）的事实。
	aux.AddCodeList(c,65569724)
	-- ①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索怪兽"
	e2:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"检索魔法"
	e4:SetCategory(CATEGORY_SEARCH|CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id+o*2)
	e4:SetCondition(s.thcon2)
	e4:SetCost(s.thcost)
	e4:SetTarget(s.thtg2)
	e4:SetOperation(s.thop2)
	c:RegisterEffect(e4)
	-- 添加自定义活动计数器，用于检测本回合是否特殊召唤过非水属性怪兽。
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器过滤函数，用于判定特殊召唤的怪兽是否为水属性。
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果发动代价与誓约限制处理函数，检查并适用“这个效果发动的回合，自己不是水属性怪兽不能特殊召唤”的限制。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合在发动此效果前是否特殊召唤过非水属性怪兽。
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册不能特殊召唤水属性以外怪兽的限制效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的怪兽属性不能为水属性以外的属性。
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤手牌中可丢弃的其他水属性怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 效果①的发动代价与誓约限制处理函数。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足誓约限制，并且手牌中是否存在除自身以外的水属性怪兽。
	if chk==0 then return s.thcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手牌丢弃1只除自身以外的水属性怪兽作为发动代价。
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
	s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 效果①的发动目标确认函数，检查怪兽区域是否有空位以及自身是否可以特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁信息，表明此效果包含将自身特殊召唤的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数，将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将这张卡以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中可以加入手牌的魔法师族·水属性怪兽。
function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 效果②的发动目标确认函数，检查卡组中是否存在可检索的怪兽并设置连锁信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的魔法师族·水属性怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明此效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理函数，从卡组检索1只魔法师族·水属性怪兽。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足条件的魔法师族·水属性怪兽。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的怪兽加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③的发动条件函数，检查这张卡此前是否在场上。
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中可以加入手牌的「冰偶镜」。
function s.thfilter2(c)
	return c:IsCode(65569724) and c:IsAbleToHand()
end
-- 效果③的发动目标确认函数，检查卡组中是否存在「冰偶镜」并设置连锁信息。
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「冰偶镜」。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表明此效果包含从卡组将1张卡加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数，从卡组检索1张「冰偶镜」。
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张「冰偶镜」。
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的「冰偶镜」加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
