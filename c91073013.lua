--VS 龍帝ヴァリウス
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己·对方的主要阶段，以龙族以外的自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●地：这个回合，表侧表示的这张卡不受对方发动的效果影响。
-- ●地·炎·暗：选场上1张其他卡破坏。
function c91073013.initial_effect(c)
	-- ①：自己·对方的主要阶段，以龙族以外的自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91073013,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,91073013)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c91073013.spcon)
	e1:SetTarget(c91073013.sptg)
	e1:SetOperation(c91073013.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地：这个回合，表侧表示的这张卡不受对方发动的效果影响。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(91073013,1))  --"展示地属性的怪兽"
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,91073014)
	e2:SetCost(c91073013.imcost)
	e2:SetTarget(c91073013.imtg)
	e2:SetOperation(c91073013.imop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地·炎·暗：选场上1张其他卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(91073013,2))  --"展示地·炎·暗属性的怪兽"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,91073014)
	e3:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e3:SetCost(c91073013.descost)
	e3:SetTarget(c91073013.destg)
	e3:SetOperation(c91073013.desop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件函数
function c91073013.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤满足作为①号效果对象的「征服斗魂」怪兽的条件：场上表侧表示、能回到手卡、非龙族，且其离开后能腾出怪兽区域
function c91073013.spfilter(c,tp)
	return c:IsSetCard(0x195) and c:IsFaceup() and c:IsAbleToHand() and not c:IsRace(RACE_DRAGON)
		-- 判定该怪兽回到手卡后，自己场上是否有可用于特殊召唤的空余怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①号效果的发动准备与目标选择函数
function c91073013.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c91073013.spfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在满足条件的「征服斗魂」怪兽作为对象
		and Duel.IsExistingTarget(c91073013.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查当前连锁中是否尚未发动过该卡的效果（用于限制同一连锁不能发动）
		and Duel.GetFlagEffect(tp,91073013)==0 end
	-- 在当前连锁中为玩家注册已发动效果的标记，用于同一连锁不能发动的限制
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
	-- 设置选择卡片时的提示信息为“请选择要返回手牌的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的「征服斗魂」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c91073013.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置连锁信息：操作分类为返回手卡，操作对象为选中的怪兽
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置连锁信息：操作分类为特殊召唤，操作对象为手卡中的这张卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①号效果的执行函数
function c91073013.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与连锁相关，则将其因效果送回持有者手卡，并确认成功回手
	if tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() then
		-- 将这张卡从手卡以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中未公开的地属性怪兽
function c91073013.imcfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
-- ②号效果（地属性分支）的发动代价函数
function c91073013.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查手卡中是否存在至少1只未公开的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91073013.imcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置选择卡片时的提示信息为“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择1只未公开的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c91073013.imcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,g)
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	Duel.ShuffleHand(tp)
end
-- ②号效果（地属性分支）的发动准备与目标确认函数
function c91073013.imtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查当前连锁中是否尚未发动过该卡的效果
	if chk==0 then return Duel.GetFlagEffect(tp,91073013)==0 end
	-- 在当前连锁中为玩家注册已发动效果的标记，用于同一连锁不能发动的限制
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
end
-- ②号效果（地属性分支）的执行函数
function c91073013.imop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToChain() then return end
	-- ●地：这个回合，表侧表示的这张卡不受对方发动的效果影响。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(c91073013.efilter)
	c:RegisterEffect(e1)
end
-- 过滤不受影响的效果：对方玩家拥有的且已发动的效果
function c91073013.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 过滤手卡中未公开的地、炎、暗属性怪兽
function c91073013.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- ②号效果（地·炎·暗属性分支）的发动代价函数
function c91073013.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有未公开的地、炎、暗属性怪兽
	local g=Duel.GetMatchingGroup(c91073013.descfilter,tp,LOCATION_HAND,0,nil)
	-- 在发动准备阶段，检查手卡中是否存在地、炎、暗属性各1只（共3只不同属性）的怪兽
	if chk==0 then return g:CheckSubGroup(aux.dabcheck,3,3) end
	-- 设置选择卡片时的提示信息为“请选择给对方确认的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从手卡中选择地、炎、暗属性各1只（共3只不同属性）的怪兽
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,3,3)
	-- 将选中的3只怪兽给对方玩家确认
	Duel.ConfirmCards(1-tp,sg)
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	Duel.ShuffleHand(tp)
end
-- ②号效果（地·炎·暗属性分支）的发动准备与目标确认函数
function c91073013.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 在发动准备阶段，检查场上是否存在其他卡片，且当前连锁中尚未发动过该卡的效果
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,91073013)==0 end
	-- 在当前连锁中为玩家注册已发动效果的标记，用于同一连锁不能发动的限制
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
	-- 设置连锁信息：操作分类为破坏，操作数量为1
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②号效果（地·炎·暗属性分支）的执行函数
function c91073013.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToChain() then c=nil end
	-- 设置选择卡片时的提示信息为“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上除这张卡以外的1张卡片
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	if #g>0 then
		-- 给选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 将选中的卡片因效果破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
