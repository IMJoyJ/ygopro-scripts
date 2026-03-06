--H－C ヤールングレイプ
-- 效果：
-- 战士族1星怪兽×2
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：自己场上的战士族怪兽在1回合各有1次不会被战斗·效果破坏。
-- ②：把这张卡2个超量素材取除，以自己墓地1只等级或者阶级是4的战士族怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的攻击力上升那个原本攻击力数值。
-- ③：对方怪兽进行战斗的攻击宣言时才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
local s,id,o=GetID()
-- 初始化效果函数，设置XYZ召唤手续、效果1（不被战斗·效果破坏）、效果2（特殊召唤墓地4星战士族怪兽并提升攻击力）、效果3（攻击宣言时回复LP）
function c23848752.initial_effect(c)
	-- 为该卡添加XYZ召唤手续，要求使用1星战士族怪兽叠放，最少2只
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),1,2)
	c:EnableReviveLimit()
	-- ①：自己场上的战士族怪兽在1回合各有1次不会被战斗·效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c23848752.indtg)
	e1:SetValue(c23848752.indct)
	c:RegisterEffect(e1)
	-- ②：把这张卡2个超量素材取除，以自己墓地1只等级或者阶级是4的战士族怪兽为对象才能发动。那只怪兽特殊召唤，这张卡的攻击力上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,23848752)
	e2:SetCost(c23848752.spcost)
	e2:SetTarget(c23848752.sptg)
	e2:SetOperation(c23848752.spop)
	c:RegisterEffect(e2)
	-- ③：对方怪兽进行战斗的攻击宣言时才能发动。自己基本分回复那只怪兽的攻击力一半的数值。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_RECOVER)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,23848752+o)
	e3:SetCondition(c23848752.rccon)
	e3:SetOperation(c23848752.rcop)
	c:RegisterEffect(e3)
end
-- 判断目标是否为正面表示的战士族怪兽
function c23848752.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 判断是否为战斗或效果破坏，是则返回1（不被破坏）
function c23848752.indct(e,re,r,rp)
	if bit.band(r,REASON_BATTLE+REASON_EFFECT)~=0 then
		return 1
	else return 0 end
end
-- 支付效果代价，从场上取除2个超量素材
function c23848752.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,2,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,2,2,REASON_COST)
end
-- 过滤满足条件的墓地怪兽：战士族、等级或阶级为4、可特殊召唤
function c23848752.spfilter(c,e,tp)
	return c:IsRace(RACE_WARRIOR) and (c:IsLevel(4) or c:IsRank(4)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 设置效果2的发动条件，检查是否有满足条件的墓地目标
function c23848752.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c23848752.spfilter(chkc,e,tp) end
	-- 检查场上是否有特殊召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否有满足条件的墓地目标
		and Duel.IsExistingTarget(c23848752.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地目标怪兽
	local g=Duel.SelectTarget(tp,c23848752.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，确定特殊召唤目标
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 执行效果2的操作，特殊召唤目标怪兽并提升自身攻击力
function c23848752.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否有特殊召唤空间
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取效果2的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)>0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 提升自身攻击力，数值等于目标怪兽的原本攻击力
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetBaseAttack())
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 判断攻击宣言时对方怪兽是否有效且处于战斗状态
function c23848752.rccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方攻击怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	return tc and tc:IsFaceup() and tc:IsRelateToBattle()
end
-- 执行效果3的操作，回复LP
function c23848752.rcop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方攻击怪兽
	local tc=Duel.GetBattleMonster(1-tp)
	if tc and tc:IsFaceup() and tc:IsRelateToBattle() then
		-- 回复自身LP，数值为对方攻击怪兽攻击力的一半
		Duel.Recover(tp,tc:GetAttack()/2,REASON_EFFECT)
	end
end
