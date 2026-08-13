--マッドマーダー
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「僵尸带菌者」使用。
-- ②：这张卡在墓地存在的场合，以自己场上1只6星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是不死族怪兽不能特殊召唤。
function c18760514.initial_effect(c)
	-- 注册①效果：这张卡在场上·墓地存在时，卡名当作「僵尸带菌者」（33420078）使用。
	aux.EnableChangeCode(c,33420078,LOCATION_MZONE+LOCATION_GRAVE)
	-- 这个卡名的②的效果1回合只能使用1次。②：这张卡在墓地存在的场合，以自己场上1只6星以上的怪兽为对象才能发动。那只怪兽的等级下降2星，这张卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域表侧表示存在，自己不是不死族怪兽不能特殊召唤。
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
-- 定义发动时选择对象的筛选条件：对象必须为表侧表示且等级为6星以上。
function c18760514.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(6)
end
-- 发动时点判定与选对象处理：检查自己场上有6星以上表侧怪兽、主要怪兽区有空位且这张卡可以特殊召唤；通过后选择对象怪兽并设置特殊召唤的操作信息。
function c18760514.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18760514.filter(chkc) end
	-- 检查自己主要怪兽区是否存在空余格子，供这张卡后续特殊召唤使用。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示且6星以上的怪兽，并且该怪兽能成为此效果的对象。
		and Duel.IsExistingTarget(c18760514.filter,tp,LOCATION_MZONE,0,1,nil)
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家发出选择提示信息，提示内容为“请选择要下降等级的怪兽”。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(18760514,0))  --"请选择要下降等级的怪兽"
	-- 从自己场上选择1只表侧表示且6星以上的怪兽作为效果对象，并记录为当前连锁的对象。
	Duel.SelectTarget(tp,c18760514.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：本次效果包含特殊召唤，预定将效果持有者（这张卡）特殊召唤。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：先令对象怪兽的等级下降2星；若这张卡仍在墓地且自己主要怪兽区有空位，则将其特殊召唤，并附加“自己不是不死族怪兽不能特殊召唤”的自肃效果。
function c18760514.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() or not tc:IsRelateToEffect(e) or tc:IsImmuneToEffect(e) or tc:GetLevel()<3 then return end
	local c=e:GetHandler()
	-- 那只怪兽的等级下降2星
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(-2)
	tc:RegisterEffect(e1)
	-- 检查自己场上主要怪兽区仍有空位，且这张卡仍与发动时的效果关联（没有被无效或离开墓地等）。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and c:IsRelateToEffect(e) then
		-- 以表侧表示形式将这张卡特殊召唤（不检查召唤条件与苏生限制）；若特殊召唤成功，则继续处理后续的自肃效果。
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
		-- 完成特殊召唤处理，使通过SpecialSummonStep进行的特殊召唤正式生效。
		Duel.SpecialSummonComplete()
	end
end
-- 自肃限制条件：被特殊召唤的怪兽不是不死族时禁止特殊召唤。
function c18760514.splimit(e,c)
	return not c:IsRace(RACE_ZOMBIE)
end
