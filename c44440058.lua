--ネメシス・キーストーン
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以「星义关键兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
-- ②：这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
function c44440058.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以「星义关键兽」以外的除外的1只自己怪兽为对象才能发动。这张卡从手卡特殊召唤，作为对象的怪兽回到卡组。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(44440058,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TODECK)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,44440058)
	e1:SetTarget(c44440058.sptg)
	e1:SetOperation(c44440058.spop)
	c:RegisterEffect(e1)
	-- 这张卡被除外的回合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_REMOVE)
	e2:SetOperation(c44440058.regop)
	c:RegisterEffect(e2)
	-- ②：这张卡被除外的回合的结束阶段才能发动。这张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(44440058,1))
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCountLimit(1,44440059)
	e3:SetCondition(c44440058.thcon)
	e3:SetTarget(c44440058.thtg)
	e3:SetOperation(c44440058.thop)
	c:RegisterEffect(e3)
end
-- 筛选可作为①对象的除外区自己怪兽：需表侧表示、是怪兽、不是「星义关键兽」本身，并且可以返回卡组。
function c44440058.tdfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER) and not c:IsCode(44440058) and c:IsAbleToDeck()
end
-- ①的取对象与发动判定：若在连锁处理中指定对象，则校验该对象位于除外区、为己方控制且满足筛选条件；发动时需确认主怪兽区有空位、此卡可特殊召唤，且除外区存在满足条件的对象。
function c44440058.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c44440058.tdfilter(chkc) end
	-- 发动条件检查之一：自己场上的主要怪兽区必须存在可用空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 且除外区存在至少1张满足条件的自己怪兽可以作为对象。
		and Duel.IsExistingTarget(c44440058.tdfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向操作玩家显示选择提示，提示文本为‘请选择要返回卡组的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家从自己除外区选择1张满足条件的怪兽作为效果对象，并登记为连锁对象。
	local g=Duel.SelectTarget(tp,c44440058.tdfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：本连锁包含特殊召唤，预定特殊召唤的卡为此卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	-- 设置操作信息：本连锁包含返回卡组，预定返回卡组的卡为选中的对象。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ①效果处理：若此卡仍与效果关联，则特殊召唤此卡；若特殊召唤成功且对象仍与效果关联，将对象返回卡组并洗牌。
function c44440058.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的1张对象卡。
	local tc=Duel.GetFirstTarget()
	-- 判断此卡仍与效果关联，尝试特殊召唤此卡且特殊召唤成功，并确认对象卡仍与效果关联。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 and tc:IsRelateToEffect(e) then
		-- 将对象卡返回持有者卡组并洗牌。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
-- 被除外时给此卡注册标识，记录本回合被除外过，用于②的发动条件。
function c44440058.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(44440058,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- ②的发动条件：检查此卡是否带有被除外的标识（即本回合被除外过）。
function c44440058.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(44440058)>0
end
-- ②的发动条件检查：确认此卡可以加入手卡；同时设置回手牌的操作信息。
function c44440058.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息：本连锁包含回手牌，目标为此卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍与效果关联，则将此卡加入持有者手卡。
function c44440058.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将此卡加入持有者手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
