--Aiドリング・ボーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
-- ②：怪兽之间进行战斗的攻击宣言时，把墓地的这张卡和1张手卡除外，从自己墓地的卡以及除外的自己的卡之中以「“艾”闲者苏生」以外的1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c22933016.initial_effect(c)
	-- 效果原文内容：①：以自己墓地1只「@火灵天星」怪兽为对象才能发动。那只怪兽特殊召唤。这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,22933016)
	e1:SetTarget(c22933016.target)
	e1:SetOperation(c22933016.activate)
	c:RegisterEffect(e1)
	-- 效果原文内容：②：怪兽之间进行战斗的攻击宣言时，把墓地的这张卡和1张手卡除外，从自己墓地的卡以及除外的自己的卡之中以「“艾”闲者苏生」以外的1张「“艾”」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22933016,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,22933017)
	e2:SetCondition(c22933016.thcon)
	e2:SetCost(c22933016.thcost)
	e2:SetTarget(c22933016.thtg)
	e2:SetOperation(c22933016.thop)
	c:RegisterEffect(e2)
end
-- 规则层面作用：过滤满足条件的怪兽（火灵天星族且可特殊召唤）
function c22933016.filter(c,e,tp)
	return c:IsSetCard(0x135) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 规则层面作用：判断是否满足特殊召唤的条件（场上是否有空位，墓地是否有符合条件的怪兽）
function c22933016.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c22933016.filter(chkc,e,tp) end
	-- 规则层面作用：判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 规则层面作用：判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c22933016.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 规则层面作用：提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 规则层面作用：选择目标怪兽
	local g=Duel.SelectTarget(tp,c22933016.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 规则层面作用：设置操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 规则层面作用：处理特殊召唤效果并设置后续限制效果
function c22933016.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) then
		-- 效果原文内容：这张卡的发动后，直到回合结束时自己不是电子界族怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(c22933016.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 规则层面作用：注册限制效果，禁止玩家在本回合特殊召唤非电子界族怪兽
		Duel.RegisterEffect(e1,tp)
	end
end
-- 规则层面作用：限制效果的目标函数，禁止电子界族怪兽特殊召唤
function c22933016.splimit(e,c)
	return not c:IsRace(RACE_CYBERSE)
end
-- 效果原文内容：怪兽之间进行战斗的攻击宣言时
function c22933016.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：判断是否处于攻击宣言阶段
	return Duel.GetAttacker() and Duel.GetAttackTarget()
end
-- 效果原文内容：把墓地的这张卡和1张手卡除外
function c22933016.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 规则层面作用：判断手牌中是否存在可除外的卡
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,nil) end
	-- 规则层面作用：提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 规则层面作用：选择手牌中要除外的卡
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,nil)
	g:AddCard(c)
	-- 规则层面作用：将选中的卡除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 规则层面作用：过滤满足条件的魔法陷阱卡（艾系列且非自身）
function c22933016.thfilter(c)
	return (c:IsLocation(LOCATION_GRAVE) or c:IsFaceup()) and c:IsSetCard(0x136) and c:IsType(TYPE_SPELL+TYPE_TRAP) and not c:IsCode(22933016) and c:IsAbleToHand()
end
-- 规则层面作用：判断是否满足效果发动条件（墓地或除外区是否存在符合条件的魔法陷阱卡）
function c22933016.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE+LOCATION_REMOVED) and chkc:IsControler(tp) and c22933016.thfilter(chkc) end
	-- 规则层面作用：判断是否存在符合条件的魔法陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c22933016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,e:GetHandler()) end
	-- 规则层面作用：提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 规则层面作用：选择目标魔法陷阱卡
	local g=Duel.SelectTarget(tp,c22933016.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,e:GetHandler())
	-- 规则层面作用：设置操作信息，表示将要将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 规则层面作用：处理效果，将目标卡加入手牌
function c22933016.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面作用：获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 规则层面作用：将目标卡送入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
