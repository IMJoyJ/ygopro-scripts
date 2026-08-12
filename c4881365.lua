--ワイバーンの竜騎士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡在手卡存在的场合，把这张卡以外的有「时间黑魔术师」的卡名记述的手卡1张卡给对方观看才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「时间黑魔术师」的卡名记述的最多2张魔法·陷阱卡加入手卡（同名卡最多1张）。那之后，选自己1张手卡丢弃。
-- ③：这张卡可以直接攻击。
local s,id,o=GetID()
-- 初始化本卡效果：注册手卡特召的起动效果①、召唤·特殊召唤成功时触发的检索效果②（含通常召唤与特殊召唤两种触发）、以及永续效果③（可以直接攻击）
function s.initial_effect(c)
	-- 在本卡上登记「时间黑魔术师」（卡号40235813）的卡名，表示这张卡的卡名记述中写有该卡
	aux.AddCodeList(c,40235813)
	-- ①：这张卡在手卡存在的场合，把这张卡以外的有「时间黑魔术师」的卡名记述的手卡1张卡给对方观看才能发动。这张卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把有「时间黑魔术师」的卡名记述的最多2张魔法·陷阱卡加入手卡（同名卡最多1张）。那之后，选自己1张手卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"检索"
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES_SELF)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：这张卡可以直接攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e4)
end
-- 定义给对方观看的手卡过滤器：要求该卡的卡名记述中写有「时间黑魔术师」且当前不处于公开状态
function s.cfilter(c)
	-- 判定该卡是否记述有「时间黑魔术师」的卡名且未公开（可被作为代价给对方观看）
	return aux.IsCodeListed(c,40235813) and not c:IsPublic()
end
-- ①效果的代价处理：检测手卡是否存在满足条件的卡，然后选1张给对方观看并洗切手卡
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检测：检查自己手卡是否存在至少1张满足条件（这张卡以外）的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,c) end
	-- 向自己发出「请选择给对方确认的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从自己手卡选择1张记述有「时间黑魔术师」卡名且未公开的卡（这张卡除外）作为代价
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,c)
	-- 将选出的卡给对方玩家观看确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切自己的手卡（隐藏被确认卡的位置信息）
	Duel.ShuffleHand(tp)
end
-- ①效果的目标设定：检测自己主要怪兽区是否有可用空格且这张卡可以被特殊召唤
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动条件检测：确认自己主要怪兽区还有可用空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：声明本连锁将特殊召唤这张卡（1张）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：若这张卡仍与连锁关联，则将其以攻击表示特殊召唤到自己场上
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以正面表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 定义卡组检索过滤器：要求该卡的卡名记述中写有「时间黑魔术师」、属于魔法·陷阱卡且可以加入手卡
function s.thfilter(c)
	-- 判定该卡是否记述有「时间黑魔术师」的卡名、是魔法或陷阱卡且可以加入手卡
	return aux.IsCodeListed(c,40235813) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果的目标设定：检测卡组是否存在可加入手卡的满足条件的魔法·陷阱卡，并设置操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：检查自己卡组是否存在至少1张满足条件的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：声明本连锁将从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ②效果的处理：从卡组把记述有「时间黑魔术师」卡名的最多2张魔法·陷阱卡加入手卡（同名卡最多1张），那之后选1张自己的手卡丢弃
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中所有满足条件的魔法·陷阱卡
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()==0 then return end
	-- 向自己发出「请选择要加入手牌的卡」的选择提示
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从满足条件的卡中选择1～2张卡名互不相同的卡（同名卡最多1张）
	local tg1=g:SelectSubGroup(tp,aux.dncheck,false,1,2)
	-- 将选出的卡以效果原因加入手卡，并判断是否至少有1张实际加入成功
	if Duel.SendtoHand(tg1,nil,REASON_EFFECT)>0 then
		-- 将加入手卡的卡给对方玩家观看确认
		Duel.ConfirmCards(1-tp,tg1)
		-- 中断当前效果处理，使之后的丢弃手卡处理视为不同时处理
		Duel.BreakEffect()
		-- 向自己发出「请选择要丢弃的手牌」的选择提示
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 从自己的手卡选择1张可以丢弃的卡
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 洗切自己的手卡
		Duel.ShuffleHand(tp)
		-- 将选出的手卡以效果丢弃的原因送去墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
