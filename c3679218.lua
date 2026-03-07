--トロイメア・マーメイド
-- 效果：
-- 「梦幻崩影·人鱼」以外的「幻崩」怪兽1只
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把1只「幻崩」怪兽特殊召唤。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以从卡组抽1张。
-- ②：只要这张卡在怪兽区域存在，场上的不在互相连接状态的怪兽的攻击力·守备力下降1000。
function c3679218.initial_effect(c)
	-- 添加连接召唤手续，要求使用1张以上1张以下的「幻崩」怪兽作为连接素材，且不能是此卡
	aux.AddLinkProcedure(c,c3679218.matfilter,1,1)
	c:EnableReviveLimit()
	-- ①：这张卡连接召唤成功的场合，丢弃1张手卡才能发动。从卡组把1只「幻崩」怪兽特殊召唤。这个效果的发动时这张卡是互相连接状态的场合，再让自己可以从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3679218,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,3679218)
	e1:SetCondition(c3679218.spcon)
	e1:SetCost(c3679218.spcost)
	e1:SetTarget(c3679218.sptg)
	e1:SetOperation(c3679218.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，场上的不在互相连接状态的怪兽的攻击力·守备力下降1000。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c3679218.atktg)
	e2:SetValue(-1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 连接素材过滤器，筛选「幻崩」属性且不是此卡的怪兽
function c3679218.matfilter(c)
	return c:IsLinkSetCard(0x112) and not c:IsLinkCode(3679218)
end
-- 效果发动条件，判断此卡是否为连接召唤
function c3679218.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动代价，丢弃1张手牌
function c3679218.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足丢弃手牌的条件
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃手牌操作
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤目标过滤器，筛选「幻崩」属性且可特殊召唤的怪兽
function c3679218.spfilter(c,e,tp)
	return c:IsSetCard(0x112) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时点，判断是否满足特殊召唤条件
function c3679218.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有特殊召唤怪兽的空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否有满足条件的怪兽
		and Duel.IsExistingMatchingCard(c3679218.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息，表示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	if e:GetHandler():GetMutualLinkedGroupCount()>0 then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
		e:SetLabel(1)
	else
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		e:SetLabel(0)
	end
end
-- 效果处理程序，执行特殊召唤并可能抽卡
function c3679218.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤怪兽的空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3679218.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	-- 执行特殊召唤操作
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断是否满足抽卡条件
		and e:GetLabel()==1 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽卡
		and Duel.SelectYesNo(tp,aux.Stringid(3679218,1)) then  --"是否抽卡？"
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 洗切玩家的卡组
		Duel.ShuffleDeck(tp)
		-- 让玩家抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 攻击力下降效果的目标过滤器，筛选不在互相连接状态的怪兽
function c3679218.atktg(e,c)
	return c:GetMutualLinkedGroupCount()==0
end
