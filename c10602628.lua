--BF－魔風のボレアース
-- 效果：
-- 暗属性调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。从卡组把1只「黑羽」怪兽送去墓地。这张卡的等级变成和那只怪兽的等级相同。
-- ②：这张卡战斗破坏怪兽送去墓地时，从自己的场上（表侧表示）·墓地把1只「黑羽」怪兽除外才能发动。那只破坏的怪兽在自己场上守备表示特殊召唤。
function c10602628.initial_effect(c)
	-- 为该卡添加同调召唤手续：1只暗属性调整+1只以上调整以外的怪兽。
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
	-- 设置②效果的发动条件：本卡与对方怪兽战斗并将其战斗破坏送去墓地时才能发动。
	e2:SetCondition(aux.bdogcon)
	e2:SetCost(c10602628.spcost)
	e2:SetTarget(c10602628.sptg)
	e2:SetOperation(c10602628.spop)
	c:RegisterEffect(e2)
end
-- 定义同调素材中调整怪兽的筛选条件：该调整怪兽必须是暗属性。
function c10602628.mfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK)
end
-- 定义①效果从卡组送去墓地的卡牌条件：卡名含有「黑羽」字段的怪兽卡，且可以被送去墓地。
function c10602628.tgfilter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①效果的发动条件：这张卡同调召唤成功时才能发动。
function c10602628.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果发动判定（chk==0）：这张卡仍与效果相关，且卡组中存在符合条件的「黑羽」怪兽。
function c10602628.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsRelateToEffect(e)
		-- 且卡组中存在至少1只满足tgfilter条件的「黑羽」怪兽。
		and Duel.IsExistingMatchingCard(c10602628.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果包含从卡组把1张卡送去墓地的处理（分类为CATEGORY_TOGRAVE，位置为卡组），用于给其他卡作发动检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只「黑羽」怪兽送去墓地；若成功送去墓地且该卡在墓地、本体表侧表示且与效果相关，则给本体附加等级变为那只怪兽等级的效果。
function c10602628.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1张满足tgfilter的「黑羽」怪兽。
	local g=Duel.SelectMatchingCard(tp,c10602628.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 若确实选择了卡且成功将该卡送去墓地，则继续执行等级变化处理。
	if g:GetCount()>0 and Duel.SendtoGrave(g,REASON_EFFECT)~=0 then
		local ec=g:GetFirst()
		if ec:IsLocation(LOCATION_GRAVE) and c:IsFaceup() and c:IsRelateToEffect(e) then
			-- 这张卡的等级变成和那只怪兽的等级相同。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_LEVEL)
			e1:SetValue(ec:GetLevel())
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
			c:RegisterEffect(e1)
		end
	end
end
-- 定义②效果发动代价的筛选条件：选择1只「黑羽」怪兽作为除外代价，要求它是我方场上表侧表示或在我方墓地，且除外后我方场上仍有可用的怪兽区域。
function c10602628.spcfilter(c,tp)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
		-- 进一步限制代价卡必须是表侧表示在场或位于墓地，且除外后我方场上仍有空余的怪兽区。
		and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and Duel.GetMZoneCount(tp,c)>0
end
-- ②效果的代价处理：从自己的场上（表侧表示）·墓地选择1只「黑羽」怪兽除外；chk==0时先检查是否存在满足条件的代价卡。
function c10602628.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	-- 代价检测：存在至少1只满足spcfilter的「黑羽」怪兽（排除战斗对象bc）可以作为代价。
	if chk==0 then return Duel.IsExistingMatchingCard(c10602628.spcfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,bc,tp) end
	-- 弹出选择提示：请选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己场上（表侧表示）·墓地选择1只符合条件「黑羽」怪兽作为代价。
	local g=Duel.SelectMatchingCard(tp,c10602628.spcfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,bc,tp)
	-- 将选择的「黑羽」怪兽表侧表示除外，作为发动代价（REASON_COST）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果发动时选择对象：以被这张卡战斗破坏并送去墓地的那只怪兽为对象，确认其可以被特殊召唤；若可以则设置对象及操作信息，准备特殊召唤。
function c10602628.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	if chk==0 then return bc:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将被战斗破坏的怪兽设置为当前连锁的效果对象。
	Duel.SetTargetCard(bc)
	-- 设置操作信息：本次效果包含将对象怪兽特殊召唤的处理（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,bc,1,0,0)
end
-- ②效果处理：取得对象怪兽，若其仍与效果相关，则将其守备表示特殊召唤到自己场上。
function c10602628.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中记录的效果对象（被战斗破坏的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
