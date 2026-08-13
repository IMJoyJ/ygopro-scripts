--ソード・ライゼオル
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：自己的场上或墓地有「雷火沸动」怪兽存在的场合，这张卡可以从手卡特殊召唤。这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只炎族·光属性怪兽加入手卡。
local s,id,o=GetID()
-- 注册两个主要效果：e1作为手卡规则特殊召唤效果（EFFECT_SPSUMMON_PROC），限定同名卡1回合1次并设定特殊召唤条件与处理；e2作为召唤成功时检索炎族·光属性怪兽的诱发效果，并设置1回合1次限制；e3克隆e2改为特殊召唤成功时也能发动，使②的召唤·特殊召唤两种场合都能检索。
function s.initial_effect(c)
	-- 对应效果原文：『这个卡名的①的方法的特殊召唤1回合只能有1次。①：自己的场上或墓地有「雷火沸动」怪兽存在的场合，这张卡可以从手卡特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.spcon)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- 对应效果原文：『这个卡名的②的效果1回合只能使用1次。②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只炎族·光属性怪兽加入手卡。』
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
end
-- 定义检索/判断用的过滤函数：检查c是否属于「雷火沸动」系列、是怪兽且处于可确认状态（如场上表侧或墓地），用于判断场上或墓地是否存在「雷火沸动」怪兽。
function s.spfilter(c)
	return c:IsSetCard(0x1be) and c:IsFaceupEx() and c:IsType(TYPE_MONSTER)
end
-- 特殊召唤规则的条件判断：若入参c为空则视为可进行规则特殊召唤；否则需要自己场上有可用怪兽区空格，且自己场上或墓地存在满足s.spfilter的「雷火沸动」怪兽，才能从手卡特殊召唤。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查玩家tp的怪兽区域是否有空位，确保特殊召唤有可用的格子。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 统计玩家tp场上·墓地中满足s.spfilter的「雷火沸动」怪兽数量是否大于0，以确认存在符合条件的怪兽。
		and Duel.GetMatchingGroupCount(s.spfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,nil)>0
end
-- 特殊召唤成功后的处理：为tp玩家设置一个到结束阶段有效的誓约自肃，使其不能从额外卡组特殊召唤非4阶的超量怪兽（即本次用①特殊召唤过的回合，额外卡组只能出4阶超量）。
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 对应效果原文：『这个方法特殊召唤过的回合，自己不是4阶超量怪兽不能从额外卡组特殊召唤。』以及『②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1只炎族·光属性怪兽加入手卡。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将该自肃效果e1注册到玩家tp，使其在该回合内对tp生效，限制其从额外卡组进行的特殊召唤行为。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃的过滤条件：当且仅当c位于额外卡组且不是“4阶超量怪兽”时，禁止将其特殊召唤；即放行4阶超量怪兽，禁止其他额外怪兽。
function s.splimit(e,c)
	return not (c:IsType(TYPE_XYZ) and c:IsRank(4)) and c:IsLocation(LOCATION_EXTRA)
end
-- 检索目标过滤条件：c是炎族、光属性怪兽，且当前可以被加入手卡（没有受到‘不能加入手卡’限制）。
function s.filter(c)
	return c:IsRace(RACE_PYRO) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsAbleToHand()
end
-- ②的发动目标判定：效果发动时检查自己卡组是否存在至少1只满足s.filter的怪兽；若存在则允许发动，并设置操作信息为‘从卡组将1张卡加入手卡’。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动合法性检查阶段（chk==0），确认卡组中有1张以上符合条件的炎族·光属性怪兽，作为②能否发动的条件。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置本次连锁的操作信息：效果类别为检索并加入手卡（CATEGORY_TOHAND），预计处理1张来自卡组的卡，目标玩家为tp，位置为卡组。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②的效果处理：从卡组选择1张符合条件的炎族·光属性怪兽加入手卡；若选到卡则将其加入持有者手卡，并向对方展示确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家tp显示‘请选择要加入手牌的卡’的提示信息，用于卡组选择时的UI提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家tp从自己的卡组中筛选并选择1张满足s.filter的卡，返回所选卡组作为g。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡g以效果原因（REASON_EFFECT）送去其持有者的手卡，完成检索加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的那张卡展示给对方玩家（1-tp）确认，使对手知道检索了哪张卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
