--M・HERO ダイアン
-- 效果：
-- 这张卡用「假面变化」的效果才能特殊召唤。
-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只4星以下的「英雄」怪兽特殊召唤。
function c62624486.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡用「假面变化」的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤条件的判定函数为假面变化限制（即只能通过「假面变化」的效果特殊召唤）
	e1:SetValue(aux.MaskChangeLimit)
	c:RegisterEffect(e1)
	-- ①：这张卡战斗破坏对方怪兽送去墓地时才能发动。从卡组把1只4星以下的「英雄」怪兽特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(62624486,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(c62624486.spcon)
	e2:SetTarget(c62624486.sptg)
	e2:SetOperation(c62624486.spop)
	c:RegisterEffect(e2)
end
-- 检查触发事件是否为：仅有1只怪兽被战斗破坏送去墓地，且该怪兽是被这张卡战斗破坏
function c62624486.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 过滤卡组中等级4以下、属于「英雄」字段且可以特殊召唤的怪兽
function c62624486.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x8) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动的可行性检查（检查自身场上是否有空位，以及卡组中是否存在符合条件的怪兽）
function c62624486.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前玩家的主要怪兽区域是否有可用的空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查己方卡组中是否存在至少1只满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c62624486.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁的操作信息，表明此效果包含从卡组特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：在己方场上有空位的情况下，从卡组选择1只满足条件的「英雄」怪兽以表侧表示特殊召唤
function c62624486.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区域是否还有空位，若无则不处理后续效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息，提示其选择要特殊召唤的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从己方卡组中选择1只满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c62624486.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧表示特殊召唤到己方场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
