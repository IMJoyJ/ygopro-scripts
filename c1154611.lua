--バージェストマ・レアンコイリア
-- 效果：
-- ①：以除外的1张自己或者对方的卡为对象才能发动。那张卡回到墓地。
-- ②：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c1154611.initial_effect(c)
	-- 对应①：以除外的1张自己或者对方的卡为对象才能发动。那张卡回到墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(c1154611.target)
	e1:SetOperation(c1154611.activate)
	c:RegisterEffect(e1)
	-- 对应②前半：陷阱卡发动时，连锁那个发动才能把这个效果在墓地发动。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(1154611,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c1154611.spcon)
	e2:SetTarget(c1154611.sptg)
	e2:SetOperation(c1154611.spop)
	c:RegisterEffect(e2)
end
-- ①的发动时点处理：从双方除外区选择1张卡为对象，并设置送去墓地的操作信息；chkc 用于对象合法性校验。
function c1154611.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) end
	-- 发动合法性检查：确认双方除外区存在至少1张可选择的对象卡。
	if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,nil) end
	-- 弹出选择提示：请选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 玩家从双方除外区选择1张卡作为效果对象，并记录为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,nil,tp,LOCATION_REMOVED,LOCATION_REMOVED,1,1,nil)
	-- 设置操作信息：本次操作分类为送去墓地，目标为已选择的对象。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- ①的效果处理：获取对象卡，若对象仍与效果关联，则将其从除外区送去墓地。
function c1154611.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的对象卡（即①选择的目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡送去墓地，原因标记为效果送回墓地（REASON_EFFECT+REASON_RETURN）。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_RETURN)
	end
end
-- ②的发动条件：当前连锁发动的卡是陷阱卡的发动（re 为陷阱卡且为发动类型 EFFECT_TYPE_ACTIVATE）。
function c1154611.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ②的发动时点处理：检查自己怪兽区域有空位且允许特殊召唤该陷阱怪兽；满足则设置特殊召唤操作信息。
function c1154611.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性检查：自己场上主要怪兽区域存在可用空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 并检查自己能否特殊召唤该陷阱怪兽：卡号1154611，种族水族，属性水，2星，攻1200/守0，作为通常怪兽/陷阱怪兽特殊召唤。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,1154611,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 设置操作信息：本效果将这张卡特殊召唤（CATEGORY_SPECIAL_SUMMON）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②的效果处理：若自身仍与效果关联且场上可特招，则把自身变成通常怪兽特殊召唤，并附加不受怪兽效果影响、离场除外两个效果。
function c1154611.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时二次检查：若怪兽区域已无空位，则直接结束该效果处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 确认此卡仍与效果关联（未被移走）且当前仍允许特殊召唤此陷阱怪兽。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,1154611,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将自身以表侧表示特殊召唤到自己场上，nocheck=true 表示不检查召唤条件，nolimit=false 表示需检查苏生限制（此处实际按陷阱怪兽方式处理）。
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 对应②中“这个效果特殊召唤的这张卡不受怪兽的效果影响”。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c1154611.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2,true)
		-- 对应②中“从场上离开的场合除外”。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成分解式特殊召唤流程，正式完成特殊召唤并触发相关时点。
		Duel.SpecialSummonComplete()
	end
end
-- 免疫判定过滤：仅当触发效果是怪兽的效果时返回 true。
function c1154611.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
