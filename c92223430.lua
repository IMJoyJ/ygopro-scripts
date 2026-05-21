--神鳥の霊峰エルブルズ
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：场上的鸟兽族·风属性怪兽的攻击力·守备力上升300。
-- ②：把手卡的5星以上的鸟兽族·风属性怪兽给对方观看才能发动。这个回合，自己可以把鸟兽族怪兽召唤的场合需要的解放减少1只。
-- ③：自己场上有鸟兽族·风属性怪兽存在的场合才能发动。把1只鸟兽族怪兽召唤。
function c92223430.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：场上的鸟兽族·风属性怪兽的攻击力·守备力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e2:SetTarget(c92223430.atktg)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	local e5=e2:Clone()
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e5)
	-- ②：把手卡的5星以上的鸟兽族·风属性怪兽给对方观看才能发动。这个回合，自己可以把鸟兽族怪兽召唤的场合需要的解放减少1只。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92223430,0))  --"减少解放数量"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1,92223430)
	e3:SetCost(c92223430.trcost)
	e3:SetOperation(c92223430.trop)
	c:RegisterEffect(e3)
	-- ③：自己场上有鸟兽族·风属性怪兽存在的场合才能发动。把1只鸟兽族怪兽召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(92223430,1))  --"把1只怪兽召唤"
	e4:SetCategory(CATEGORY_SUMMON)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1,92223431)
	e4:SetCondition(c92223430.sumcon)
	e4:SetTarget(c92223430.sumtg)
	e4:SetOperation(c92223430.sumop)
	c:RegisterEffect(e4)
end
-- 过滤场上鸟兽族·风属性怪兽作为攻击力/守备力上升效果的对象
function c92223430.atktg(e,c)
	return c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 过滤手卡中5星以上的鸟兽族·风属性且未给对方观看的怪兽
function c92223430.costfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND) and not c:IsPublic()
end
-- 效果②的Cost：展示手卡1只5星以上的鸟兽族·风属性怪兽
function c92223430.trcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡是否存在满足条件的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92223430.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 玩家选择手卡1只满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92223430.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 给对方玩家确认选中的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 洗切手卡
	Duel.ShuffleHand(tp)
end
-- 效果②的效果处理：注册一个本回合内自己召唤鸟兽族怪兽时减少1只解放的全局效果
function c92223430.trop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 这个回合，自己可以把鸟兽族怪兽召唤的场合需要的解放减少1只。③：自己场上有鸟兽族·风属性怪兽存在的场合才能发动。把1只鸟兽族怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_DECREASE_TRIBUTE)
	e1:SetTargetRange(LOCATION_HAND,0)
	-- 设置减少解放效果的对象为鸟兽族怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_WINDBEAST))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该减少解放的效果
	Duel.RegisterEffect(e1,tp)
end
-- 过滤自己场上表侧表示的鸟兽族·风属性怪兽
function c92223430.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WINDBEAST) and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果③的发动条件：自己场上有鸟兽族·风属性怪兽存在
function c92223430.sumcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在表侧表示的鸟兽族·风属性怪兽
	return Duel.IsExistingMatchingCard(c92223430.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤可以进行通常召唤的鸟兽族怪兽
function c92223430.sumfilter(c)
	return c:IsRace(RACE_WINDBEAST) and c:IsSummonable(true,nil)
end
-- 效果③的发动准备：检查手卡或场上是否存在可召唤的鸟兽族怪兽，并设置召唤的操作信息
function c92223430.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡或场上是否存在可召唤的鸟兽族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92223430.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil) end
	-- 设置连锁处理中的操作信息为召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
end
-- 效果③的效果处理：选择手卡或场上1只鸟兽族怪兽进行通常召唤
function c92223430.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
	-- 玩家选择手卡或场上1只可召唤的鸟兽族怪兽
	local g=Duel.SelectMatchingCard(tp,c92223430.sumfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家对选中的怪兽进行通常召唤（无视每回合召唤次数限制）
		Duel.Summon(tp,tc,true,nil)
	end
end
