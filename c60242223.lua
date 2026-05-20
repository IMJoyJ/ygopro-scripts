--深淵の獣サロニール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己或对方的墓地1只光·暗属性怪兽为对象才能发动（对方场上有怪兽存在的场合，这个效果在对方回合也能发动）。那只怪兽除外，这张卡从手卡特殊召唤。
-- ②：这张卡被送去墓地的场合才能发动。「深渊之兽 萨隆魔龙」以外的1只「深渊之兽」怪兽或1张「烙印」魔法·陷阱卡从卡组送去墓地。
local s,id,o=GetID()
-- 初始化效果：注册手卡特殊召唤效果（包含起动效果与自由时点诱发即时效果）以及送去墓地时的诱发效果。
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
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCondition(s.spcon2)
	c:RegisterEffect(e2)
	-- ②：这张卡被送去墓地的场合才能发动。「深渊之兽 萨隆魔龙」以外的1只「深渊之兽」怪兽或1张「烙印」魔法·陷阱卡从卡组送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,id+o)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.target)
	e3:SetOperation(s.operation)
	c:RegisterEffect(e3)
end
-- 起动效果（自己回合）的发动条件：对方场上没有怪兽存在。
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否为0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
end
-- 诱发即时效果（对方回合）的发动条件：对方场上有怪兽存在。
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的怪兽数量是否大于0。
	return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
-- 过滤条件：光·暗属性且可以被除外的怪兽。
function s.cfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT+ATTRIBUTE_DARK) and c:IsAbleToRemove()
end
-- 特殊召唤效果的发动准备与合法性检测（包含对象选择与效果分类声明）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and s.cfilter(chkc) end
	local c=e:GetHandler()
	-- 检查双方墓地是否存在至少1只满足条件的光·暗属性怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,nil)
		-- 检查自己场上是否有空余的怪兽区域，且这张卡是否可以特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要除外的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择墓地中1只满足条件的光·暗属性怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,s.cfilter,tp,LOCATION_GRAVE,LOCATION_GRAVE,1,1,nil)
	-- 设置连锁信息：包含除外操作，操作对象为选择的怪兽。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	-- 设置连锁信息：包含特殊召唤操作，操作对象为这张卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的实际处理：除外目标怪兽，并将这张卡特殊召唤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动阶段选择的效果目标怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与效果相关，若成功将其表侧表示除外，且这张卡仍与效果相关，则继续处理。
	if tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)>0 and c:IsRelateToEffect(e) then
		-- 将这张卡在自己场上表侧表示特殊召唤。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤条件：卡组中除「深渊之兽 萨隆魔龙」以外的「深渊之兽」怪兽或「烙印」魔法·陷阱卡。
function s.filter(c)
	return c:IsAbleToGrave() and not c:IsCode(id)
		and (c:IsType(TYPE_MONSTER) and c:IsSetCard(0x188)
			or c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsSetCard(0x15d))
end
-- 送去墓地效果的发动准备与合法性检测（包含卡组检索检测与效果分类声明）。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足条件的卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息：包含送去墓地操作，操作对象为卡组中的1张卡。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 送去墓地效果的实际处理：从卡组选择1张满足条件的卡送去墓地。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从卡组选择1张满足条件的卡。
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选择的卡送去墓地。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
