--メンタルプロシージャー
-- 效果：
-- 这个卡名的①③的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤或者用怪兽的效果特殊召唤的场合，支付2000基本分才能发动。从自己的卡组·墓地把1张「瞬间移动」通常·速攻魔法卡加入手卡。
-- ②：把自己场上的这张卡作为念动力族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
-- ③：这张卡被除外的场合，支付1000基本分才能发动。这张卡特殊召唤。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·怪兽效果特召成功时支付2000LP检索/回收「瞬间移动」魔法卡，②作为念动力族同调素材时可当作非调整，③被除外时支付1000LP特殊召唤。
function s.initial_effect(c)
	-- ①：这张卡召唤或者用怪兽的效果特殊召唤的场合，支付2000基本分才能发动。从自己的卡组·墓地把1张「瞬间移动」通常·速攻魔法卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.thcost)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.thcon)
	c:RegisterEffect(e2)
	-- ②：把自己场上的这张卡作为念动力族同调怪兽的同调素材的场合，可以把这张卡当作调整以外的怪兽使用。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_NONTUNER)
	e3:SetValue(s.tnval)
	c:RegisterEffect(e3)
	-- ③：这张卡被除外的场合，支付1000基本分才能发动。这张卡特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_REMOVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,id)
	e4:SetCost(s.spcost)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- 检查是否是由怪兽的效果特殊召唤成功。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_MONSTER)
end
-- ①号效果的发动代价：检查并支付2000基本分。
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查玩家是否能够支付2000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,2000) end
	-- 让玩家支付2000基本分。
	Duel.PayLPCost(tp,2000)
end
-- 过滤条件：卡名含有「瞬间移动」且是通常魔法或速攻魔法，并且能加入手牌。
function s.thfilter(c)
	return c:IsSetCard(0x1cc) and (c:IsAllTypes(TYPE_QUICKPLAY+TYPE_SPELL) or c:GetType()==TYPE_SPELL) and c:IsAbleToHand()
end
-- ①号效果的发动准备：检查卡组或墓地是否存在满足条件的卡，并设置将卡加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己的卡组或墓地是否存在至少1张满足条件的「瞬间移动」魔法卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置连锁的操作信息，表示该效果会从卡组或墓地将1张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- ①号效果的处理：从卡组或墓地选择1张满足条件的「瞬间移动」魔法卡加入手牌（适用王家长眠之谷的过滤）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，要求选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己的卡组或墓地选择1张满足条件且不受王家长眠之谷影响的卡。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡因效果加入玩家手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 限制条件：作为同调素材的怪兽必须由自身控制，且同调怪兽必须是念动力族。
function s.tnval(e,c)
	return e:GetHandler():IsControler(c:GetControler()) and c:IsRace(RACE_PSYCHO)
end
-- ③号效果的发动代价：检查并支付1000基本分。
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查玩家是否能够支付1000基本分。
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	-- 让玩家支付1000基本分。
	Duel.PayLPCost(tp,1000)
end
-- ③号效果的发动准备：检查怪兽区域是否有空位，以及自身是否能特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动效果时，检查自己的主要怪兽区域是否有可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息，表示该效果会将自身特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③号效果的处理：如果自身仍存在于除外区（与连锁相关联），则将自身特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡以表侧表示特殊召唤到自己的场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
