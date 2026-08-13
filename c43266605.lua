--PSYフレーム・マルチスレッダー
-- 效果：
-- 「PSY骨架多线人」的③的效果1回合只能使用1次。
-- ①：这张卡只要在手卡·墓地存在，当作「PSY骨架驱动者」使用。
-- ②：自己场上的「PSY骨架」卡被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ③：这张卡在墓地存在，自己场上有「PSY骨架」调整特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43266605.initial_effect(c)
	-- 调用Auxiliary.EnableChangeCode使这张卡在手卡·墓地存在时当作「PSY骨架驱动者」（卡号49036338）使用（对应①效果）。
	aux.EnableChangeCode(c,49036338,LOCATION_HAND+LOCATION_GRAVE)
	-- 注册“此卡已在墓地”的标记检测效果，用于③效果发动时准确判断此卡是否在墓地，并避免同一连锁中的重复判定。
	local e0=aux.AddThisCardInGraveAlreadyCheck(c)
	-- ②：自己场上的「PSY骨架」卡被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_HAND)
	e2:SetTarget(c43266605.reptg)
	e2:SetValue(c43266605.repval)
	e2:SetOperation(c43266605.repop)
	c:RegisterEffect(e2)
	-- 「PSY骨架多线人」的③的效果1回合只能使用1次。③：这张卡在墓地存在，自己场上有「PSY骨架」调整特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43266605,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,43266605)
	e3:SetLabelObject(e0)
	e3:SetCondition(c43266605.spcon)
	e3:SetTarget(c43266605.sptg)
	e3:SetOperation(c43266605.spop)
	c:RegisterEffect(e3)
end
-- 判断被破坏的怪兽是否为满足条件的己方「PSY骨架」卡：表侧表示、在场上、由战斗或效果破坏且不是代替破坏。
function c43266605.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc1) and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- ②效果是否能发动的判定：手卡的这张卡可以丢弃、未被预定破坏，且本次被破坏的怪兽中存在满足repfilter条件的「PSY骨架」卡。
function c43266605.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c43266605.repfilter,1,nil,tp) end
	-- 弹出选择询问，让玩家决定是否丢弃手卡的这张卡作为代替破坏。
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 作为EFFECT_DESTROY_REPLACE的Value函数，判断被破坏的怪兽是否可由这张卡的丢弃代替破坏。
function c43266605.repval(e,c)
	return c43266605.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏的代价：丢弃手卡的这张卡（将其送去墓地）。
function c43266605.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将手卡的这张卡丢弃送去墓地，作为代替破坏的处理。
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD+REASON_REPLACE)
end
-- 判断特殊召唤的怪兽是否满足条件：自己场上的「PSY骨架」调整，且该特殊召唤不是由本卡③效果自身发动的特殊召唤（避免循环触发）。
function c43266605.cfilter(c,tp,se)
	return c:IsSetCard(0xc1) and c:IsType(TYPE_TUNER) and c:IsControler(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- ③效果的发动条件：本次特殊召唤成功的怪兽中存在自己场上的「PSY骨架」调整，且不是由这张卡自身③效果特殊召唤的，同时这张卡在墓地存在。
function c43266605.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c43266605.cfilter,1,nil,tp,se)
end
-- ③效果的发动条件：自己场上有可用主要怪兽区空格，且墓地中的这张卡能够被特殊召唤。
function c43266605.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己场上存在空余的主要怪兽区域，用于放置③效果特殊召唤的这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本连锁将进行特殊召唤（对象为墓地中的这张卡），供相关卡片和规则检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ③效果处理：特殊召唤墓地中的这张卡，若成功则给它赋予“从场上离开的场合除外”的效果。
function c43266605.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡仍与本效果相关且特殊召唤成功，才继续赋予离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
