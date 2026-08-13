--フレムベル・ヘルドッグ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把「炎狱地狱犬」以外的1只守备力200以下的炎属性怪兽特殊召唤。
function c23297235.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把「炎狱地狱犬」以外的1只守备力200以下的炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23297235,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件，使用aux.bdogcon检测该卡是否与对方怪兽战斗并将该怪兽战斗破坏送去墓地。
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c23297235.sptg)
	e1:SetOperation(c23297235.spop)
	c:RegisterEffect(e1)
end
-- 定义可特殊召唤的卡片的筛选条件：守备力200以下、炎属性、卡名不是「炎狱地狱犬」，且能够被特殊召唤。
function c23297235.filter(c,e,tp)
	return c:IsDefenseBelow(200) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(23297235)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标处理函数：在满足空位的前提下，确认卡组中存在符合条件的怪兽才能发动。
function c23297235.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在检查发动条件时，先确认自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 再检查卡组中是否存在至少1张满足filter条件的怪兽。
		and Duel.IsExistingMatchingCard(c23297235.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设定本次连锁的操作信息，登记为从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理时，若场上没有空位则直接结束；否则提示玩家选择要特殊召唤的卡，从卡组选1只符合条件的怪兽特殊召唤。
function c23297235.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己场上主要怪兽区域没有空位，则不进行特殊召唤处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，提示玩家选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选出1张满足filter条件的怪兽卡。
	local g=Duel.SelectMatchingCard(tp,c23297235.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到持有者（发动者）场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
