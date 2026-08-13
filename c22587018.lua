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
	-- 设置效果的发动条件：当此卡与对方怪兽战斗并战斗破坏该怪兽送去墓地时，条件成立。
	e1:SetCondition(aux.bdogcon)
	e1:SetTarget(c22587018.sptg)
	e1:SetOperation(c22587018.spop)
	c:RegisterEffect(e1)
end
-- 定义卡组内「氢素龙」的过滤函数：该卡必须是卡名「氢素龙」（卡号22587018），并且能够被特殊召唤到自己场上。
function c22587018.filter(c,e,tp)
	return c:IsCode(22587018) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标与合法性判定：检查自己主要怪兽区是否有空位，且卡组中存在符合条件的「氢素龙」，并设置相应的特殊召唤操作信息。
function c22587018.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件判定：自己的主要怪兽区存在至少1个可用格子。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并且卡组中存在至少1张满足特殊召唤条件的「氢素龙」。
		and Duel.IsExistingMatchingCard(c22587018.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果涉及从卡组把1只怪兽特殊召唤（数量为1，持有者为发动者，位置为卡组）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：若自己主要怪兽区仍有空位，则从卡组选取1只符合条件的「氢素龙」，以表侧表示特殊召唤到自己场上。
function c22587018.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认：若自己的主要怪兽区没有空位，则终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 从卡组中检索第一张满足条件的「氢素龙」。
	local tc=Duel.GetFirstMatchingCard(c22587018.filter,tp,LOCATION_DECK,0,nil,e,tp)
	if tc then
		-- 将检索到的「氢素龙」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
