--アイス・ドール
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。
-- ①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。
-- ③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
local s,id,o=GetID()
-- 初始化并注册卡片的各项效果和限制计数器
function s.initial_effect(c)
	-- 记录该卡名记载了「冰偶镜」的信息
	aux.AddCodeList(c,65569724)
	-- 这个卡名的①的效果1回合只能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。
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
	-- 这个卡名的②的效果1回合只能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。
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
	-- 这个卡名的③的效果1回合只能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
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
	-- 添加自定义活动计数器，用于监控特殊召唤的怪兽是否为水属性
	Duel.AddCustomActivityCounter(id,ACTIVITY_SPSUMMON,s.counterfilter)
end
-- 计数器的过滤函数，检测特殊召唤的怪兽是否为表侧表示的水属性
function s.counterfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup()
end
-- 检测并注册非水属性怪兽不能特殊召唤的玩家限制效果
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前，确认本回合自身是否未曾特殊召唤过非水属性怪兽
	if chk==0 then return Duel.GetCustomActivityCount(id,tp,ACTIVITY_SPSUMMON)==0 end
	-- 这个卡名的①②③的效果1回合各能使用1次，这些效果发动的回合，自己不是水属性怪兽不能特殊召唤。①：从手卡丢弃1只其他的水属性怪兽才能发动。这张卡从手卡特殊召唤。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只魔法师族·水属性怪兽加入手卡。③：这张卡从场上送去墓地的场合才能发动。从卡组把1张「冰偶镜」加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为发动效果的玩家注册该回合不能特殊召唤非水属性怪兽的限制
	Duel.RegisterEffect(e1,tp)
end
-- 限制玩家不能特殊召唤非水属性怪兽
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	return not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 过滤手卡中的水属性怪兽以用作丢弃的Cost
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable()
end
-- 丢弃1只手卡的水属性怪兽并应用特殊召唤限制作为发动的代价
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动前，检查自身是否满足特殊召唤限制条件且手卡中是否有符合条件的丢弃怪兽
	if chk==0 then return s.thcost(e,tp,eg,ep,ev,re,r,rp,chk) and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 丢弃1只手卡的水属性怪兽
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST+REASON_DISCARD,e:GetHandler())
	s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
end
-- 检查怪兽区域是否有空位以及自身是否能从手卡特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息，准备将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 若此卡与效果存在关联则将其特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡以表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤卡组中的魔法师族·水属性怪兽
function s.thfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsAttribute(ATTRIBUTE_WATER) and c:IsAbleToHand()
end
-- 检查卡组中是否存在符合条件的检索对象并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的魔法师族·水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，准备从卡组检索1张卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理，从卡组选择符合条件的怪兽加入手牌并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1只符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认并展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 确认此卡此前在场上存在（送去墓地的触发条件）
function s.thcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤卡组中的「冰偶镜」
function s.thfilter2(c)
	return c:IsCode(65569724) and c:IsAbleToHand()
end
-- 确认卡组中存在「冰偶镜」并设置检索操作信息
function s.thtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认卡组中是否存在「冰偶镜」
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter2,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息，准备从卡组检索1张「冰偶镜」
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索「冰偶镜」的效果处理，将卡组中的「冰偶镜」加入手牌并展示
function s.thop2(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张「冰偶镜」
	local g=Duel.SelectMatchingCard(tp,s.thfilter2,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的「冰偶镜」加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认并展示加入手牌的「冰偶镜」
		Duel.ConfirmCards(1-tp,g)
	end
end
