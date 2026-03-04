--BF－魔風のボレアース
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1只「黑羽」怪兽送去墓地。这张卡的等级变成和那只怪兽的等级相同。
-- ②：这张卡战斗破坏怪兽送去墓地时，从自己的场上（表侧表示）·墓地把1只「黑羽」怪兽除外才能发动。那只破坏的怪兽在自己场上守备表示特殊召唤。
function c10602628.initial_effect(c)
	-- 为卡片添加同调召唤手续，要求1只暗属性调整和1只调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,c10602628.mfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。从卡组把1只「黑羽」怪兽送去墓地。这张卡的等级变成和那只怪兽的等级相同。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(10602628,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,10602628)
	e1:SetCondition(c10602628.lvcon)
	e1:SetTarget(c10602628.lvtg)
	e1:SetOperation(c10602628.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏怪兽送去墓地时，从自己的场上（表侧表示）·墓地把1只「黑羽」怪兽除外才能发动。那只破坏的怪兽在自己场上守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(10602628,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCountLimit(1,10602629)
	-- 设置效果触发条件为与对方怪兽战斗并战斗破坏对方怪兽送去墓地
	e2:SetCondition(aux.bdogcon)
	e2:SetCost(c10602628.spcost)
	e2:SetTarget(c10602628.sptg)
	e2:SetOperation(c10602628.spop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的调整怪兽（暗属性）
function c10602628.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 过滤满足条件的「黑羽」怪兽（可送去墓地）
function c10602628.tgfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- 判断是否为同调召唤
function c10602628.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 设置效果发动时的处理目标
function c10602628.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 检查卡组中是否存在满足条件的「黑羽」怪兽
		and Duel.IsExistingMatchingCard(c10602628.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁处理信息，表示将从卡组选择1只「黑羽」怪兽送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 设置效果发动时的处理操作
function c10602628.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 从卡组选择1只「黑羽」怪兽
	local g=Duel.SelectMatchingCard(tp,c10602628.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的怪兽送去墓地并判断是否成功
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		local ec=g:GetFirst()
		if ec:IsLocation(LOCATION_GRAVE) and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 将卡片等级设置为被送去墓地的「黑羽」怪兽的等级
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(ec:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 过滤满足条件的「黑羽」怪兽（可除外作为cost）
function c10602628.spcfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 判断该怪兽是否在场上或墓地且场上存在可用区域
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and Duel.GetMZoneCount(tp,c)>0
end
-- 设置效果发动时的处理成本
function c10602628.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 检查场上或墓地中是否存在满足条件的「黑羽」怪兽作为除外cost
	if chk==0 then return Duel.IsExistingMatchingCard(c10602628.spcfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,bc,tp) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	-- 选择1只「黑羽」怪兽除外作为cost
	local g=Duel.SelectMatchingCard(tp,c10602628.spcfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,bc,tp)
	-- 将选中的怪兽除外作为cost
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 设置效果发动时的处理目标
function c10602628.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置连锁处理信息，表示将要特殊召唤的怪兽
	Duel.SetTargetCard(bc)
	-- 设置连锁处理信息，表示将要特殊召唤的怪兽数量和位置
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- 设置效果发动时的处理操作
function c10602628.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽以守备表示特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
