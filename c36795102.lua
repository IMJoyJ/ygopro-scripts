--究極宝玉獣 レインボー・ドラゴン
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：「宝玉兽」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
-- ③：把当作永续魔法卡使用的这张卡除外才能发动。从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤，从卡组把1只「究极宝玉神」怪兽加入手卡。
function c36795102.initial_effect(c)
	-- ①：「宝玉兽」怪兽进行战斗的攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36795102,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,36795102)
	e1:SetCondition(c36795102.spcon1)
	e1:SetTarget(c36795102.sptg1)
	e1:SetOperation(c36795102.spop1)
	c:RegisterEffect(e1)
	-- ②：表侧表示的这张卡在怪兽区域被破坏的场合，可以不送去墓地当作永续魔法卡使用在自己的魔法与陷阱区域表侧表示放置。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_TO_GRAVE_REDIRECT_CB)
	e2:SetCondition(c36795102.repcon)
	e2:SetOperation(c36795102.repop)
	c:RegisterEffect(e2)
	-- ③：把当作永续魔法卡使用的这张卡除外才能发动。从卡组把1只4星以下的「宝玉兽」怪兽效果无效特殊召唤，从卡组把1只「究极宝玉神」怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(36795102,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,36795103)
	e3:SetCondition(c36795102.spcon2)
	-- 将这张卡除外作为cost
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(c36795102.sptg2)
	e3:SetOperation(c36795102.spop2)
	c:RegisterEffect(e3)
end
-- 判断目标是否为表侧表示的宝玉兽族怪兽
function c36795102.cfilter(c)
	return c and c:IsFaceup() and c:IsSetCard(0x1034)
end
-- 判断攻击怪兽或被攻击怪兽是否为宝玉兽族
function c36795102.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判断攻击怪兽或被攻击怪兽是否为宝玉兽族
	return c36795102.cfilter(Duel.GetAttacker()) or c36795102.cfilter(Duel.GetAttackTarget())
end
-- 判断是否满足特殊召唤条件
function c36795102.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的卡为处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c36795102.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断是否满足替换效果条件
function c36795102.repcon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:IsLocation(LOCATION_MZONE) and c:IsReason(REASON_DESTROY)
end
-- 将卡变为永续魔法卡
function c36795102.repop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 将卡变为永续魔法卡
	local e1=Effect.CreateEffect(c)
	e1:SetCode(EFFECT_CHANGE_TYPE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(TYPE_SPELL+TYPE_CONTINUOUS)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
	c:RegisterEffect(e1)
end
-- 判断是否为永续魔法卡状态
function c36795102.spcon2(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetType()==TYPE_CONTINUOUS+TYPE_SPELL
end
-- 筛选满足条件的宝玉兽怪兽
function c36795102.spfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x1034) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 确保卡组中存在可以加入手牌的究极宝玉神怪兽
		and Duel.IsExistingMatchingCard(c36795102.thfilter,tp,LOCATION_DECK,0,1,c)
end
-- 筛选可以加入手牌的究极宝玉神怪兽
function c36795102.thfilter(c)
	return c:IsSetCard(0x2034) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 判断是否满足发动条件
function c36795102.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的宝玉兽怪兽
		and Duel.IsExistingMatchingCard(c36795102.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置特殊召唤的卡为处理对象
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置加入手牌的卡为处理对象
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行效果处理
function c36795102.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的宝玉兽怪兽
	local g1=Duel.SelectMatchingCard(tp,c36795102.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g1:GetFirst()
	-- 执行特殊召唤步骤
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local c=e:GetHandler()
		-- 使特殊召唤的怪兽无效化
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 使特殊召唤的怪兽效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
		-- 提示选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 选择满足条件的究极宝玉神怪兽
		local g2=Duel.SelectMatchingCard(tp,c36795102.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g2:GetCount()>0 then
			-- 将卡加入手牌
			Duel.SendtoHand(g2,tp,REASON_EFFECT)
			-- 确认对方手牌
			Duel.ConfirmCards(1-tp,g2)
		end
	end
end
