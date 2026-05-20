--地縛囚人 ストーン・スィーパー
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次，②的效果1回合只能使用1次。
-- ①：场地区域有卡存在的场合，这张卡可以从手卡特殊召唤。
-- ②：把这张卡从手卡丢弃才能发动。从卡组把1只3星以下的恶魔族调整加入手卡。这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①的特殊召唤规则和②的起动效果。
function s.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：场地区域有卡存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
	-- 这个卡名的②的效果1回合只能使用1次。②：把这张卡从手卡丢弃才能发动。从卡组把1只3星以下的恶魔族调整加入手卡。这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 特殊召唤规则的条件检查函数，要求自身怪兽区域有空位且场地区域有卡存在。
function s.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上的主要怪兽区域是否有可用的空位。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查双方的场地区域是否存在卡片。
		and Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)>0
end
-- 检索效果的发动代价（Cost）处理函数，要求将自身从手卡丢弃。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 作为发动代价，将这张卡从手卡丢弃送去墓地。
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中满足“3星以下的恶魔族调整”且能加入手卡的卡片。
function s.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FIEND) and c:IsType(TYPE_TUNER) and c:IsAbleToHand()
end
-- 检索效果的发动准备（Target）处理函数，检查卡组中是否存在符合条件的卡，并设置操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查卡组中是否存在至少1只满足过滤条件的怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果在处理时会将卡组中的1张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的效果处理（Operation）函数，将符合条件的怪兽加入手卡，并对自身施加额外卡组特殊召唤限制。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 给发动效果的玩家发送提示信息，提示其选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1只满足过滤条件的怪兽。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的怪兽加入手卡。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手卡的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
	-- 这个效果的发动后，直到回合结束时自己不是融合·同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制特殊召唤的效果注册给发动效果的玩家，持续到回合结束。
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数，判定特殊召唤的卡是否来自额外卡组且不是融合或同调怪兽。
function s.limit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_FUSION+TYPE_SYNCHRO)
end
