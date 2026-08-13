--ジュラック・ヘレラ
-- 效果：
-- 自己场上守备表示存在的「朱罗纪艾雷拉龙」以外的名字带有「朱罗纪」的怪兽被战斗破坏送去墓地时，这张卡可以从手卡或者墓地特殊召唤。
function c16111820.initial_effect(c)
	-- 自己场上守备表示存在的「朱罗纪艾雷拉龙」以外的名字带有「朱罗纪」的怪兽被战斗破坏送去墓地时，这张卡可以从手卡或者墓地特殊召唤。
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
-- 筛选被战斗破坏送去墓地的怪兽：其原控制者为此效果发动者、被破坏前是守备表示、破坏原因为战斗、当前在墓地、卡名含有「朱罗纪」且不是「朱罗纪艾雷拉龙」自身。
function c16111820.filter(c,tp)
	return c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_DEFENSE) and c:IsReason(REASON_BATTLE) and c:IsLocation(LOCATION_GRAVE)
		and c:IsSetCard(0x22) and not c:IsCode(16111820)
end
-- 检测本次被战斗破坏送去墓地的怪兽群中是否存在至少1只满足上述筛选条件的怪兽。
function c16111820.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c16111820.filter,1,nil,tp)
end
-- 效果发动时的合法性检测：自己主要怪兽区有空余格且这张卡（在手牌/墓地）可以被特殊召唤。
function c16111820.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 要求自己场上存在可用的主要怪兽区空格，确保特殊召唤有位置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本连锁的操作信息登记为“特殊召唤此卡”，使其他卡片（如星尘龙等）能正确响应/干扰。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理时，取得效果持有者自身；若该卡仍与发动效果保持关联（未被除外/离场等），则以表侧表示特殊召唤此卡到自己场上。
function c16111820.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示（通常为攻击表示）特殊召唤到其持有者/控制者的场上。
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
