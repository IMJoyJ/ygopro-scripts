--地縛超神官
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：同调怪兽在自己的场上·墓地的两方存在的场合才能发动。这张卡从手卡特殊召唤。
-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1只「地缚神」怪兽加入手卡。
-- ③：这张卡已在怪兽区域存在的状态，「地缚神」怪兽召唤的场合才能发动。对方基本分变成3000。
function c45836982.initial_effect(c)
	-- ①：同调怪兽在自己的场上·墓地的两方存在的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,45836982)
	e1:SetCondition(c45836982.spcon)
	e1:SetTarget(c45836982.sptg)
	e1:SetOperation(c45836982.spop)
	c:RegisterEffect(e1)
	-- ②：自己主要阶段才能发动。从自己的卡组·墓地把1只「地缚神」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,45836983)
	e2:SetTarget(c45836982.thtg)
	e2:SetOperation(c45836982.thop)
	c:RegisterEffect(e2)
	-- ③：这张卡已在怪兽区域存在的状态，「地缚神」怪兽召唤的场合才能发动。对方基本分变成3000。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SUMMON_SUCCESS)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,45836984)
	e3:SetCondition(c45836982.lpcon)
	e3:SetOperation(c45836982.lpop)
	c:RegisterEffect(e3)
end
-- 过滤函数，检查以玩家来看的场上是否存在至少1张满足过滤条件的同调怪兽
function c45836982.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_SYNCHRO)
end
-- 检查以玩家来看的场上是否存在至少1张满足过滤条件的同调怪兽，并且检查以玩家来看的墓地是否存在至少1张同调怪兽
function c45836982.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查以玩家来看的场上是否存在至少1张满足过滤条件的同调怪兽
	return Duel.IsExistingMatchingCard(c45836982.cfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查以玩家来看的墓地是否存在至少1张同调怪兽
		and Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SYNCHRO)
end
-- 设置效果处理时的条件，判断是否满足特殊召唤的条件
function c45836982.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足特殊召唤的条件，检查场上是否有空位并且该卡可以被特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前处理的连锁的操作信息，确定要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将该卡特殊召唤到场上
function c45836982.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡以特殊召唤的方式召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤函数，检查以玩家来看的卡组或墓地是否存在至少1张满足过滤条件的「地缚神」怪兽
function c45836982.thfilter(c)
	return c:IsSetCard(0x1021) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时的条件，判断是否满足检索的条件
function c45836982.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足检索的条件，检查卡组或墓地是否存在至少1张满足过滤条件的「地缚神」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c45836982.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置当前处理的连锁的操作信息，确定要加入手牌的卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 检索效果的处理函数，选择一张满足条件的卡加入手牌
function c45836982.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c45836982.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方查看了加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤函数，检查以玩家来看的场上是否存在至少1张满足过滤条件的「地缚神」怪兽
function c45836982.lpfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1021)
end
-- 触发效果的条件函数，判断是否满足触发条件
function c45836982.lpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足触发条件，检查对方基本分不是3000，并且不是自己召唤的怪兽，且有「地缚神」怪兽被召唤
	return Duel.GetLP(1-tp)~=3000 and not eg:IsContains(e:GetHandler()) and eg:IsExists(c45836982.lpfilter,1,nil)
end
-- 触发效果的处理函数，将对方基本分设置为3000
function c45836982.lpop(e,tp,eg,ep,ev,re,r,rp)
	-- 将对方基本分设置为3000
	Duel.SetLP(1-tp,3000)
end
