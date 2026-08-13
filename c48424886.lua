--エルシャドール・エグリスタ
-- 效果：
-- 「影依」怪兽＋炎属性怪兽
-- 这张卡用融合召唤才能从额外卡组特殊召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
function c48424886.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡设定「影依」怪兽＋炎属性怪兽的融合素材（使用影依专用融合召唤手续）。
	aux.AddFusionProcShaddoll(c,ATTRIBUTE_FIRE)
	-- 这张卡用融合召唤才能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetRange(LOCATION_EXTRA)
	e2:SetValue(c48424886.splimit)
	c:RegisterEffect(e2)
	-- 这个卡名的①的效果1回合只能使用1次。①：对方把怪兽特殊召唤之际才能发动。那次特殊召唤无效，那些怪兽破坏。那之后，从自己手卡选1张「影依」卡送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48424886,0))  --"无效并破坏"
	e3:SetCategory(CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_SPSUMMON)
	e3:SetCountLimit(1,48424886)
	e3:SetCondition(c48424886.condition)
	e3:SetTarget(c48424886.target)
	e3:SetOperation(c48424886.operation)
	c:RegisterEffect(e3)
	-- ②：这张卡被送去墓地的场合，以自己墓地1张「影依」魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(48424886,1))  --"卡片回收"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(c48424886.thtg)
	e4:SetOperation(c48424886.thop)
	c:RegisterEffect(e4)
end
-- 判定特殊召唤是否为融合召唤，仅当召唤类型为融合召唤时才允许进行特殊召唤（对应“用融合召唤才能从额外卡组特殊召唤”的限制）。
function c48424886.splimit(e,se,sp,st)
	return bit.band(st,SUMMON_TYPE_FUSION)==SUMMON_TYPE_FUSION
end
-- ①效果的发动条件：对方进行怪兽特殊召唤之际，且当前连锁为空（不在连锁处理中，直接针对那次特殊召唤发动）。
function c48424886.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 当进行特殊召唤的玩家是对方（tp≠ep）且当前没有处于连锁处理中时，条件成立。
	return tp~=ep and Duel.GetCurrentChain()==0
end
-- 筛选持有「影依」字段的卡片（用于从手卡选择1张「影依」卡）。
function c48424886.filter(c)
	return c:IsSetCard(0x9d)
end
-- ①效果发动时的处理：确认己方手牌存在「影依」卡，并将对方这次特殊召唤的怪兽群登记为无效召唤与破坏的对象。
function c48424886.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时检查：己方手牌是否存在至少1张「影依」卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c48424886.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置操作信息：将对方即将特殊召唤的怪兽群登记为将被无效召唤的对象。
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,eg:GetCount(),0,0)
	-- 设置操作信息：将对方即将特殊召唤的怪兽群登记为将被破坏的对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,eg:GetCount(),0,0)
end
-- ①效果处理：使对方那次特殊召唤无效并破坏那些怪兽，然后从自己手卡选1张「影依」卡送去墓地。
function c48424886.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让对方正在进行的特殊召唤无效（对应“那次特殊召唤无效”）。
	Duel.NegateSummon(eg)
	-- 将特殊召唤被无效的那些怪兽破坏（对应“那些怪兽破坏”）。
	Duel.Destroy(eg,REASON_EFFECT)
	-- 弹出提示，让己方选择要送去墓地的「影依」卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从己方手卡选择1张「影依」卡（后续将其送去墓地）。
	local g=Duel.SelectMatchingCard(tp,c48424886.filter,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 中断当前效果处理，使后续的送墓处理与之前的无效·破坏视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		-- 将选择的「影依」卡从手卡送去墓地（对应“从自己手卡选1张「影依」卡送去墓地”）。
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
-- 筛选自己墓地中持有「影依」字段的魔法·陷阱卡，且该卡能够加入手卡。
function c48424886.thfilter(c)
	return c:IsSetCard(0x9d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- ②效果发动时的处理：从自己墓地选择1张「影依」魔法·陷阱卡为对象，并设置将其加入手卡的操作信息。
function c48424886.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c48424886.thfilter(chkc) end
	-- 发动时检查：自己墓地是否存在至少1张符合条件的「影依」魔法·陷阱卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c48424886.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 弹出提示，让己方选择要加入手卡的「影依」魔法·陷阱卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张符合条件的「影依」魔法·陷阱卡作为效果对象。
	local g=Duel.SelectTarget(tp,c48424886.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：登记将对象卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ②效果处理：将对象化的墓地「影依」魔法·陷阱卡加入手卡。
function c48424886.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理时仍与效果关联的对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该对象卡加入持有者的手卡（对应“那张卡加入手卡”）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
