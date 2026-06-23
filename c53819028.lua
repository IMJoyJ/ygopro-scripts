--捕食植物セラセニアント
-- 效果：
-- 「捕食植物 瓶子草蚁」的③的效果1回合只能使用1次。
-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
-- ③：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把「捕食植物 瓶子草蚁」以外的1张「捕食」卡加入手卡。
function c53819028.initial_effect(c)
	-- ①：对方怪兽的直接攻击宣言时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(53819028,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c53819028.spcon)
	e1:SetTarget(c53819028.sptg)
	e1:SetOperation(c53819028.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害计算后才能发动。那只对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(53819028,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLED)
	e2:SetTarget(c53819028.destg)
	e2:SetOperation(c53819028.desop)
	c:RegisterEffect(e2)
	-- ③：场上的这张卡被效果送去墓地的场合或者被战斗破坏的场合才能发动。从卡组把「捕食植物 瓶子草蚁」以外的1张「捕食」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(53819028,2))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCountLimit(1,53819028)
	e3:SetTarget(c53819028.thtg)
	e3:SetOperation(c53819028.thop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c53819028.thcon)
	c:RegisterEffect(e4)
end
-- 判断是否为对方怪兽的直接攻击宣言
function c53819028.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 攻击怪兽控制者不是自己且攻击目标为空
	return Duel.GetAttacker():GetControler()~=tp and Duel.GetAttackTarget()==nil
end
-- 判断是否满足特殊召唤条件
function c53819028.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤操作
function c53819028.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将卡片特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 设置破坏效果的目标
function c53819028.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则获取攻击目标
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if chk==0 then return tc and tc:IsRelateToBattle() end
	-- 设置破坏的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
end
-- 执行破坏操作
function c53819028.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是自身，则获取攻击目标
	if tc==e:GetHandler() then tc=Duel.GetAttackTarget() end
	if tc:IsRelateToBattle() and tc:IsControler(1-tp) then
		-- 将目标怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 判断是否为战斗破坏或效果送去墓地
function c53819028.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤满足条件的「捕食」卡
function c53819028.thfilter(c)
	return c:IsSetCard(0xf3) and c:IsAbleToHand() and not c:IsCode(53819028)
end
-- 设置检索操作信息
function c53819028.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断卡组中是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c53819028.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置检索的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索操作
function c53819028.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,c53819028.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到被加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
