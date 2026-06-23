--剣闘獣の檻－コロッセウム
-- 效果：
-- 每次怪兽从卡组在场上特殊召唤，给这张卡放置1个指示物。场上表侧表示存在的名字带有「剑斗兽」的怪兽，这张卡每放置有1个指示物，攻击力·守备力上升100。这张卡被卡的效果破坏时，可以从手卡丢弃1张「剑斗兽之槛-圆形斗技场」让这张卡不破坏。
function c52518793.initial_effect(c)
	c:EnableCounterPermit(0x7)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次怪兽从卡组在场上特殊召唤，给这张卡放置1个指示物。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCondition(c52518793.accon)
	e2:SetOperation(c52518793.acop)
	c:RegisterEffect(e2)
	-- 场上表侧表示存在的名字带有「剑斗兽」的怪兽，这张卡每放置有1个指示物，攻击力·守备力上升100。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	-- 设置效果目标为名字带有「剑斗兽」的怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsSetCard,0x1019))
	e3:SetValue(c52518793.atkval)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
	-- 这张卡被卡的效果破坏时，可以从手卡丢弃1张「剑斗兽之槛-圆形斗技场」让这张卡不破坏。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_FZONE)
	e5:SetTarget(c52518793.desreptg)
	e5:SetOperation(c52518793.desrepop)
	c:RegisterEffect(e5)
end
-- 返回当前卡片指示物数量乘以100作为攻击力增减数值
function c52518793.atkval(e,c)
	return e:GetHandler():GetCounter(0x7)*100
end
-- 过滤函数：判断怪兽是否从卡组召唤且为怪兽卡
function c52518793.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_DECK) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 条件函数：检查是否有怪兽从卡组特殊召唤成功
function c52518793.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52518793.cfilter,1,nil,tp)
end
-- 将指示物添加到此卡上
function c52518793.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x7,1)
end
-- 检测是否满足代替破坏的条件：不是因规则破坏且手卡有此卡
function c52518793.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		-- 检测手卡是否存在「剑斗兽之槛-圆形斗技场」
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,52518793) end
	-- 询问玩家是否发动此效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 执行丢弃手卡中「剑斗兽之槛-圆形斗技场」的操作
function c52518793.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 从手卡丢弃1张「剑斗兽之槛-圆形斗技场」
	Duel.DiscardHand(tp,Card.IsCode,1,1,REASON_EFFECT+REASON_DISCARD,nil,52518793)
end
