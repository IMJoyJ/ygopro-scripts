--エンジェルO1
-- 效果：
-- 这个卡名的①的方法的特殊召唤1回合只能有1次。
-- ①：这张卡可以把手卡1只7星以上的怪兽给对方观看，从手卡特殊召唤。
-- ②：只要特殊召唤的这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
function c82243738.initial_effect(c)
	-- 这个卡名的①的方法的特殊召唤1回合只能有1次。①：这张卡可以把手卡1只7星以上的怪兽给对方观看，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82243738,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,82243738+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c82243738.spcon)
	e1:SetTarget(c82243738.sptg)
	e1:SetOperation(c82243738.spop)
	c:RegisterEffect(e1)
	-- ②：只要特殊召唤的这张卡在怪兽区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只7星以上的怪兽表侧攻击表示上级召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(82243738,1))  --"使用「天使O1」的效果上级召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	-- 设置增加召唤次数效果的目标为等级7以上的怪兽
	e2:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,7))
	e2:SetCondition(c82243738.trcon)
	e2:SetValue(0x1)
	c:RegisterEffect(e2)
end
-- 过滤条件：等级7以上、怪兽卡、且未处于公开状态
function c82243738.spfilter(c)
	return c:IsLevelAbove(7) and c:IsType(TYPE_MONSTER) and not c:IsPublic()
end
-- 特殊召唤规则的条件：怪兽区域有空位且手卡有可展示的等级7以上怪兽
function c82243738.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查我方主要怪兽区域是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在满足条件的等级7以上怪兽
		and Duel.IsExistingMatchingCard(c82243738.spfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 特殊召唤规则的Target函数：选择手卡中1只等级7以上的怪兽作为展示对象
function c82243738.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中所有满足条件的等级7以上怪兽
	local g=Duel.GetMatchingGroup(c82243738.spfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的Operation函数：将选中的怪兽给对方确认并洗切手卡
function c82243738.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	-- 洗切我方手卡
	Duel.ShuffleHand(tp)
end
-- 增加召唤次数效果的启用条件：这张卡是特殊召唤的
function c82243738.trcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SPECIAL)
end
