--重騎士プリメラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「重骑士 普莉梅拉」以外的1张「百夫长骑士」卡加入手卡。这个回合，自己不能把「重骑士 普莉梅拉」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己场上的5星以上的「百夫长骑士」怪兽不会被效果破坏。
-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化卡片效果，注册召唤、特殊召唤时的检索效果、永续陷阱效果和主要阶段特殊召唤效果
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「重骑士 普莉梅拉」以外的1张「百夫长骑士」卡加入手卡。这个回合，自己不能把「重骑士 普莉梅拉」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡是当作永续陷阱卡使用的场合，自己场上的5星以上的「百夫长骑士」怪兽不会被效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetRange(LOCATION_SZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetCondition(s.edcon)
	e3:SetTarget(s.edtg)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetCountLimit(1,id+o)
	e4:SetHintTiming(0,TIMING_MAIN_END)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检索过滤函数，用于筛选「百夫长骑士」卡且不是自身卡号的卡
function s.thfilter(c)
	return c:IsSetCard(0x1a2) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 设置检索效果的处理目标，确定要检索的卡数量和位置
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索条件，即卡组中是否存在符合条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，表示将要进行检索并加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果的操作，选择卡并加入手牌，同时确认对方查看
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择符合条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 注册一个回合结束时失效的不能特殊召唤效果，防止本回合再次特殊召唤自身
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数，禁止召唤自身
function s.splimit(e,c)
	return c:IsCode(id)
end
-- 判断该卡是否为永续陷阱状态
function s.edcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 判断目标怪兽是否为「百夫长骑士」且等级不低于5
function s.edtg(e,c)
	return c:IsSetCard(0x1a2) and c:IsLevelAbove(5)
end
-- 判断当前是否为主要阶段且该卡为永续陷阱状态
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 设置特殊召唤效果的目标，判断是否可以特殊召唤自身
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断玩家是否可以特殊召唤指定参数的怪兽
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT+TYPE_TUNER,1600,1600,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) end
	-- 设置连锁操作信息，表示将要进行特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果的操作，将自身特殊召唤到场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
