--ジュラック・ヘレラ
-- 效果：
-- 自己场上守备表示存在的「朱罗纪艾雷拉龙」以外的名字带有「朱罗纪」的怪兽被战斗破坏送去墓地时，这张卡可以从手卡或者墓地特殊召唤。
function c16111820.initial_effect(c)
	-- 创建一个诱发选发效果，可以在自己场上守备表示存在的「朱罗纪艾雷拉龙」以外的名字带有「朱罗纪」的怪兽被战斗破坏送去墓地时发动，将此卡从手卡或墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16111820,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c16111820.condition)
	e1:SetTarget(c16111820.target)
	e1:SetOperation(c16111820.operation)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于判断被战斗破坏送去墓地的怪兽是否满足条件：上一个控制者为自己、上一个位置为守备表示、破坏原因为战斗、当前位置在墓地、卡名含有「朱罗纪」、且不是此卡本身。
function c16111820.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_DEFENSE) and c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE)
		and c:IsSetCard(0x22) and not c:IsCode(16111820)
end
-- 效果发动条件，判断是否有满足filter条件的怪兽被战斗破坏送去墓地。
function c16111820.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16111820.filter,1,nil,tp)
end
-- 效果处理目标设定，判断是否满足特殊召唤条件：场上主怪兽区有空位且此卡可以被特殊召唤。
function c16111820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上主怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果处理信息，将此卡作为特殊召唤的目标。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理函数，执行特殊召唤操作。
function c16111820.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将此卡以正面表示形式特殊召唤到自己场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
