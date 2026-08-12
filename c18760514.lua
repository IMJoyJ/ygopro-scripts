--マッドマーダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「僵尸带菌者」使用。
-- ②：这张卡在墓地存在的场合，以自己场上1只6星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是不死族怪兽不能特殊召唤。
function c18760514.initial_effect(c)
	-- 使此卡在场上或墓地存在时视为「僵尸带菌者」使用
	aux.EnableChangeCode(c,33420078,LOCATION_MZONE+LOCATION_GRAVE)
	-- ②：这张卡在墓地存在的场合，以自己场上1只6星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是不死族怪兽不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,18760514)
	e1:SetTarget(c18760514.target)
	e1:SetOperation(c18760514.operation)
	c:RegisterEffect(e1)
end
-- 过滤场上自己6星以上的表侧表示怪兽
function c18760514.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(6)
end
-- 判断是否满足发动条件：有足够怪兽区域，存在符合条件的目标怪兽，此卡可特殊召唤
function c18760514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18760514.filter(chkc) end
	-- 判断是否有足够的怪兽区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断场上是否存在满足条件的怪兽作为目标
		and Duel.IsExistingTarget(c18760514.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要下降等级的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18760514,0))  --"请选择要下降等级的怪兽"
	-- 选择场上自己1只6星以上的怪兽作为目标
	Duel.SelectTarget(tp,c18760514.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置此效果的处理信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理效果：使目标怪兽等级下降2星，并特殊召唤此卡
function c18760514.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取此效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 使目标怪兽的等级下降2星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	-- 判断是否有足够的怪兽区域并确认此卡是否仍存在于场上的处理条件
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 执行特殊召唤此卡的操作
		if Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
			-- 只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是不死族怪兽不能特殊召唤。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
			e2:SetRange(LOCATION_MZONE)
			e2:SetAbsoluteRange(tp,1,0)
			e2:SetTarget(c18760514.splimit)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e2,true)
		end
		-- 完成特殊召唤流程
		Duel.SpecialSummonComplete()
	end
end
-- 限制非不死族怪兽不能特殊召唤
function c18760514.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
