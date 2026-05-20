--バイオレンス・ウィッチ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：「黑蔷薇龙」或者有那个卡名记述的怪兽或植物族同调怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合，若场上有同调怪兽存在，丢弃1张手卡才能发动。从卡组把1只守备力1500以下的植物族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含效果①和效果②的定义
function s.initial_effect(c)
	-- 将「黑蔷薇龙」加入到这张卡的效果文本记载卡片列表中
	aux.AddCodeList(c,73580471)
	-- ①：「黑蔷薇龙」或者有那个卡名记述的怪兽或植物族同调怪兽在自己场上存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，若场上有同调怪兽存在，丢弃1张手卡才能发动。从卡组把1只守备力1500以下的植物族怪兽特殊召唤。这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"从卡组特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.spcost2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
-- 过滤函数：检测场上是否存在表侧表示的「黑蔷薇龙」、有「黑蔷薇龙」卡名记述的怪兽、或者植物族同调怪兽
function s.cfilter(c)
	return c:IsFaceup()
		and (c:IsCode(73580471)
			-- 或者该卡是效果文本中记载了「黑蔷薇龙」卡名的怪兽
			or aux.IsCodeListed(c,73580471) and c:IsType(TYPE_MONSTER)
			or c:IsRace(RACE_PLANT) and c:IsAllTypes(TYPE_SYNCHRO+TYPE_MONSTER))
end
-- 效果①的发动条件：自己场上存在满足条件的卡
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张满足过滤条件s.cfilter的卡
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动准备：检查自己怪兽区域是否有空位，且这张卡是否可以特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理：如果这张卡仍在手牌中，则将其特殊召唤
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤函数：检测场上是否存在表侧表示的同调怪兽
function s.cfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 效果②的发动代价：丢弃1张手牌
function s.spcost2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己手牌中是否存在可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 从手牌中选择1张卡作为代价丢弃
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数：检测卡组中是否存在守备力1500以下的植物族怪兽，且该怪兽可以被特殊召唤
function s.spfilter(c,e,tp)
	return c:IsRace(RACE_PLANT) and c:IsDefenseBelow(1500) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动准备：检查场上是否有同调怪兽、自己怪兽区域是否有空位、以及卡组中是否有可特殊召唤的怪兽
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查场上是否存在同调怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 并且检查自己场上是否有可用的怪兽区域空格
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查自己卡组中是否存在满足特殊召唤条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息：从卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果②的效果处理：从卡组特殊召唤1只守备力1500以下的植物族怪兽，并适用“直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤”的限制
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否有可用的怪兽区域空格
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从卡组中选择1只满足过滤条件s.spfilter的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以表侧表示特殊召唤到自己的怪兽区域
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个效果的发动后，直到回合结束时自己不是同调怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中注册该限制效果，使其对玩家生效
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件函数：限制玩家不能从额外卡组特殊召唤同调怪兽以外的怪兽
function s.splimit(e,c)
	return not c:IsType(TYPE_SYNCHRO) and c:IsLocation(LOCATION_EXTRA)
end
