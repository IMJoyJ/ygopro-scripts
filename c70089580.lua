--オーロラ・ウィング
-- 效果：
-- 这张卡被战斗破坏送去墓地时，这张卡可以表侧攻击表示特殊召唤。「极光翼鸟」的效果1回合只能使用1次。
function c70089580.initial_effect(c)
	-- 这张卡被战斗破坏送去墓地时，这张卡可以表侧攻击表示特殊召唤。「极光翼鸟」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(70089580,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCountLimit(1,70089580)
	e1:SetCondition(c70089580.condition)
	e1:SetTarget(c70089580.target)
	e1:SetOperation(c70089580.operation)
	c:RegisterEffect(e1)
end
-- 检查自身是否在墓地且是被战斗破坏
function c70089580.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检查怪兽区域是否有空位，以及自身是否可以表侧攻击表示特殊召唤
function c70089580.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查发动玩家的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 将自身表侧攻击表示特殊召唤
function c70089580.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若怪兽区域没有空位则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧攻击表示特殊召唤
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
