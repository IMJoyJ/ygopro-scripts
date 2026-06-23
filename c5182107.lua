--超重武者ドウC－N
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只机械族灵摆怪兽加入手卡。
-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。除「超重武者 同心C-N」外的1只攻击力1500以下的机械族·地属性怪兽从自己的手卡·墓地特殊召唤。
function c5182107.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从自己的额外卡组（表侧）把1只机械族灵摆怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(5182107,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,5182107)
	e1:SetTarget(c5182107.thtg)
	e1:SetOperation(c5182107.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：自己墓地没有魔法·陷阱卡存在的场合，把这张卡解放才能发动。除「超重武者 同心C-N」外的1只攻击力1500以下的机械族·地属性怪兽从自己的手卡·墓地特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(5182107,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,5182108)
	e3:SetCondition(c5182107.spcon)
	e3:SetCost(c5182107.spcost)
	e3:SetTarget(c5182107.sptg)
	e3:SetOperation(c5182107.spop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的机械族灵摆怪兽（表侧）
function c5182107.thfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_PENDULUM) and c:IsAbleToHand()
end
-- 判断是否能发动效果①，即在额外卡组中是否存在满足条件的机械族灵摆怪兽
function c5182107.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能发动效果①，即在额外卡组中是否存在满足条件的机械族灵摆怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5182107.thfilter,tp,LOCATION_EXTRA,0,1,nil) end
	-- 设置连锁操作信息为将1张满足条件的灵摆怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_EXTRA)
end
-- 处理效果①的发动，选择并把符合条件的灵摆怪兽加入手牌
function c5182107.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从额外卡组中选择1只满足条件的机械族灵摆怪兽
	local g=Duel.SelectMatchingCard(tp,c5182107.thfilter,tp,LOCATION_EXTRA,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的灵摆怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
end
-- 判断是否能发动效果②，即自己墓地没有魔法·陷阱卡存在
function c5182107.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否能发动效果②，即自己墓地没有魔法·陷阱卡存在
	return not Duel.IsExistingMatchingCard(Card.IsType,tp,LOCATION_GRAVE,0,1,nil,TYPE_SPELL+TYPE_TRAP)
end
-- 处理效果②的发动，支付解放费用
function c5182107.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足发动条件：自身可被解放且场上存在可用怪兽区
	if chk==0 then return c:IsReleasable() and Duel.GetMZoneCount(tp,c)>0 end
	-- 将自身解放作为发动效果②的代价
	Duel.Release(c,REASON_COST)
end
-- 筛选满足条件的机械族·地属性怪兽（攻击力≤1500，非同心C-N）
function c5182107.spfilter(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsRace(RACE_MACHINE) and c:IsAttribute(ATTRIBUTE_EARTH)
		and not c:IsCode(5182107) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否能发动效果②，即在手卡或墓地中是否存在满足条件的怪兽
function c5182107.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否能发动效果②，即在手卡或墓地中是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5182107.spfilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁操作信息为特殊召唤1只满足条件的怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
end
-- 处理效果②的发动，选择并特殊召唤满足条件的怪兽
function c5182107.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否存在可用怪兽区
	if Duel.GetMZoneCount(tp)>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡或墓地中选择1只满足条件的机械族·地属性怪兽
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c5182107.spfilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
