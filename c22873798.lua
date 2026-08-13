--ハイエナ
-- 效果：
-- 这张卡因战斗送去墓地时，可以把卡组的「鬣狗」特殊召唤到场上。之后卡组洗切。
function c22873798.initial_effect(c)
	-- 这张卡因战斗送去墓地时，可以把卡组的「鬣狗」特殊召唤到场上。之后卡组洗切。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22873798,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(c22873798.condition)
	e1:SetTarget(c22873798.target)
	e1:SetOperation(c22873798.operation)
	c:RegisterEffect(e1)
end
-- 判断该效果能否发动：效果所属的这张卡必须位于墓地，且其从场上送去墓地的原因为战斗破坏。
function c22873798.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 检索对象的过滤条件：目标卡必须是卡名也为「鬣狗」（卡号22873798）的卡，并且该卡当前可以被特殊召唤。
function c22873798.filter(c,e,tp)
	return c:IsCode(22873798) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- target函数：在效果发动前检查发动条件——自己主要怪兽区有空位，且卡组中存在至少1张符合条件的「鬣狗」。
function c22873798.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的主要怪兽区，空位数量需大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己卡组中是否存在至少1张满足c22873798.filter条件的「鬣狗」。
		and Duel.IsExistingMatchingCard(c22873798.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次效果处理将进行1次从卡组的特殊召唤，分类为CATEGORY_SPECIAL_SUMMON，供相关的连锁检测或效果响应使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- operation函数：效果处理时，先计算可用怪兽区空格数；若【青眼精灵龙】的效果适用（不能同时特殊召唤2只以上怪兽），则将可特召数量上限限制为1；随后从卡组中选择符合条件的「鬣狗」，并以表侧表示特殊召唤到自己场上。
function c22873798.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得自己场上可用的主要怪兽区空格数量，作为本次可特殊召唤怪兽数量的上限参考。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	-- 检测【青眼精灵龙】(59822133)的怪兽效果是否生效中。禁止双方同时特殊召唤2只以上怪兽
	if Duel.IsPlayerAffectedByEffect(tp,59822133) then ft=1 end
	-- 显示选择提示，提示玩家从卡组中选择要特殊召唤的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己卡组中选择1至ft张满足筛选条件的「鬣狗」（ft为可用空格数，受青眼精灵龙限制时通常为1）。
	local g=Duel.SelectMatchingCard(tp,c22873798.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的「鬣狗」以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
