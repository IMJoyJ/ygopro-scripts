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
	-- 设置永续效果的影响对象为场上的岩石族怪兽
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
-- 定义过滤函数：检查卡片是否为自己场上表侧表示的「三形金字塔」怪兽
function c72772445.actfilter(c,tp)
	return c and c:IsFaceup() and c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- 定义封锁效果的发动条件：进行战斗的攻击怪兽或被攻击怪兽是自己场上的「三形金字塔」怪兽
function c72772445.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 检查当前战斗的攻击怪兽或被攻击怪兽是否满足自己场上表侧表示的「三形金字塔」怪兽的条件
	return c72772445.actfilter(Duel.GetAttacker(),tp) or c72772445.actfilter(Duel.GetAttackTarget(),tp)
end
-- 定义特殊召唤效果的发动条件：此卡在送去墓地前必须在场地区域表侧表示存在
function c72772445.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 定义过滤函数：检查手牌中是否存在可以特殊召唤的「三形金字塔」怪兽
function c72772445.spfilter(c,e,tp)
	-- 判断卡片是否为「三形金字塔」怪兽，且在当前状态下是否可以特殊召唤（根据是否为特殊召唤怪兽动态决定是否忽略召唤条件）
	return c:IsSetCard(0xe2) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c))
end
-- 定义特殊召唤效果的发动准备：在发动时检查自己场上是否有空余怪兽区域，且手牌中是否存在可特殊召唤的「三形金字塔」怪兽
function c72772445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，首先检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查手牌中是否存在至少1只满足特殊召唤条件的「三形金字塔」怪兽
		and Duel.IsExistingMatchingCard(c72772445.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向系统注册连锁操作信息，表明此效果包含从手牌特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义特殊召唤效果的执行逻辑：在怪兽区域有空位时，让玩家从手牌选择1只「三形金字塔」怪兽特殊召唤，若特召的是特殊召唤怪兽则完成正规召唤程序
function c72772445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 在效果处理时，如果自己场上已经没有可用的怪兽区域，则不进行处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手牌中选择1只满足特殊召唤条件的「三形金字塔」怪兽
	local g=Duel.SelectMatchingCard(tp,c72772445.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 将选择的怪兽以表侧表示特殊召唤（根据是否为特殊召唤怪兽决定是否忽略召唤条件），若特召成功且该怪兽为特殊召唤怪兽，则准备执行后续的正规召唤程序
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.TriamidSpSummonType(sc),POS_FACEUP) and aux.TriamidSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
