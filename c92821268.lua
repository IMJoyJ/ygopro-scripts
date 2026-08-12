--ギミック・パペット－ナイト・ジョーカー
-- 效果：
-- 自己场上的名字带有「机关傀儡」的怪兽被战斗破坏送去自己墓地时，把那只怪兽从游戏中除外才能发动。这张卡从手卡特殊召唤。「机关傀儡-夜小丑」的效果1回合只能使用1次。
function c92821268.initial_effect(c)
	-- 自己场上的名字带有「机关傀儡」的怪兽被战斗破坏送去自己墓地时，把那只怪兽从游戏中除外才能发动。这张卡从手卡特殊召唤。「机关傀儡-夜小丑」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92821268,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,92821268)
	e1:SetCost(c92821268.cost)
	e1:SetTarget(c92821268.target)
	e1:SetOperation(c92821268.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足“原本控制者为自己、在自己场上被战斗破坏并送去自己墓地的「机关傀儡」怪兽”且“可以作为代价除外”的卡片
function c92821268.cfilter(c,tp)
	return c:IsControler(tp) and c:IsLocation(LOCATION_GRAVE) and c:IsSetCard(0x1083)
		and c:IsPreviousControler(tp) and c:IsAbleToRemoveAsCost()
end
-- 发动代价：检查并过滤出被战斗破坏送去墓地的「机关傀儡」怪兽，将其除外
function c92821268.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(c92821268.cfilter,1,nil,tp) end
	local g=eg:Filter(c92821268.cfilter,nil,tp)
	-- 将作为代价的怪兽表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 检查自身是否可以特殊召唤以及怪兽区域是否有空位
function c92821268.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息，表明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若此卡仍在手卡，则将其特殊召唤
function c92821268.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡表侧表示特殊召唤到自己的场上
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
