--K9－04号 咒
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
-- ②：这张卡召唤的场合才能发动。从卡组把1只机械族以外的「K9」怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「K9」怪兽不能从额外卡组特殊召唤。
-- ③：把自己场上1张表侧表示的「K9」卡送去墓地才能发动。把对方手卡全部确认。
local s,id,o=GetID()
-- 初始化卡片效果，注册三个效果：不用解放召唤、特殊召唤、确认手卡
function s.initial_effect(c)
	-- ①：对方手卡是2张以上的场合，这张卡可以不用解放作召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"不用解放召唤(K9-04号 咒)"
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetCondition(s.ntcon)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤的场合才能发动。从卡组把1只机械族以外的「K9」怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「K9」怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ③：把自己场上1张表侧表示的「K9」卡送去墓地才能发动。把对方手卡全部确认。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"确认手卡"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetCost(s.cfcost)
	e3:SetTarget(s.cftg)
	e3:SetOperation(s.cfop)
	c:RegisterEffect(e3)
end
-- 判断是否满足不用解放召唤的条件：等级不低于5，场上存在空位，对方手牌不少于2张
function s.ntcon(e,c,minc)
	if c==nil then return true end
	-- 等级不低于5且场上存在空位
	return minc==0 and c:IsLevelAbove(5) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
		-- 对方手牌不少于2张
		and Duel.IsExistingMatchingCard(aux.TRUE,c:GetControler(),0,LOCATION_HAND,2,nil)
end
-- 筛选满足条件的「K9」怪兽（非机械族）用于特殊召唤
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x1cb) and not c:IsRace(RACE_MACHINE) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断特殊召唤是否可以发动：场上有空位，卡组中存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 场上有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 卡组中存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：准备特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 执行特殊召唤操作：选择并特殊召唤符合条件的怪兽，并附加限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位，没有则不执行特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作并注册限制效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 创建并注册限制非K9怪兽从额外卡组特殊召唤的效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,3))  --"「K9-04号 咒」的效果特殊召唤"
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CONTROL)
		tc:RegisterEffect(e1,true)
	end
end
-- 筛选场上正面表示的K9卡作为送去墓地的代价
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0x1cb) and c:IsAbleToGraveAsCost()
end
-- 处理确认手卡效果的费用：选择一张场上正面表示的K9卡送去墓地
function s.cfcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的K9卡可以作为费用
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_ONFIELD,0,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择一张场上正面表示的K9卡送去墓地
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_ONFIELD,0,1,1,nil,tp)
	-- 将选中的卡送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 限制非K9怪兽从额外卡组特殊召唤的效果函数
function s.splimit(e,c)
	return not c:IsSetCard(0x1cb) and c:IsLocation(LOCATION_EXTRA)
end
-- 判断确认手卡效果是否可以发动：对方手牌中存在未公开的卡
function s.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方手牌中是否存在未公开的卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_HAND,1,nil) end
end
-- 执行确认手卡操作：确认对方手牌并洗切对方手牌
function s.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方所有手牌
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if g:GetCount()>0 then
		-- 确认对方手牌内容
		Duel.ConfirmCards(tp,g)
		-- 洗切对方手牌
		Duel.ShuffleHand(1-tp)
	end
end
