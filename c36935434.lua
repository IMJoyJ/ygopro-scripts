--バイロード・サクリファイス
-- 效果：
-- 自己场上的怪兽被战斗破坏的场合才能发动。从手卡特殊召唤1只「电子食人魔」。
function c36935434.initial_effect(c)
	-- 效果原文内容：自己场上的怪兽被战斗破坏的场合才能发动。从手卡特殊召唤1只「电子食人魔」。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c36935434.condition)
	e1:SetTarget(c36935434.target)
	e1:SetOperation(c36935434.operation)
	c:RegisterEffect(e1)
end
-- 检查目标怪兽是否在被战斗破坏前属于玩家
function c36935434.cfilter(c,tp)
	return c:IsPreviousControler(tp)
end
-- 判断是否有满足条件的怪兽被战斗破坏
function c36935434.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c36935434.cfilter,1,nil,tp)
end
-- 筛选手卡中可以特殊召唤的「电子食人魔」
function c36935434.filter(c,e,tp)
	return c:IsCode(64268668) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 判断是否满足发动条件：场上存在空位且手卡有「电子食人魔」
function c36935434.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手卡是否存在满足条件的「电子食人魔」
		and Duel.IsExistingMatchingCard(c36935434.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置连锁操作信息，指定将要特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：检查场上是否有空位，提示选择并特殊召唤「电子食人魔」
function c36935434.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若场上无空位则不执行效果
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手卡选择1只「电子食人魔」
	local g=Duel.SelectMatchingCard(tp,c36935434.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「电子食人魔」特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
