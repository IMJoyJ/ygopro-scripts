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
	-- 设置攻击力·守备力上升效果的适用对象为场上表侧表示存在的名字带有「剑斗兽」（0x1019）的怪兽。
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
-- 返回这张卡上放置的指示物数量乘以100，作为攻击力上升的数值。
function c52518793.atkval(e,c)
	return e:GetHandler():GetCounter(0x7)*100
end
-- 判断怪兽是否满足“从卡组特殊召唤到场上”且“原本种类为怪兽卡”的条件，用于过滤本次特殊召唤成功的怪兽。
function c52518793.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_DECK) and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 检查本次特殊召唤成功的怪兽群中是否存在至少1只满足上述条件的怪兽，若存在则触发放置指示物。
function c52518793.accon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c52518793.cfilter,1,nil,tp)
end
-- 给这张卡（剑斗兽之槛-圆形斗技场）放置1个指示物（指示物类型0x7）。
function c52518793.acop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():AddCounter(0x7,1)
end
-- 代替破坏效果的触发条件：这张卡将要被破坏且破坏原因不是规则破坏，同时手牌中存在可以丢弃的同名卡。
function c52518793.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		-- 检查手牌中是否存在至少1张卡号为52518793（即「剑斗兽之槛-圆形斗技场」）的卡。
		and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,52518793) end
	-- 询问控制者是否选择从手卡丢弃1张同名卡来替代这次破坏，选择是则执行代替破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 代替破坏效果的处理：从手卡丢弃1张「剑斗兽之槛-圆形斗技场」，使这张卡不被卡的效果破坏。
function c52518793.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 从手卡筛选并丢弃1张「剑斗兽之槛-圆形斗技场」（卡号52518793），丢弃原因为效果+丢弃（REASON_EFFECT+REASON_DISCARD）。
	Duel.DiscardHand(tp,Card.IsCode,1,1,REASON_EFFECT+REASON_DISCARD,nil,52518793)
end
