--ベリー・マジシャン・ガール
-- 效果：
-- ①：这张卡召唤成功的场合才能发动。从卡组把1只「魔术少女」怪兽加入手卡。
-- ②：1回合1次，这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡的表示形式变更，从卡组把「浆果魔术少女」以外的1只「魔术少女」怪兽特殊召唤。
function c20747792.initial_effect(c)
	-- ①：这张卡召唤成功的场合才能发动。从卡组把1只「魔术少女」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(20747792,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c20747792.thtg)
	e1:SetOperation(c20747792.thop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，这张卡成为对方的效果的对象时或者被选择作为对方怪兽的攻击对象时才能发动。这张卡的表示形式变更，从卡组把「浆果魔术少女」以外的1只「魔术少女」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(20747792,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_BECOME_TARGET)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_SINGLE)
	e2:SetCondition(c20747792.spcon1)
	e2:SetTarget(c20747792.sptg)
	e2:SetOperation(c20747792.spop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(20747792,2))
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c20747792.spcon2)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「魔术少女」怪兽（类型为怪兽且能加入手牌）
function c20747792.thfilter(c)
	return c:IsSetCard(0x20a2) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 设置效果处理时要检索的卡组中的「魔术少女」怪兽
function c20747792.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在满足条件的「魔术少女」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c20747792.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时要检索的卡组中的「魔术少女」怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 处理效果：选择并加入手牌
function c20747792.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的「魔术少女」怪兽
	local g=Duel.SelectMatchingCard(tp,c20747792.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 检索满足条件的「魔术少女」怪兽（不包括自己且能特殊召唤）
function c20747792.spfilter(c,e,tp)
	return c:IsSetCard(0x20a2) and not c:IsCode(20747792) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否成为对方效果的对象
function c20747792.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsContains(e:GetHandler()) and rp==1-tp
end
-- 判断是否被对方怪兽攻击
function c20747792.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否被对方怪兽攻击
	return eg:IsContains(e:GetHandler()) and Duel.GetAttacker():IsControler(1-tp)
end
-- 设置效果处理时要特殊召唤的卡组中的「魔术少女」怪兽
function c20747792.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的「魔术少女」怪兽
		and Duel.IsExistingMatchingCard(c20747792.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果处理时要特殊召唤的卡组中的「魔术少女」怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	-- 设置效果处理时要改变表示形式的卡
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetHandler(),1,0,0)
end
-- 处理效果：改变表示形式并特殊召唤
function c20747792.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡是否有效且能改变表示形式
	if not c:IsRelateToEffect(e) or Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)==0 then return end
	-- 检查场上是否有空位
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的「魔术少女」怪兽
	local g=Duel.SelectMatchingCard(tp,c20747792.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的卡特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
