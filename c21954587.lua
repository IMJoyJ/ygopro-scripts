--水精鱗－メガロアビス
-- 效果：
-- ①：从手卡把这张卡以外的2只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1张「深渊」魔法·陷阱卡加入手卡。
-- ③：把这张卡以外的自己场上1只表侧攻击表示的水属性怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
function c21954587.initial_effect(c)
	-- ①：从手卡把这张卡以外的2只水属性怪兽丢弃去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21954587,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c21954587.spcost)
	e1:SetTarget(c21954587.sptg)
	e1:SetOperation(c21954587.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡的①的效果特殊召唤成功时才能发动。从卡组把1张「深渊」魔法·陷阱卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21954587,1))  --"检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c21954587.thcon)
	e2:SetTarget(c21954587.thtg)
	e2:SetOperation(c21954587.thop)
	c:RegisterEffect(e2)
	-- ③：把这张卡以外的自己场上1只表侧攻击表示的水属性怪兽解放才能发动。这个回合，这张卡在同1次的战斗阶段中可以作2次攻击。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(21954587,2))  --"两次攻击"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c21954587.atkcon)
	e3:SetCost(c21954587.atkcost)
	e3:SetTarget(c21954587.atktg)
	e3:SetOperation(c21954587.atkop)
	c:RegisterEffect(e3)
end
-- 用于筛选手卡中满足水属性、可丢弃、可送入墓地的怪兽
function c21954587.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
-- 检查手卡中是否存在至少2张满足条件的水属性怪兽，并执行丢弃操作
function c21954587.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少2张满足条件的水属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c21954587.cfilter,tp,LOCATION_HAND,0,2,e:GetHandler()) end
	-- 从手卡丢弃2张满足条件的水属性怪兽
	Duel.DiscardHand(tp,c21954587.cfilter,2,2,REASON_COST+REASON_DISCARD,e:GetHandler())
end
-- 检查特殊召唤的条件是否满足
function c21954587.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有可用怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作
function c21954587.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该卡特殊召唤到场上
	Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,false,false,POS_FACEUP)
end
-- 判断该卡是否为通过①效果特殊召唤成功
function c21954587.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 用于筛选卡组中满足「深渊」字段、魔法或陷阱类型的卡
function c21954587.thfilter(c)
	return c:IsSetCard(0x75) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 检查卡组中是否存在至少1张满足条件的「深渊」魔法或陷阱卡
function c21954587.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的「深渊」魔法或陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c21954587.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的连锁操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索并加入手牌的操作
function c21954587.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张满足条件的「深渊」魔法或陷阱卡
	local g=Duel.SelectMatchingCard(tp,c21954587.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断是否可以进入战斗阶段
function c21954587.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否可以进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 用于筛选自己场上满足表侧攻击表示、水属性的怪兽
function c21954587.rfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK) and c:IsAttribute(ATTRIBUTE_WATER)
end
-- 检查场上是否存在满足条件的水属性怪兽，并执行解放操作
function c21954587.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在满足条件的水属性怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c21954587.rfilter,1,e:GetHandler()) end
	-- 从场上选择1张满足条件的水属性怪兽进行解放
	local g=Duel.SelectReleaseGroup(tp,c21954587.rfilter,1,1,e:GetHandler())
	-- 将选中的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 检查是否可以发动该效果
function c21954587.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetEffectCount(EFFECT_EXTRA_ATTACK)==0 end
end
-- 设置该卡在本回合可进行2次攻击的效果
function c21954587.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 设置该卡在本回合可进行2次攻击的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EXTRA_ATTACK)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
