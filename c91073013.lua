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
-- 特殊召唤效果的条件判断
function c91073013.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段是主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 作为对象的自己场上的「征服斗魂」怪兽过滤条件：龙族以外、表侧表示、能回到手卡且满足出场位置
function c91073013.spfilter(c,tp)
	return c:IsSetCard(0x195) and c:IsFaceup() and c:IsAbleToHand() and not c:IsRace(RACE_DRAGON)
		-- 该怪兽回到手卡后，自己场上有可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤效果的目标判定（包括取对象检测）
function c91073013.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c91073013.spfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 自己场上存在可以作为此效果对象的龙族以外的「征服斗魂」怪兽
		and Duel.IsExistingTarget(c91073013.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 同一连锁上还没有发动过此卡的效果
		and Duel.GetFlagEffect(tp,91073013)==0 end
	-- 给玩家注册在该连锁中已发动过该卡效果的标记（同一连锁不能重复发动）
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
	-- 提示玩家选择要回到手卡的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上一只龙族以外的「征服斗魂」怪兽作为对象
	local g=Duel.SelectTarget(tp,c91073013.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置操作信息：对象怪兽回到手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置操作信息：这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 特殊召唤效果的操作处理
function c91073013.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的那只怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍和连锁相关则送回持有者手卡
	if tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() then
		-- 将这张卡从手卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤手卡中未展示的地属性怪兽
function c91073013.imcfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH) and not c:IsPublic()
end
-- 抗性效果的发动代价：展示手卡中1只地属性怪兽
function c91073013.imcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断手卡中是否存在未展示的地属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c91073013.imcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要展示的地属性怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择自己手卡中1只未展示的地属性怪兽
	local g=Duel.SelectMatchingCard(tp,c91073013.imcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 向对方玩家展示选中的怪兽
	Duel.ConfirmCards(1-tp,g)
	-- 若此卡是「征服斗魂」怪兽，触发展示卡片的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将自己手卡洗牌
	Duel.ShuffleHand(tp)
end
-- 抗性效果的目标判定与连锁判定
function c91073013.imtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断同一连锁上是否还未发动过此卡的效果
	if chk==0 then return Duel.GetFlagEffect(tp,91073013)==0 end
	-- 给玩家注册在该连锁中已发动过该卡效果的标记（同一连锁不能重复发动）
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
end
-- 抗性效果的操作处理
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
-- 抗性过滤条件：不受对方发动的效果影响
function c91073013.efilter(e,re)
	return e:GetHandlerPlayer()~=re:GetOwnerPlayer() and re:IsActivated()
end
-- 过滤手卡中未展示的地、暗、炎属性怪兽
function c91073013.descfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_DARK+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- 破坏效果的发动代价：展示手卡中地、炎、暗属性的怪兽各1只
function c91073013.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中未展示的地、暗、炎属性怪兽
	local g=Duel.GetMatchingGroup(c91073013.descfilter,tp,LOCATION_HAND,0,nil)
	-- 判断是否存在地、炎、暗属性怪兽各1只的组合
	if chk==0 then return g:CheckSubGroup(aux.dabcheck,3,3) end
	-- 提示玩家选择要展示的3只怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择属性各不相同的3只手卡怪兽（地、炎、暗各1只）
	local sg=g:SelectSubGroup(tp,aux.dabcheck,false,3,3)
	-- 向对方玩家展示这3只怪兽
	Duel.ConfirmCards(1-tp,sg)
	-- 若此卡是「征服斗魂」怪兽，触发展示卡片的自定义事件
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	-- 将自己手卡洗牌
	Duel.ShuffleHand(tp)
end
-- 破坏效果的目标判定与连锁判定
function c91073013.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取场上除这张卡以外的所有卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 判断场上是否存在其他卡片可以被破坏，并且同一连锁上没有发动过此卡的效果
	if chk==0 then return #g>0 and Duel.GetFlagEffect(tp,91073013)==0 end
	-- 给玩家注册在该连锁中已发动过该卡效果的标记（同一连锁不能重复发动）
	Duel.RegisterFlagEffect(tp,91073013,RESET_CHAIN,0,1)
	-- 设置操作信息：破坏场上1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的操作处理
function c91073013.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not e:GetHandler():IsRelateToChain() then c=nil end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1张其他卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
	if #g>0 then
		-- 给被选为对象的卡显示选择状态动画
		Duel.HintSelection(g)
		-- 将选中的卡破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
end
