--妖仙獣 大幽谷響
-- 效果：
-- 「妖仙兽 大幽谷响」的①的效果1回合只能使用1次。
-- ①：对方怪兽的直接攻击宣言时从手卡把「妖仙兽 大幽谷响」以外的1只「妖仙兽」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡的攻击力·守备力直到回合结束时变成和进行战斗的对方怪兽的原本攻击力相同。
-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把1张「妖仙兽」卡加入手卡。
function c69838592.initial_effect(c)
	-- 「妖仙兽 大幽谷响」的①的效果1回合只能使用1次。①：对方怪兽的直接攻击宣言时从手卡把「妖仙兽 大幽谷响」以外的1只「妖仙兽」怪兽送去墓地才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(69838592,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,69838592)
	e1:SetCondition(c69838592.spcon)
	e1:SetCost(c69838592.spcost)
	e1:SetTarget(c69838592.sptg)
	e1:SetOperation(c69838592.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方怪兽进行战斗的伤害步骤开始时才能发动。这张卡的攻击力·守备力直到回合结束时变成和进行战斗的对方怪兽的原本攻击力相同。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(69838592,1))  --"攻守变化"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCondition(c69838592.condition)
	e2:SetOperation(c69838592.operation)
	c:RegisterEffect(e2)
	-- ③：这张卡被战斗破坏送去墓地时才能发动。从卡组把1张「妖仙兽」卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(69838592,2))  --"从卡组把1张「妖仙兽」卡加入手卡"
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DESTROYED)
	e3:SetCondition(c69838592.thcon)
	e3:SetTarget(c69838592.thtg)
	e3:SetOperation(c69838592.thop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件函数：对方怪兽直接攻击宣言时
function c69838592.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 过滤手卡中除「妖仙兽 大幽谷响」以外的「妖仙兽」怪兽，且能作为代价送去墓地
function c69838592.cfilter(c)
	return c:IsSetCard(0xb3) and c:IsType(TYPE_MONSTER) and not c:IsCode(69838592) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价函数：从手卡把1只「妖仙兽」怪兽送去墓地
function c69838592.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张满足过滤条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c69838592.cfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 让玩家选择手卡中1张满足过滤条件的怪兽作为代价送去墓地
	Duel.DiscardHand(tp,c69838592.cfilter,1,1,REASON_COST)
end
-- 效果①的发动准备（Target）函数：检查怪兽区域是否有空位，且自身是否可以特殊召唤
function c69838592.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：特殊召唤自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理（Operation）函数：将自身特殊召唤
function c69838592.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤自身攻守数值不等于对方怪兽原本攻击力的条件（避免无意义发动）
function c69838592.filter(c,tc)
	if c:IsFacedown() then return false end
	return tc:GetBaseAttack()~=c:GetAttack() or tc:GetBaseAttack()~=c:GetDefense()
end
-- 效果②的发动条件函数：伤害步骤开始时，自身与对方怪兽进行战斗，且攻守数值不等于对方原本攻击力
function c69838592.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c:IsRelateToBattle() and bc and c69838592.filter(c,bc) and bc:IsFaceup() and bc:IsRelateToBattle()
end
-- 效果②的效果处理（Operation）函数：将自身的攻击力·守备力直到回合结束时变成和进行战斗的对方怪兽的原本攻击力相同
function c69838592.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if c:IsFaceup() and c:IsRelateToBattle() and bc:IsFaceup() and bc:IsRelateToBattle() then
		-- 这张卡的攻击力·守备力直到回合结束时变成和进行战斗的对方怪兽的原本攻击力相同。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(bc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
		c:RegisterEffect(e2)
	end
end
-- 效果③的发动条件函数：这张卡被战斗破坏送去墓地时
function c69838592.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤卡组中的「妖仙兽」卡片，且能加入手卡
function c69838592.thfilter(c)
	return c:IsSetCard(0xb3) and c:IsAbleToHand()
end
-- 效果③的发动准备（Target）函数：检查卡组中是否存在可检索的「妖仙兽」卡，并设置操作信息
function c69838592.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的「妖仙兽」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c69838592.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理（Operation）函数：从卡组把1张「妖仙兽」卡加入手卡
function c69838592.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送选择要加入手牌的卡的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的「妖仙兽」卡
	local g=Duel.SelectMatchingCard(tp,c69838592.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
