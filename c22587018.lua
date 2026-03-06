--ハイドロゲドン
-- 效果：
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「氢素龙」特殊召唤。
function c22587018.initial_effect(c)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只「氢素龙」特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22587018,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	-- 检测是否满足效果发动条件：己方怪兽与对方怪兽战斗并破坏对方怪兽送入墓地
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c22587018.sptg)
	e1:SetOperation(c22587018.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查卡组中是否存在可特殊召唤的「氢素龙」
function c22587018.filter(c,e,tp)
	return c:IsCode(22587018) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果处理的条件判断：判断场上是否有空位且卡组中是否存在满足条件的「氢素龙」
function c22587018.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组中是否存在满足条件的「氢素龙」
		and Duel.IsExistingMatchingCard(c22587018.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息：标记本次效果将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理函数：检查场上是否有空位并检索卡组中的「氢素龙」进行特殊召唤
function c22587018.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场上是否有空位，若无则直接返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索满足条件的第一只「氢素龙」
	local tc=Duel.GetFirstMatchingCard(c22587018.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的「氢素龙」以正面表示方式特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
