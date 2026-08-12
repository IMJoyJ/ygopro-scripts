--忍法 変化の術
-- 效果：
-- ①：把自己场上1只表侧表示的「忍者」怪兽解放才能把这张卡发动。把持有解放的怪兽的等级＋3以下的等级的1只兽族·鸟兽族·昆虫族怪兽从手卡·卡组特殊召唤。这张卡从场上离开时那只怪兽破坏。
function c70861343.initial_effect(c)
	-- ①：把自己场上1只表侧表示的「忍者」怪兽解放才能把这张卡发动。把持有解放的怪兽的等级＋3以下的等级的1只兽族·鸟兽族·昆虫族怪兽从手卡·卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(c70861343.target)
	e1:SetOperation(c70861343.operation)
	c:RegisterEffect(e1)
	-- 这张卡从场上离开时那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_LEAVE_FIELD)
	e2:SetOperation(c70861343.desop)
	c:RegisterEffect(e2)
end
-- 过滤解放怪兽的条件：自己场上表侧表示的「忍者」怪兽，且手卡·卡组存在可特殊召唤的等级在解放怪兽等级+3以下的兽族·鸟兽族·昆虫族怪兽
function c70861343.cfilter(c,e,tp,ft)
	local lv=c:GetLevel()
	return c:IsFaceup() and lv>0 and c:IsSetCard(0x2b)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5))
		-- 检查手卡或卡组中是否存在至少1只满足特殊召唤条件的、等级在解放怪兽等级+3以下的怪兽
		and Duel.IsExistingMatchingCard(c70861343.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,lv+3,e,tp)
end
-- 过滤特殊召唤怪兽的条件：等级在指定等级以下、种族为兽族/鸟兽族/昆虫族且可以特殊召唤的怪兽
function c70861343.filter(c,lv,e,tp)
	return c:IsLevelBelow(lv) and c:IsRace(RACE_BEAST+RACE_WINDBEAST+RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 卡片发动时的效果处理：检查是否能解放怪兽并特殊召唤，选择1只「忍者」怪兽解放作为发动代价，并保存其等级+3的数值，设置特殊召唤的操作信息
function c70861343.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取玩家场上可用的怪兽区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	-- 在发动检查阶段，确认怪兽区域有空位（若解放自己场上怪兽则空位要求可放宽），且存在可解放的满足条件的「忍者」怪兽
	if chk==0 then return ft>-1 and Duel.CheckReleaseGroup(tp,c70861343.cfilter,1,nil,e,tp,ft) end
	-- 让玩家选择1只满足条件的「忍者」怪兽作为解放对象
	local rg=Duel.SelectReleaseGroup(tp,c70861343.cfilter,1,1,nil,e,tp,ft)
	e:SetLabel(rg:GetFirst():GetLevel()+3)
	-- 解放选择的怪兽作为发动的代价
	Duel.Release(rg,REASON_COST)
	-- 设置特殊召唤的操作信息，表示将从手卡或卡组特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 卡片发动后的效果处理：从手卡或卡组选择1只满足等级和种族条件的怪兽特殊召唤，并与这张卡建立对象关联
function c70861343.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 检查怪兽区域是否已满，若无空位则不处理特殊召唤
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从手卡或卡组选择1只等级在被解放怪兽等级+3以下且满足种族条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c70861343.filter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e:GetLabel(),e,tp)
	local tc=g:GetFirst()
	-- 若成功选择怪兽，则将其以表侧表示特殊召唤（分步处理），并让这张卡对该怪兽进行标记（建立对象关联）
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		c:SetCardTarget(tc)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
-- 离场时的效果处理：若这张卡从场上离开，则将其标记的怪兽破坏
function c70861343.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetFirstCardTarget()
	if tc and tc:IsLocation(LOCATION_MZONE) then
		-- 因效果将该怪兽破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
