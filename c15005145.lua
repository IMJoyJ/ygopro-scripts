--重騎士プリメラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「重骑士 普莉梅拉」以外的1张「百夫长骑士」卡加入手卡。这个回合，自己不能把「重骑士 普莉梅拉」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己场上的5星以上的「百夫长骑士」怪兽不会被效果破坏。
-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 创建并注册该卡的4个效果：①召唤时的效果、②特殊召唤时的效果、③永续陷阱效果（不被效果破坏）、④永续陷阱效果（主要阶段可特殊召唤）
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
-- 检索过滤函数：筛选卡组中「百夫长骑士」卡且不是自身，且可以加入手牌
function s.thfilter(c)
	return c:IsSetCard(0x1a2) and not c:IsCode(id) and c:IsAbleToHand()
end
-- 效果处理前的判定：检查卡组中是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理信息：将要从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：提示选择卡牌并执行加入手牌和确认操作，同时设置回合内不能特殊召唤自身的限制
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择满足条件的1张卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认所选的卡
		Duel.ConfirmCards(1-tp,g)
	end
	-- 创建并注册回合结束时失效的不能特殊召唤效果，防止自己在本回合再次特殊召唤该卡
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 限制特殊召唤的过滤函数：禁止特殊召唤该卡
function s.splimit(e,c)
	return c:IsCode(id)
end
-- 永续陷阱效果的发动条件：该卡当前为永续陷阱状态
function s.edcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 永续陷阱效果的目标过滤函数：筛选场上5星以上的「百夫长骑士」怪兽
function s.edtg(e,c)
	return c:IsSetCard(0x1a2) and c:IsLevelAbove(5)
end
-- 特殊召唤效果的发动条件：当前为己方主要阶段且该卡为永续陷阱状态
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- 特殊召唤效果处理前的判定：检查是否可以特殊召唤该卡
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查目标玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查目标玩家是否可以特殊召唤该卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT+TYPE_TUNER,1600,1600,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) end
	-- 设置效果处理信息：将要特殊召唤该卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果处理函数：执行特殊召唤操作
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 执行特殊召唤操作
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
