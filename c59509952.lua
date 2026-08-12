--大天使クリスティア
-- 效果：
-- ①：自己墓地的天使族怪兽只有4只的场合，这张卡可以从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1只天使族怪兽为对象发动。那只天使族怪兽加入手卡。
-- ③：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
-- ④：场上的表侧表示的这张卡被送去墓地的场合，不去墓地回到持有者卡组最上面。
function c59509952.initial_effect(c)
	-- ①：自己墓地的天使族怪兽只有4只的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(59509952,0))  --"特殊召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c59509952.spcon)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- ③：只要这张卡在怪兽区域存在，双方不能把怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	c:RegisterEffect(e2)
	-- ④：场上的表侧表示的这张卡被送去墓地的场合，不去墓地回到持有者卡组最上面。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c59509952.recon)
	e3:SetValue(LOCATION_DECK)
	c:RegisterEffect(e3)
	-- ②：这张卡的①的方法特殊召唤成功的场合，以自己墓地1只天使族怪兽为对象发动。那只天使族怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(59509952,1))  --"墓地回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCondition(c59509952.condition)
	e4:SetTarget(c59509952.target)
	e4:SetOperation(c59509952.operation)
	c:RegisterEffect(e4)
end
-- 特殊召唤规则的条件函数：判断自身特殊召唤的条件是否满足
function c59509952.spcon(e,c)
	if c==nil then return true end
	-- 判断自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0 and
		-- 过滤并计算自己墓地中天使族怪兽的数量是否刚好等于4只
		Duel.GetMatchingGroupCount(Card.IsRace,c:GetControler(),LOCATION_GRAVE,0,nil,RACE_FAIRY)==4
end
-- 离场重定向效果的条件函数：判断自身是否在场上表侧表示存在且即将被送去墓地
function c59509952.recon(e)
	local c=e:GetHandler()
	return c:IsFaceup() and c:GetDestination()==LOCATION_GRAVE
end
-- 效果发动的条件函数：判断这张卡是否是通过自身①效果的特殊召唤方式特殊召唤成功
function c59509952.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 过滤函数：筛选自己墓地中可以加入手牌的天使族怪兽
function c59509952.filter(c)
	return c:IsRace(RACE_FAIRY) and c:IsAbleToHand()
end
-- 效果发动的目标选择函数：在发动时选择自己墓地1只天使族怪兽作为效果对象，并设置操作信息
function c59509952.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59509952.filter(chkc) end
	if chk==0 then return true end
	-- 给玩家发送提示信息，提示选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地中1只满足条件的天使族怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c59509952.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置当前连锁的操作信息，表明此效果包含将选定卡片加入手牌的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果的处理函数：将作为对象的天使族怪兽加入手牌并洗牌
function c59509952.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的那张卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_FAIRY) then
		-- 因效果将作为对象的怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 手动洗切加入卡片后的手牌
		Duel.ShuffleHand(tp)
	end
end
