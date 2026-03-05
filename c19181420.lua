--メメント・ツイン・ドラゴン
-- 效果：
-- 「莫忘」怪兽×2
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组把最多2只「莫忘」怪兽加入手卡（同名卡最多1张）。
-- ②：自己的「莫忘」怪兽战斗破坏的怪兽不去墓地而除外。
-- ③：融合召唤的这张卡被破坏的场合才能发动。从自己墓地把1只6星以下的「莫忘」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数，启用复活限制并设置融合召唤条件，创建三个效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡为需要2个「莫忘」卡作为融合素材的融合怪兽
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x1a1),2,true)
	-- ①：这张卡融合召唤的场合才能发动。自己的手卡·场上（表侧表示）1只「莫忘」怪兽破坏，从卡组把最多2只「莫忘」怪兽加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"破坏怪兽并检索「莫忘」怪兽"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_DESTROY+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：自己的「莫忘」怪兽战斗破坏的怪兽不去墓地而除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.tdtg)
	e2:SetValue(LOCATION_REMOVED)
	c:RegisterEffect(e2)
	-- ③：融合召唤的这张卡被破坏的场合才能发动。从自己墓地把1只6星以下的「莫忘」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"特殊召唤「莫忘」怪兽"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
-- 效果条件：该卡必须是融合召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- 过滤器1：选择自己手卡或场上的1只表侧表示的「莫忘」怪兽
function s.filter1(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1a1) and c:IsFaceupEx()
end
-- 过滤器2：选择自己卡组中1只「莫忘」怪兽
function s.filter2(c)
	return c:IsSetCard(0x1a1) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果目标设置：检查是否有满足条件的破坏对象和检索对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己手卡或场上的1只「莫忘」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil)
		-- 检查自己卡组中是否有「莫忘」怪兽
		and Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil) end
	-- 提示对方该效果已发动
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：将要破坏的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_HAND+LOCATION_MZONE)
	-- 设置操作信息：将要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：选择破坏1只怪兽并检索最多2只「莫忘」怪兽
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	-- 如果成功破坏，则继续检索
	if g:GetCount()>0 and Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取卡组中所有满足条件的「莫忘」怪兽
		local g2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_DECK,0,nil)
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择最多2张卡名不同的「莫忘」怪兽
		local tg=g2:SelectSubGroup(tp,aux.dncheck,false,1,2)
		if tg then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tg,nil,REASON_EFFECT)
			-- 向对方确认加入手牌的卡
			Duel.ConfirmCards(1-tp,tg)
			-- 洗切自己的手牌
			Duel.ShuffleHand(tp)
		end
	end
end
-- 战斗破坏时的处理目标过滤器：仅对「莫忘」怪兽生效
function s.tdtg(e,c)
	return c:IsSetCard(0x1a1)
end
-- 效果条件：该卡必须是从场上被破坏且为融合召唤
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
-- 效果目标设置：检查是否有满足条件的特殊召唤对象
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地是否有满足条件的「莫忘」怪兽
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置操作信息：将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 特殊召唤的过滤器：6星以下的「莫忘」怪兽
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1a1) and c:IsLevelBelow(6) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理函数：从墓地特殊召唤1只6星以下的「莫忘」怪兽
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
