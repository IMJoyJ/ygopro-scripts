--氷結のフィッツジェラルド
-- 效果：
-- 暗属性调整＋调整以外的兽族怪兽1只
-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。这张卡被战斗破坏送去墓地时，自己场上没有怪兽存在的场合，可以丢弃1张手卡把这张卡从墓地表侧守备表示特殊召唤。
function c94515289.initial_effect(c)
	-- 设置同调召唤手续：暗属性调整 + 1只调整以外的兽族怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_DARK),aux.NonTuner(Card.IsRace,RACE_BEAST),1,1)
	c:EnableReviveLimit()
	-- 这张卡攻击的场合，对方直到伤害步骤结束时魔法·陷阱卡不能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(c94515289.aclimit)
	e1:SetCondition(c94515289.actcon)
	c:RegisterEffect(e1)
	-- 这张卡被战斗破坏送去墓地时，自己场上没有怪兽存在的场合，可以丢弃1张手卡把这张卡从墓地表侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(94515289,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetCondition(c94515289.spcon)
	e2:SetCost(c94515289.spcost)
	e2:SetTarget(c94515289.sptg)
	e2:SetOperation(c94515289.spop)
	c:RegisterEffect(e2)
end
-- 限制发动的卡片类型为魔法·陷阱卡（EFFECT_TYPE_ACTIVATE代表魔陷卡片的发动）
function c94515289.aclimit(e,re,tp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 限制发动效果的条件函数：当前攻击怪兽为这张卡
function c94515289.actcon(e)
	-- 检查当前进行攻击的怪兽是否是这张卡自身
	return Duel.GetAttacker()==e:GetHandler()
end
-- 特殊召唤效果的发动条件函数：被战斗破坏送去墓地且自己场上没有怪兽
function c94515289.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否在墓地、是否因战斗破坏送墓，以及自己场上的怪兽数量是否为0
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
-- 特殊召唤效果的代价函数：丢弃1张手卡
function c94515289.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：检查手卡中是否存在至少1张可以丢弃的卡（排除自身）
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 特殊召唤效果的目标过滤与检查函数
function c94515289.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁中的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数
function c94515289.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时，再次检查自己场上是否没有怪兽，若有则不处理
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将这张卡从墓地表侧守备表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
