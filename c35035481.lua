--バージェストマ・オレノイデス
-- 效果：
-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
function c35035481.initial_effect(c)
	-- ①：以场上1张魔法·陷阱卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c35035481.target)
	e1:SetOperation(c35035481.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，陷阱卡发动时才能发动（同一连锁上最多1次）。这张卡变成通常怪兽（水族·水·2星·攻1200/守0）在怪兽区域特殊召唤（不当作陷阱卡使用）。这个效果特殊召唤的这张卡不受怪兽的效果影响，从场上离开的场合除外。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(c35035481.spcon)
	e2:SetTarget(c35035481.sptg)
	e2:SetOperation(c35035481.spop)
	c:RegisterEffect(e2)
end
-- 作为①的破坏对象筛选条件：对象必须是场上的魔法·陷阱卡。
function c35035481.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- ①的发动时点处理：检查是否存在合法的取对象目标，让玩家选择1张场上的魔法·陷阱卡作为对象，并登记破坏信息。
function c35035481.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c35035481.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性判定：确认场上存在除自身以外、可以被选择为对象的魔法·陷阱卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c35035481.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向操作玩家显示“请选择要破坏的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张魔法·陷阱卡（不能选这张卡自身）作为①的破坏对象，并建立对象关联。
	local g=Duel.SelectTarget(tp,c35035481.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 登记操作信息：记录本次效果将破坏1张卡，供后续连锁与效果判定使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①的效果处理：取得对象卡，若对象卡仍与效果关联，则将其破坏。
function c35035481.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①发动时选择的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以“效果”的原因将对象卡破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②的发动条件：当前连锁中发动的效果确实是陷阱卡的“发动”（即发动中的卡为陷阱卡且拥有发动效果类型）。
function c35035481.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsActiveType(TYPE_TRAP) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- ②的发动时点处理：确认自己怪兽区有空位且可以特殊召唤这张陷阱怪兽；若满足则登记特殊召唤信息。
function c35035481.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 发动合法性判定：自己场上有空余的主要怪兽区域可供特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动合法性判定：自己能够以水族·水·2星·攻1200/守0的通常怪兽形式特殊召唤这张卡。
		and Duel.IsPlayerCanSpecialSummonMonster(tp,35035481,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) end
	-- 登记操作信息：记录本次效果将特殊召唤这张卡，供连锁判定使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ②的效果处理：实际把这张卡变成通常怪兽特殊召唤，并赋予其“不受怪兽的效果影响”和“从场上离开时除外”的效果。
function c35035481.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次确认：若自己场上已无空余的主要怪兽区域，则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local c=e:GetHandler()
	-- 效果处理时确认：这张卡仍在墓地且与本效果关联，并且玩家仍具备特殊召唤该陷阱怪兽的能力，才继续处理。
	if c:IsRelateToEffect(e) and Duel.IsPlayerCanSpecialSummonMonster(tp,35035481,0xd4,TYPES_NORMAL_TRAP_MONSTER,1200,0,2,RACE_AQUA,ATTRIBUTE_WATER) then
		c:AddMonsterAttribute(TYPE_NORMAL)
		-- 将这张卡以表侧攻击表示特殊召唤到自己的主要怪兽区（作为通常怪兽，不当作陷阱卡）。
		Duel.SpecialSummonStep(c,0,tp,tp,true,false,POS_FACEUP)
		-- 这个效果特殊召唤的这张卡不受怪兽的效果影响
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_IMMUNE_EFFECT)
		e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetRange(LOCATION_MZONE)
		e2:SetValue(c35035481.efilter)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 从场上离开的场合除外。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e3:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e3,true)
		-- 完成特殊召唤流程，使本次特殊召唤正式生效。
		Duel.SpecialSummonComplete()
	end
end
-- 免疫判定函数：只有“怪兽的效果”才会被免疫。
function c35035481.efilter(e,re)
	return re:IsActiveType(TYPE_MONSTER)
end
