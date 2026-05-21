--X－セイバー パロムロ
-- 效果：
-- 自己场上存在的名字带有「剑士」的怪兽被战斗破坏送去墓地时，可以支付500基本分，这张卡从墓地特殊召唤。
function c96099959.initial_effect(c)
	-- 自己场上存在的名字带有「剑士」的怪兽被战斗破坏送去墓地时，可以支付500基本分，这张卡从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(96099959,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c96099959.condition)
	e1:SetCost(c96099959.cost)
	e1:SetTarget(c96099959.target)
	e1:SetOperation(c96099959.operation)
	c:RegisterEffect(e1)
end
-- 过滤满足以下条件的卡：非自身、名字带有「剑士」、在墓地、原本由自己控制且因战斗破坏
function c96099959.filter(c,ec,tp)
	return c~=ec and c:IsSetCard(0xd) and c:IsLocation(LOCATION_GRAVE) and c:IsPreviousControler(tp)
		and c:IsReason(REASON_BATTLE)
end
-- 检查被破坏送去墓地的卡片中是否存在自己场上被战斗破坏的名字带有「剑士」的怪兽
function c96099959.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c96099959.filter,1,nil,e:GetHandler(),tp)
end
-- 检查并支付500基本分作为发动的代价
function c96099959.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查玩家是否能够支付500基本分
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	-- 扣除玩家500基本分
	Duel.PayLPCost(tp,500)
end
-- 检查怪兽区域是否有空位以及自身是否可以特殊召唤
function c96099959.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动阶段检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 若此卡仍存在于墓地，则将其在自己场上表侧表示特殊召唤
function c96099959.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将此卡表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
