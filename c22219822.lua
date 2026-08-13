--トリックスター・マンドレイク
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡从手卡送去墓地的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合，以对方的连接怪兽的所连接区1只怪兽为对象才能发动。那只怪兽破坏。
function c22219822.initial_effect(c)
	-- ①：这张卡从手卡送去墓地的场合才能发动。这张卡守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合除外。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(22219822,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,22219822)
	e1:SetCondition(c22219822.spcon)
	e1:SetTarget(c22219822.sptg)
	e1:SetOperation(c22219822.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合，以对方的连接怪兽的所连接区1只怪兽为对象才能发动。那只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(22219822,1))  --"怪兽破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCountLimit(1,22219823)
	e2:SetCondition(c22219822.descon)
	e2:SetTarget(c22219822.destg)
	e2:SetOperation(c22219822.desop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：确认这张卡是从手牌送去墓地（之前的位置是手牌），满足“从手卡送去墓地的场合”。
function c22219822.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- ①效果的发动目标判定：仅在效果发动时（chk==0）检查自己场上是否存在可用怪兽区，且这张卡能否以表侧守备表示作特殊召唤；满足则允许发动。
function c22219822.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有空的怪兽区域，保证有位置进行特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 将本次连锁的操作信息设定为“特殊召唤这张卡”，供后续效果处理及卡组联动检测使用。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果关联，将其以表侧守备表示特殊召唤；成功后给这张卡附加一个“从场上离开时改为除外”的代替去向效果。
function c22219822.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断这张卡是否仍与当前效果关联，且特殊召唤是否成功（返回值非0）；只有成功时才给其附加离场除外效果。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- ①：这个效果特殊召唤的这张卡从场上离开的场合除外。②：这张卡作为「淘气仙星」连接怪兽的连接素材送去墓地的场合，以对方的连接怪兽的所连接区1只怪兽为对象才能发动。那只怪兽破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
-- ②效果的发动条件：这张卡在墓地，且是作为连接素材被送去墓地，并且导致其作为素材的连接怪兽卡名含有「淘气仙星」系列。
function c22219822.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfb)
end
-- 过滤条件：筛选出表侧表示且为连接怪兽的卡。
function c22219822.lkfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- ②效果的目标选择：收集对方场上所有表侧连接怪兽所连接区的怪兽作为可能对象；若指定对象则验证其可被选为对象；在无对象时检查是否存在可选择的合法目标；然后让玩家选择1只可被效果破坏的对象，并设定为连锁对象及破坏操作信息。
function c22219822.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tg=Group.CreateGroup()
	-- 获取对方场上所有表侧表示的连接怪兽，作为后续收集所连接区对象的来源。
	local lg=Duel.GetMatchingGroup(c22219822.lkfilter,tp,0,LOCATION_MZONE,nil)
	-- 遍历对方场上的每只连接怪兽，将其所连接区的全部卡合并入可选目标组 tg。
	for tc in aux.Next(lg) do
		tg:Merge(tc:GetLinkedGroup())
	end
	if chkc then return tg:IsContains(chkc) and chkc:IsCanBeEffectTarget(e) end
	if chk==0 then return tg:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	-- 弹出选择提示，要求玩家选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local g=tg:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	-- 将选定的卡登记为当前连锁的效果对象（取对象）。
	Duel.SetTargetCard(g)
	-- 设置本次连锁的操作信息为“破坏这1张卡”，并记录破坏分类。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象卡，若其仍与效果关联，则将其破坏。
function c22219822.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁中登记的第一张对象卡（即玩家选择的破坏对象）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
