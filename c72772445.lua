--トラミッド・キングゴレム
-- 效果：
-- 「三形金字塔·巨人王」的③的效果1回合只能使用1次。
-- ①：场上的岩石族怪兽的攻击力上升500。
-- ②：自己的「三形金字塔」怪兽进行战斗的场合，直到伤害步骤结束时对方不能把魔法·陷阱·怪兽的效果发动。
-- ③：场地区域的表侧表示的这张卡被送去墓地的场合才能发动。从手卡把1只「三形金字塔」怪兽特殊召唤。
function c72772445.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的岩石族怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果的过滤条件为岩石族怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_ROCK))
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- ②：自己的「三形金字塔」怪兽进行战斗的场合，直到伤害步骤结束时对方不能把魔法·陷阱·怪兽的效果发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(0,1)
	e3:SetValue(1)
	e3:SetCondition(c72772445.actcon)
	c:RegisterEffect(e3)
	-- ③：场地区域的表侧表示的这张卡被送去墓地的场合才能发动。从手卡把1只「三形金字塔」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCountLimit(1,72772445)
	e4:SetCondition(c72772445.spcon)
	e4:SetTarget(c72772445.sptg)
	e4:SetOperation(c72772445.spop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「三形金字塔」怪兽
function c72772445.actfilter(c,tp)
	return c and c:IsFaceup() and c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- 判断进行战斗的怪兽是否是自己的「三形金字塔」怪兽
function c72772445.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 如果攻击怪兽或者被攻击怪兽是自己的「三形金字塔」怪兽则符合条件
	return c72772445.actfilter(Duel.GetAttacker(),tp) or c72772445.actfilter(Duel.GetAttackTarget(),tp)
end
-- 判断此卡先前是否在场地区域表侧表示存在
function c72772445.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 过滤手卡中可以特殊召唤的「三形金字塔」怪兽
function c72772445.spfilter(c,e,tp)
	-- 检查卡片是否是「三形金字塔」怪兽，以及是否可以特殊召唤
	return c:IsSetCard(0xe2) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c))
end
-- 特殊召唤效果的发动条件检测，判断怪兽区是否有空位以及手卡是否有可召唤的「三形金字塔」怪兽
function c72772445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 若为检测阶段，则首先判断己方主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且检查手牌中是否存在可以特殊召唤的「三形金字塔」怪兽
		and Duel.IsExistingMatchingCard(c72772445.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理的分类为从手牌特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果处理，若怪兽区有空位，则让玩家选择手牌中的「三形金字塔」怪兽并将其特殊召唤
function c72772445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若主要怪兽区没有空位，则效果不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要进行特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从玩家手牌中选择1只满足特殊召唤条件的「三形金字塔」怪兽
	local g=Duel.SelectMatchingCard(tp,c72772445.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 如果特殊召唤成功，并且是具有特殊特殊召唤限制的怪兽，则完成其正规召唤程序
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.TriamidSpSummonType(sc),POS_FACEUP)>0 and aux.TriamidSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
