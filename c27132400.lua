--オルターガイスト・マルウィスプ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：这张卡召唤·特殊召唤的场合，以「幻变骚灵·恶意软件鬼火」以外的自己墓地1只「幻变骚灵」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
local s,id,o=GetID()
-- 注册①②两个效果：①为加入手卡时触发的选发特殊召唤效果，②为召唤/特殊召唤成功时触发的选发取对象效果；②通过克隆分别注册了通常召唤成功和特殊召唤成功两个触发实例，并共用同一回合次数限制。
function s.initial_effect(c)
	-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤的场合，以「幻变骚灵·恶意软件鬼火」以外的自己墓地1只「幻变骚灵」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡加入手卡的原因不是抽卡，即满足“用抽卡以外的方法加入手卡”的场合。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- ①效果发动时的合法性检查：自身所在区域有可用的主要怪兽区空格，且这张卡能够被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空余的主要怪兽区格子可以用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将操作信息登记为特殊召唤这张卡自身，数量为1，以便触发相关卡片的应对和时点判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与发动的效果保持关联，则将其表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡在处理时没有离开过当前区域且仍与效果关联，然后以表侧攻击表示（POS_FACEUP）特殊召唤这张卡。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的选对象筛选条件：墓地中存在「幻变骚灵」系列怪兽、不是这张卡同名卡，并且可以表侧守备表示特殊召唤。
function s.filter(c,e,tp)
	return c:IsSetCard(0x103) and not c:IsCode(id)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- ②效果的发动合法性检查和取对象处理：先检查主怪兽区有空位且墓地存在符合条件的对象，再在发动时选择1只作为对象。
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	-- 检查自己场上是否有空余的主要怪兽区格子可以用于特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己墓地中是否存在1只满足s.filter条件的「幻变骚灵」怪兽可以作为对象。
		and Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示消息，提示内容是“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地的符合条件的怪兽中选择1只作为效果对象，并自动将其与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 将操作信息登记为特殊召唤所选择的对象怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- ②效果处理：将对象怪兽表侧守备表示特殊召唤，成功后为那只怪兽附加本回合不能发动效果的永续效果。
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 确认对象怪兽仍与效果关联，且不受王家长眠之谷等墓地效果限制的影响，才能进行墓地特殊召唤。
	if tc:IsRelateToEffect(e) and aux.NecroValleyFilter()(tc)
		-- 以表侧守备表示进行特殊召唤步骤，若成功则继续附加不能发动效果的限制；此步骤需配合SpecialSummonComplete完成。
		and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 这个回合，这个效果特殊召唤的怪兽的效果不能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))  --"「幻变骚灵·恶意软件鬼火」效果适用中"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 结束本次特殊召唤的分解处理，完成特殊召唤并触发召唤成功时点。
	Duel.SpecialSummonComplete()
end
