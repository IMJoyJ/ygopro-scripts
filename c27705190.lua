--星遺物の交心
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：自己场上有「机怪虫」怪兽存在，对方怪兽的效果发动时才能发动。那个效果变成「选对方场上1只表侧表示怪兽回到持有者手卡」。
-- ②：把墓地的这张卡除外，以场上1只连接怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「机怪虫」怪兽在作为成为对象的怪兽所连接区的自己场上里侧守备表示特殊召唤。
function c27705190.initial_effect(c)
	-- ①：自己场上有「机怪虫」怪兽存在，对方怪兽的效果发动时才能发动。那个效果变成「选对方场上1只表侧表示怪兽回到持有者手卡」。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(27705190,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,27705190)
	e1:SetCondition(c27705190.cecondition)
	e1:SetTarget(c27705190.cetarget)
	e1:SetOperation(c27705190.ceoperation)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，以场上1只连接怪兽为对象才能发动。从自己的手卡·卡组·墓地选1只「机怪虫」怪兽在作为成为对象的怪兽所连接区的自己场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(27705190,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,27705190)
	-- 将此卡除外作为cost
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c27705190.sptarget)
	e2:SetOperation(c27705190.spoperation)
	c:RegisterEffect(e2)
end
-- 将连锁对象改为对方场上1只表侧表示怪兽并将其送回持有者手卡
function c27705190.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择对方场上1只表侧表示怪兽
	local sg=Duel.SelectMatchingCard(tp,c27705190.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	if sg:GetCount()>0 then
		-- 将选择的怪兽送回持有者手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
-- 过滤条件：场上存在表侧表示的「机怪虫」怪兽
function c27705190.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x104)
end
-- 效果发动条件：对方怪兽效果发动且自己场上有「机怪虫」怪兽
function c27705190.cecondition(e,tp,eg,ep,ev,re,r,rp)
	-- 对方怪兽效果发动且自己场上有「机怪虫」怪兽
	return ep~=tp and re:IsActiveType(TYPE_MONSTER) and Duel.IsExistingMatchingCard(c27705190.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：场上表侧表示且能送回手卡的怪兽
function c27705190.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand()
end
-- 效果发动时的处理：确认对方场上是否存在表侧表示怪兽
function c27705190.cetarget(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认对方场上是否存在表侧表示怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c27705190.thfilter,rp,0,LOCATION_MZONE,1,nil) end
end
-- 效果处理：将连锁效果改为将对方怪兽送回手卡
function c27705190.ceoperation(e,tp,eg,ep,ev,re,r,rp)
	local g=Group.CreateGroup()
	-- 将连锁对象改为无对象
	Duel.ChangeTargetCard(ev,g)
	-- 将连锁处理改为将对方怪兽送回手卡
	Duel.ChangeChainOperation(ev,c27705190.repop)
end
-- 过滤条件：场上表侧表示的连接怪兽且其连接区存在可特殊召唤的「机怪虫」怪兽
function c27705190.spfilter1(c,e,tp)
	local zone=bit.band(c:GetLinkedZone(tp),0x1f)
	-- 场上表侧表示的连接怪兽且其连接区存在可特殊召唤的「机怪虫」怪兽
	return c:IsFaceup() and c:IsType(TYPE_LINK) and zone>0 and Duel.IsExistingMatchingCard(c27705190.spfilter2,tp,0x13,0,1,c,e,tp,zone)
end
-- 过滤条件：「机怪虫」怪兽且能里侧守备表示特殊召唤
function c27705190.spfilter2(c,e,tp,zone)
	return c:IsSetCard(0x104) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,tp,zone)
end
-- 效果发动时的处理：选择对象并设置操作信息
function c27705190.sptarget(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return c27705190.spfilter1(chkc,e,tp) and chkc:IsLocation(LOCATION_MZONE) end
	-- 确认自己场上是否存在满足条件的连接怪兽
	if chk==0 then return Duel.IsExistingTarget(c27705190.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	-- 提示玩家选择效果对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只满足条件的连接怪兽作为对象
	Duel.SelectTarget(tp,c27705190.spfilter1,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	-- 设置操作信息：准备特殊召唤1只「机怪虫」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x13)
end
-- 效果处理：选择并特殊召唤「机怪虫」怪兽
function c27705190.spoperation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组·墓地选择1只「机怪虫」怪兽
		local sg=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c27705190.spfilter2),tp,0x13,0,1,1,c,e,tp,zone)
		if sg:GetCount()>0 then
			-- 将选择的「机怪虫」怪兽特殊召唤到对象怪兽的连接区
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE,zone)
			-- 向对方确认特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
