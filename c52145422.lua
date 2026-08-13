--グレイドル・ドラゴン
-- 效果：
-- 水族调整＋调整以外的怪兽1只以上
-- 「灰篮龙」的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤成功时，以最多有那些作为同调素材的水属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。
-- ②：这张卡被战斗·效果破坏送去墓地的场合，以这张卡以外的自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。
function c52145422.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为水族怪兽，调整以外怪兽任意（至少1只），对应召唤条件“水族调整＋调整以外的怪兽1只以上”。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_AQUA),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应①效果：“①：这张卡同调召唤时，以最多有那些作为同调素材的水属性怪兽数量的对方场上的卡为对象才能发动。那些卡破坏。”创建并注册该效果，同时实现发动条件、对象选择和破坏处理。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,52145422)
	e1:SetCondition(c52145422.descon)
	e1:SetTarget(c52145422.destg)
	e1:SetOperation(c52145422.desop)
	c:RegisterEffect(e1)
	-- 对应①效果中“以最多有那些作为同调素材的水属性怪兽数量”：通过EFFECT_MATERIAL_CHECK在同调召唤时记录素材中的水属性怪兽数量，并存入①效果的Label中，用于决定可破坏卡的张数。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(c52145422.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	-- 对应②效果：“②：这张卡被战斗·效果破坏送去墓地的场合，以这张卡以外的自己墓地1只水属性怪兽为对象才能发动。那只怪兽特殊召唤。这个效果特殊召唤的怪兽的效果无效化。”创建并注册该效果，包含发动条件、对象选择、特殊召唤和无效化处理。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCountLimit(1,52145423)
	e3:SetCondition(c52145422.spcon)
	e3:SetTarget(c52145422.sptg)
	e3:SetOperation(c52145422.spop)
	c:RegisterEffect(e3)
end
-- EFFECT_MATERIAL_CHECK的效果值函数：取得这张卡的同调素材，统计其中水属性怪兽的数量，并通过SetLabel将这个数量写入①效果e1的Label中，供①效果选择破坏对象数量使用。
function c52145422.valcheck(e,c)
	local ct=e:GetHandler():GetMaterial():FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)
	e:GetLabelObject():SetLabel(ct)
end
-- 效果①的发动条件：判断这张卡是否是以同调召唤的方式特殊召唤成功（SUMMON_TYPE_SYNCHRO）。
function c52145422.descon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 效果①的发动时目标选择与合法性判定：选择对方场上的卡为对象，数量为记录的水属性素材数ct（最多ct张，至少1张）；若在连锁处理时检查对象，则对象必须在对方场上；满足条件后提示选择并设定破坏操作信息。
function c52145422.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local ct=e:GetLabel()
	-- 发动时点合法性检查：要求记录的水属性素材数量ct>0，且对方场上有至少1张可以成为对象的卡。
	if chk==0 then return ct>0 and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 向玩家tp显示选择提示，提示内容为“请选择要破坏的卡”（HINTMSG_DESTROY），用于引导选择对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1到ct张任意卡（aux.TRUE表示无条件）作为效果对象，并自动将这些卡登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,ct,nil)
	-- 设置当前连锁的操作信息：效果类别为破坏（CATEGORY_DESTROY），对象为已选择的g，数量为g的数量，供其他卡片响应破坏效果时使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- 效果①的破坏处理：获取连锁中仍与效果相关的对象卡，若存在则全部以效果破坏（REASON_EFFECT）。
function c52145422.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出发动时选择的对象卡组，再用Card.IsRelateToEffect筛选出仍然与效果e有联系的对象（未被无效、未脱离联系）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if g:GetCount()>0 then
		-- 以效果破坏（REASON_EFFECT）方式将这些对象卡全部破坏。
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- 效果②的发动条件：这张卡被破坏（REASON_DESTROY）且破坏原因为战斗或效果（REASON_BATTLE+REASON_EFFECT）后送去墓地。
function c52145422.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_DESTROY) and e:GetHandler():IsReason(REASON_BATTLE+REASON_EFFECT)
end
-- 墓地水属性怪兽的过滤条件：该怪兽是水属性，且可以被效果e通常特殊召唤（不忽略召唤条件和苏生限制）。
function c52145422.filter(c,e,tp)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果②的发动时目标选择与合法性判定：选择自己墓地1只除这张卡以外的水属性怪兽为对象；检查自己场上有空位且墓地存在符合条件的对象；连锁处理时验证对象仍符合条件且不是这张卡。
function c52145422.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c52145422.filter(chkc,e,tp) and chkc~=e:GetHandler() end
	-- 效果②发动时点的合法性检查：自己主要怪兽区必须有至少1个可用空格，否则无法特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查之二：自己墓地存在至少1只除了这张卡以外、满足filter条件且能特殊召唤的水属性怪兽。
		and Duel.IsExistingTarget(c52145422.filter,tp,LOCATION_GRAVE,0,1,e:GetHandler(),e,tp) end
	-- 向玩家tp显示选择提示，提示内容为“请选择要特殊召唤的卡”（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张符合条件的怪兽作为效果对象，并自动登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c52145422.filter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler(),e,tp)
	-- 设置当前连锁的操作信息：类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），对象为g，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的特殊召唤处理：将对象怪兽特殊召唤，若成功则给它附加EFFECT_DISABLE和EFFECT_DISABLE_EFFECT使其效果无效化，最后完成分步特殊召唤。
function c52145422.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的第一个对象卡（即选中的墓地水属性怪兽）。
	local tc=Duel.GetFirstTarget()
	-- 判断对象卡与效果仍有联系且可以特殊召唤；若可以，则用SpecialSummonStep将其正面表示特殊召唤到tp场上，并继续附加无效化效果。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		-- 对应“这个效果特殊召唤的怪兽的效果无效化”：给特殊召唤的怪兽注册EFFECT_DISABLE，使其效果无效化。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		-- 对应“这个效果特殊召唤的怪兽的效果无效化”：再给该怪兽注册EFFECT_DISABLE_EFFECT，使其在场上发动的效果也被无效化。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e2)
	end
	-- 调用SpecialSummonComplete结束分步特殊召唤，正式完成特殊召唤并触发相关时点。
	Duel.SpecialSummonComplete()
end
