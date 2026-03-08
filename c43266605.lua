--PSYフレーム・マルチスレッダー
-- 效果：
-- 「PSY骨架多线人」的③的效果1回合只能使用1次。
-- ①：这张卡只要在手卡·墓地存在，当作「PSY骨架驱动者」使用。
-- ②：自己场上的「PSY骨架」卡被战斗·效果破坏的场合，可以作为代替把手卡的这张卡丢弃。
-- ③：这张卡在墓地存在，自己场上有「PSY骨架」调整特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
function c43266605.initial_effect(c)
	-- 使此卡在手牌或墓地时视为「PSY骨架驱动者」
	aux.EnableChangeCode(c,49036338,LOCATION_HAND+LOCATION_GRAVE)
	-- 注册一个效果，用于检测此卡是否已送入过墓地
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
	-- ③：这张卡在墓地存在，自己场上有「PSY骨架」调整特殊召唤的场合才能发动。这张卡从墓地特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
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
-- 用于判断是否为「PSY骨架」族且正面表示在场上的卡，并且是因战斗或效果破坏而非代替破坏
function c43266605.repfilter(c,tp)
	return c:IsFaceup() and c:IsSetCard(0xc1) and c:IsOnField() and c:IsControler(tp) and c:IsReason(REASON_EFFECT+REASON_BATTLE) and not c:IsReason(REASON_REPLACE)
end
-- 判断是否满足代替破坏的条件，即此卡在手牌且可丢弃，并且有符合条件的「PSY骨架」卡被破坏
function c43266605.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and eg:IsExists(c43266605.repfilter,1,nil,tp) end
	-- 询问玩家是否发动此卡的代替破坏效果
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
-- 返回是否满足代替破坏条件的卡
function c43266605.repval(e,c)
	return c43266605.repfilter(c,e:GetHandlerPlayer())
end
-- 执行代替破坏操作，将此卡送去墓地
function c43266605.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 将此卡以效果、丢弃、代替的理由送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT+REASON_DISCARD+REASON_REPLACE)
end
-- 用于判断是否为「PSY骨架」族调整且控制者为玩家的卡
function c43266605.cfilter(c,tp,se)
	return c:IsSetCard(0xc1) and c:IsType(TYPE_TUNER) and c:IsControler(tp)
		and (se==nil or c:GetReasonEffect()~=se)
end
-- 判断是否满足特殊召唤条件，即有符合条件的「PSY骨架」调整被特殊召唤
function c43266605.spcon(e,tp,eg,ep,ev,re,r,rp)
	local se=e:GetLabelObject():GetLabelObject()
	return eg:IsExists(c43266605.cfilter,1,nil,tp,se)
end
-- 判断是否可以发动特殊召唤效果，即场上存在空位且此卡可特殊召唤
function c43266605.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤操作，并注册离场时除外的效果
function c43266605.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断此卡是否可以特殊召唤并执行特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 特殊召唤后，注册此卡离场时除外的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
