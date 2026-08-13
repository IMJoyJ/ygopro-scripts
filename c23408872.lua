--サシカエル
-- 效果：
-- 把自己场上存在的1只水族怪兽解放，选择自己墓地存在的1只名字带有「青蛙」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
function c23408872.initial_effect(c)
	-- 把自己场上存在的1只水族怪兽解放，选择自己墓地存在的1只名字带有「青蛙」的怪兽发动。选择的怪兽从墓地特殊召唤。这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(23408872,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c23408872.cost)
	e1:SetTarget(c23408872.target)
	e1:SetOperation(c23408872.operation)
	c:RegisterEffect(e1)
end
-- 筛选可作为解放代价的水族怪兽：必须是水族；若己方主怪兽区有空位(ft>0)，则允许选择己方或对方场上符合条件的水族；若无空位，则只能选择自己主怪兽区（序号0-4）的水族；对方怪兽必须为表侧表示。
function c23408872.cfilter(c,ft,tp)
	return c:IsRace(RACE_AQUA)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
-- 代价处理：确认可以解放1只满足条件的怪兽后，选择并解放那只水族怪兽作为发动代价。
function c23408872.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取己方主要怪兽区当前的可用空格数，用于后续判断解放后是否有位置特殊召唤。
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 发动代价合法性检查：必须有足够的空格能在解放后空出位置，并且场上存在至少1只满足过滤条件的水族怪兽可供解放。
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c23408872.cfilter,1,nil,ft,tp) end
	-- 从场上选择1只满足条件的水族怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c23408872.cfilter,1,1,nil,ft,tp)
	-- 将所选水族怪兽解放，作为效果发动代价。
	Duel.Release(g,REASON_COST)
end
-- 选择墓地中名字带有「青蛙」（字段0x12）并且能够被正常特殊召唤（满足召唤条件和苏生限制）的怪兽作为特殊召唤对象。
function c23408872.filter(c,e,tp)
	return c:IsSetCard(0x12) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的目标选择处理：从自己墓地选择1只符合条件的「青蛙」怪兽作为取对象目标，并设置本次操作的信息为特殊召唤。
function c23408872.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c23408872.filter(chkc,e,tp) end
	-- 检查自己墓地是否存在至少1只满足条件且能够成为效果对象的「青蛙」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c23408872.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只符合条件的「青蛙」怪兽，并将其设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c23408872.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置操作信息，表明本次效果处理将进行1只怪兽的特殊召唤，供相关时点和效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：若选择的对象仍然存在且与效果关联，则将其从墓地特殊召唤到自己场上。
function c23408872.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的那只墓地怪兽对象。
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤到自己场上（检查召唤条件和苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
