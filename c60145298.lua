--白魔女ディアベルゼ
-- 效果：
-- 这个卡名在规则上也当作「白森林」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「罪宝」卡或「迪亚贝尔」卡送去墓地。
-- ③：只要自己场上有「迪亚贝尔」怪兽2只以上存在，自己场上的怪兽不会被对方的效果破坏。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。这张卡从手卡特殊召唤。
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
	-- ②：这张卡召唤·特殊召唤的场合才能发动。从卡组把1张「罪宝」卡或「迪亚贝尔」卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"送去墓地"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：只要自己场上有「迪亚贝尔」怪兽2只以上存在，自己场上的怪兽不会被对方的效果破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,0)
	e4:SetCondition(s.effcon)
	-- 设置不受对方效果破坏的影响
	e4:SetValue(aux.indoval)
	c:RegisterEffect(e4)
end
-- 过滤手卡或场上可作为特殊召唤代价送去墓地的魔法·陷阱卡
function s.costfilter(c,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
		-- 检查卡片是否能送去墓地，且该卡离开场后自己场上是否有可用的怪兽区域
		and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果①特殊召唤的代价判定与执行函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可作为特殊召唤代价送去墓地的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,e:GetHandler(),tp) end
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择1张手卡或场上的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,e:GetHandler(),tp)
	-- 将选中的卡作为代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①特殊召唤的发动准备函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁中的操作信息为特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①特殊召唤的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤卡组中可以送去墓地的「罪宝」卡或「迪亚贝尔」卡
function s.tgfilter(c)
	return c:IsSetCard(0x19e,0x19b) and c:IsAbleToGrave()
end
-- 效果②送去墓地的发动准备函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可以送去墓地的「罪宝」卡或「迪亚贝尔」卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁中的操作信息为从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果②送去墓地的效果处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张「罪宝」卡或「迪亚贝尔」卡
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 效果③永续效果的适用条件判定函数
function s.effcon(e)
	-- 检查自己场上是否存在2只以上表侧表示的「迪亚贝尔」怪兽
	return Duel.IsExistingMatchingCard(aux.AND(Card.IsFaceup,Card.IsSetCard),e:GetHandlerPlayer(),LOCATION_MZONE,0,2,nil,0x19b)
end
