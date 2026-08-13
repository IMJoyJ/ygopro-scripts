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
	-- 把攻击力上升效果的作用对象限定为双方场上的岩石族怪兽
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
	-- ③：场地区域的表侧表示的这张卡被送去墓地的场合才能发动。从手卡把1只「三形金字塔」怪兽特殊召唤。「三形金字塔·巨人王」的③的效果1回合只能使用1次。
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
-- 过滤函数：判断卡片是否为自己场上表侧表示的「三形金字塔」怪兽
function c72772445.actfilter(c,tp)
	return c and c:IsFaceup() and c:IsSetCard(0xe2) and c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- 封印效果的适用条件：判定进行战斗的攻击方或攻击对象是否为自己的「三形金字塔」怪兽
function c72772445.actcon(e)
	local tp=e:GetHandlerPlayer()
	-- 攻击宣言的怪兽或被选为攻击对象的怪兽中只要有一方是自己的「三形金字塔」怪兽，封印条件即成立
	return c72772445.actfilter(Duel.GetAttacker(),tp) or c72772445.actfilter(Duel.GetAttackTarget(),tp)
end
-- 发动条件：这张卡是从场地区域以表侧表示被送去墓地的场合
function c72772445.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_FZONE) and c:IsPreviousPosition(POS_FACEUP)
end
-- 特殊召唤候选过滤函数：手卡中可以被特殊召唤的「三形金字塔」怪兽
function c72772445.spfilter(c,e,tp)
	-- 判定该卡是「三形金字塔」怪兽，并且按其是否为特殊召唤怪兽的种类判断能否被特殊召唤
	return c:IsSetCard(0xe2) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.TriamidSpSummonType(c))
end
-- 对象检测：自己主要怪兽区有空位，且手卡存在可以特殊召唤的「三形金字塔」怪兽
function c72772445.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区还有可用的空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且确认自己手卡至少存在1只满足特殊召唤条件的「三形金字塔」怪兽
		and Duel.IsExistingMatchingCard(c72772445.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息：宣告将从手卡特殊召唤1只怪兽，用于其他卡的效果发动检测
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：从手卡选1只「三形金字塔」怪兽特殊召唤，若其为特殊召唤怪兽则完成正规召唤手续
function c72772445.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己主要怪兽区已没有空位则中断处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家显示「请选择要特殊召唤的卡」的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让自己从手卡选择1只满足条件的「三形金字塔」怪兽
	local g=Duel.SelectMatchingCard(tp,c72772445.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		local sc=g:GetFirst()
		-- 将选中的怪兽以表侧表示特殊召唤到自己场上，特殊召唤成功且该卡属于特殊召唤怪兽时执行CompleteProcedure完成正规出场手续
		if Duel.SpecialSummon(g,0,tp,tp,false,aux.TriamidSpSummonType(sc),POS_FACEUP)>0 and aux.TriamidSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
