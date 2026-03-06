--フレムベル・ヘルドッグ
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把「炎狱地狱犬」以外的1只守备力200以下的炎属性怪兽特殊召唤。
function c23297235.initial_effect(c)
	-- 效果原文内容：①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把「炎狱地狱犬」以外的1只守备力200以下的炎属性怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23297235,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否满足效果发动条件，即自己与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c23297235.sptg)
	e1:SetOperation(c23297235.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的怪兽：守备力200以下、炎属性、不是炎狱地狱犬、可以被特殊召唤
function c23297235.filter(c,e,tp)
	return c:IsDefenseBelow(200) and c:IsAttribute(ATTRIBUTE_FIRE) and not c:IsCode(23297235)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的准备阶段，检查是否满足发动条件：场上存在空位且卡组存在符合条件的怪兽
function c23297235.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有空位可用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在至少一张符合条件的怪兽
		and Duel.IsExistingMatchingCard(c23297235.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤一张怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理阶段，执行特殊召唤操作
function c23297235.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有空位，如果没有则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择一张符合条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c23297235.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
