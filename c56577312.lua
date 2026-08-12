--エレキカンシャ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：把最多有自己场上的雷族怪兽种类数量的「电气机车」以外的「电气」卡从卡组加入手卡（同名卡最多1张）。
-- ②：把墓地的这张卡除外才能发动。从手卡把「电气」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果在这张卡送去墓地的回合不能发动。
function c56577312.initial_effect(c)
	-- ①：把最多有自己场上的雷族怪兽种类数量的「电气机车」以外的「电气」卡从卡组加入手卡（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(56577312,0))  --"卡组检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,56577312)
	e1:SetTarget(c56577312.target)
	e1:SetOperation(c56577312.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外才能发动。从手卡把「电气」怪兽尽可能特殊召唤（同名卡最多1张）。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(56577312,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,56577313)
	-- 设置效果的发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置效果的Cost：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c56577312.sptg)
	e2:SetOperation(c56577312.spop)
	c:RegisterEffect(e2)
end
-- 过滤条件：自己场上表侧表示的雷族怪兽
function c56577312.ctfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_THUNDER)
end
-- 过滤条件：卡组中「电气机车」以外的、可以加入手卡的「电气」卡
function c56577312.thfilter(c)
	return c:IsSetCard(0xe) and not c:IsCode(56577312) and c:IsAbleToHand()
end
-- 效果1的发动准备与合法性检测函数
function c56577312.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只表侧表示的雷族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c56577312.ctfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 并且卡组中存在至少1张满足条件的「电气」卡
		and Duel.IsExistingMatchingCard(c56577312.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理中的操作信息：从卡组将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果1的处理函数：根据场上雷族怪兽种类数量，从卡组检索对应数量且卡名不同的「电气」卡
function c56577312.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的雷族怪兽
	local g1=Duel.GetMatchingGroup(c56577312.ctfilter,tp,LOCATION_MZONE,0,nil)
	-- 获取卡组中所有满足条件的「电气」卡
	local g2=Duel.GetMatchingGroup(c56577312.thfilter,tp,LOCATION_DECK,0,nil)
	if g1:GetCount()==0 or g2:GetCount()==0 then return end
	local ct=g1:GetClassCount(Card.GetCode)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1到ct张卡名互不相同的「电气」卡（ct为雷族怪兽种类数量）
	local sg=g2:SelectSubGroup(tp,aux.dncheck,false,1,ct)
	if sg and sg:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤条件：手牌中可以特殊召唤的「电气」怪兽
function c56577312.spfilter(c,e,tp)
	return c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果2的发动准备与合法性检测函数
function c56577312.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且手牌中存在至少1只可以特殊召唤的「电气」怪兽
		and Duel.IsExistingMatchingCard(c56577312.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁处理中的操作信息：从手牌特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果2的处理函数：从手牌尽可能特殊召唤卡名不同的「电气」怪兽
function c56577312.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的怪兽区域数量
	local ct=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 获取手牌中所有可以特殊召唤的「电气」怪兽
	local g=Duel.GetMatchingGroup(c56577312.spfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if ct<=0 or g:GetCount()==0 then return end
	ct=math.min(ct,g:GetClassCount(Card.GetCode))
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ct=1 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择数量等于ct且卡名互不相同的「电气」怪兽
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,ct,ct)
	if sg and sg:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤
		Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
	end
end
