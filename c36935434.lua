--バイロード・サクリファイス
-- 效果：
-- 自己场上的怪兽被战斗破坏的场合才能发动。从手卡特殊召唤1只「电子食人魔」。
function c36935434.initial_effect(c)
	-- 自己场上的怪兽被战斗破坏的场合才能发动。从手卡特殊召唤1只「电子食人魔」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c36935434.condition)
	e1:SetTarget(c36935434.target)
	e1:SetOperation(c36935434.operation)
	c:RegisterEffect(e1)
end
-- 判断被战斗破坏的怪兽的上一个控制者是否为发动玩家，即是否为“自己场上的怪兽”被战破。
function c36935434.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 检查本次被战斗破坏的怪兽组中是否存在至少1只满足条件（上一个控制者是自己）的怪兽，作为发动条件。
function c36935434.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36935434.cfilter,1,nil,tp)
end
-- 筛选手卡中卡名为「电子食人魔」（卡号64268668）且可以被正常特殊召唤的怪兽。
function c36935434.filter(c,e,tp)
	return c:IsCode(64268668) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 发动时判定：我方主要怪兽区有空位，且手卡中存在可特殊召唤的「电子食人魔」；满足则设置后续特殊召唤的操作信息。
function c36935434.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方主要怪兽区是否有可以使用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1张满足特殊召唤条件的「电子食人魔」。
		and Duel.IsExistingMatchingCard(c36935434.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置本次连锁的特殊召唤操作信息：从手卡特殊召唤1只怪兽，供后续时点/连锁检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理：再次确认主怪兽区有空位后，由玩家选择手卡中1只「电子食人魔」，将其表侧表示特殊召唤到我方场上。
function c36935434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若我方主要怪兽区没有空位，则特殊召唤不进行。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的选择提示，准备从手卡选择怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡中选择1张满足过滤条件的「电子食人魔」作为特殊召唤对象。
	local g=Duel.SelectMatchingCard(tp,c36935434.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「电子食人魔」以表侧表示特殊召唤到我方场上（不跳过召唤条件与苏生限制的检查）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
