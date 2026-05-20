--ダウナード・マジシャン
-- 效果：
-- 魔法师族4星怪兽×2
-- 这张卡也能在自己主要阶段2在自己场上的3阶以下的超量怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ③：这张卡进行战斗的伤害计算后发动。这张卡1个超量素材取除。
function c72167543.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_SPELLCASTER),4,2,c72167543.ovfilter,aux.Stringid(72167543,0))  --"是否在3阶以下的超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ②：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(c72167543.atkval)
	c:RegisterEffect(e2)
	-- ③：这张卡进行战斗的伤害计算后发动。这张卡1个超量素材取除。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(72167543,1))  --"移除素材"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_BATTLED)
	e3:SetOperation(c72167543.rmop)
	c:RegisterEffect(e3)
end
-- 定义重叠超量召唤的素材过滤条件：自己场上表侧表示、3阶以下的超量怪兽，且当前处于主要阶段2
function c72167543.ovfilter(c)
	-- 检查卡片是否表侧表示、阶级在3以下，且当前是否为主要阶段2
	return c:IsFaceup() and c:IsRankBelow(3) and Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 计算并返回攻击力上升值，数值为这张卡的超量素材数量乘以200
function c72167543.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 效果处理：将这张卡的1个超量素材取除
function c72167543.rmop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
end
