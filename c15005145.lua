--重騎士プリメラ
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「重骑士 普莉梅拉」以外的1张「百夫长骑士」卡加入手卡。这个回合，自己不能把「重骑士 普莉梅拉」特殊召唤。
-- ②：这张卡是当作永续陷阱卡使用的场合，自己场上的5星以上的「百夫长骑士」怪兽不会被效果破坏。
-- ③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 初始化并注册卡片的三个效果：①召唤/特殊召唤成功时检索『百夫长骑士』并附加特召自肃（用两个触发事件共用同一检索效果）、②作为永续陷阱时使我方5星以上『百夫长骑士』怪兽获得效果破坏抗性、③作为永续陷阱时可在主要阶段将自身特殊召唤。
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
-- 检索过滤器：目标必须包含「百夫长骑士」字段、卡名不是「重骑士 普莉梅拉」，并且能够加入手卡。
function s.thfilter(c)
	return c:IsSetCard(0x1a2) and not c:IsCode(id) and c:IsAbleToHand()
end
-- ①效果的发动条件和操作信息：在可以发动时（chk==0）检查卡组是否存在满足条件的检索目标；若存在，则登记本次处理为从卡组将1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：卡组中存在至少1张满足thfilter条件的「百夫长骑士」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记操作信息：本次效果处理将从卡组把1张卡加入手卡（用于效果发动后的检索判定，不取对象）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行①效果：从卡组选择1张符合条件的「百夫长骑士」卡加入手卡并展示给对方，然后给自己附加这个回合不能特殊召唤「重骑士 普莉梅拉」的限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出选择提示：让操作玩家选择要加入手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己卡组选择1张满足thfilter条件的「百夫长骑士」卡作为检索对象。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片以效果原因加入其持有者的手卡（即自己的手卡）。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示刚刚加入手卡的卡片，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个回合，自己不能把「重骑士 普莉梅拉」特殊召唤。②：这张卡是当作永续陷阱卡使用的场合，自己场上的5星以上的「百夫长骑士」怪兽不会被效果破坏。③：这张卡是当作永续陷阱卡使用的场合，自己·对方的主要阶段才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘自己不能特殊召唤「重骑士 普莉梅拉」’的限制效果注册给当前玩家，持续到本回合结束阶段。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃限制的判定条件：只有卡名是「重骑士 普莉梅拉」的怪兽才受到不能特殊召唤的限制。
function s.splimit(e,c)
	return c:IsCode(id)
end
-- ②效果的适用条件：这张卡在魔法与陷阱区域且类型为永续陷阱（即正作为永续陷阱卡使用）。
function s.edcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- ②效果的适用对象：己方场上5星以上、属于「百夫长骑士」字段的怪兽。
function s.edtg(e,c)
	return c:IsSetCard(0x1a2) and c:IsLevelAbove(5)
end
-- ③效果的发动条件：当前为主要阶段1或主要阶段2，且这张卡正作为永续陷阱卡使用。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段，用于判断是否处于主要阶段。
	local ph=Duel.GetCurrentPhase()
	return (ph==PHASE_MAIN1 or ph==PHASE_MAIN2) and e:GetHandler():GetType()==TYPE_TRAP+TYPE_CONTINUOUS
end
-- ③效果的发动合法性检查：己方主要怪兽区有空位，且自己可以特殊召唤「重骑士 普莉梅拉」（以4星·光属性·魔法师族·调整·效果怪兽的形式）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否还有可用的主要怪兽区空格，确保特殊召唤后有格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己是否能够将「重骑士 普莉梅拉」以怪兽形式特殊召唤（使用其怪兽参数判定召唤规则是否允许）。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,id,0x1a2,TYPE_MONSTER+TYPE_EFFECT+TYPE_TUNER,1600,1600,4,RACE_SPELLCASTER,ATTRIBUTE_LIGHT) end
	-- 登记操作信息：本次效果处理将把这张卡自身特殊召唤（确定为特殊召唤对象）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行③效果：若这张卡仍与效果关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上（不检查召唤条件、不检查苏生限制）。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
