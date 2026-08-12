--深淵の獣ドルイドヴルム
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
-- ②：这张卡从场上送去墓地的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果：①效果（手牌起动/诱发即时，除外墓地光暗特召自身），②效果（从场上送墓时，送墓对方场上1只特召的怪兽）。
function s.initial_effect(c)
	-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡从场上送去墓地的场合，以对方场上1只特殊召唤的怪兽为对象才能发动。那只怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e3:SetCondition(s.condition)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 定义①效果作为起动效果发动时的条件（对方场上没有怪兽存在）。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
-- 定义①效果作为二速诱发即时效果发动时的条件（对方场上有怪兽存在）。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判定对方场上是否有怪兽存在。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤条件：自己或对方墓地的光·暗属性且可以除外的怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- ①效果的靶向与发动准备：检查合法对象与特召空间，选择墓地的光·暗属性怪兽为对象，并声明除外与特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 发动准备阶段（chk==0）：检查双方墓地是否存在至少1只满足条件（光·暗属性且可除外）的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 并且检查自身怪兽区域是否有空位，以及自身是否可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择双方墓地中1只满足条件的光·暗属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁操作信息：包含除外选定怪兽的操作。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁操作信息：包含特殊召唤自身的操作。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果的处理：将作为对象的墓地怪兽除外，若除外成功，则将手牌的这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查对象怪兽是否仍适应效果，并将其表侧表示除外；若除外成功且自身仍适应效果，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡在自身场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②效果的发动条件：这张卡必须是从场上送去墓地。
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：对方场上特殊召唤成功且可以送去墓地的怪兽。
function s.filter(c)
	return c:IsSummonType(SUMMON_TYPE_SPECIAL) and c:IsAbleToGrave()
end
-- ②效果的靶向与发动准备：检查对方场上是否有特殊召唤的怪兽，选择其中1只作为对象，并声明送去墓地的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 发动准备阶段（chk==0）：检查对方场上是否存在至少1只特殊召唤的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家选择对方场上1只特殊召唤的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.filter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息：包含将选定怪兽送去墓地的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ②效果的处理：将作为对象的对方场上怪兽送去墓地。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对方场上的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽因效果送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
