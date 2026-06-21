--VS ヘヴィ・ボーガー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次，同一连锁上不能发动。
-- ①：自己·对方的主要阶段，以机械族以外的自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。
-- ●暗：自己从卡组抽1张。
-- ●地·炎：给与对方1500伤害。
function c92895501.initial_effect(c)
	-- ①：自己·对方的主要阶段，以机械族以外的自己场上1只「征服斗魂」怪兽为对象才能发动。那只怪兽回到手卡，这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92895501,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,92895501)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCondition(c92895501.spcon)
	e1:SetTarget(c92895501.sptg)
	e1:SetOperation(c92895501.spop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●暗：自己从卡组抽1张。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92895501,1))  --"展示暗属性的怪兽"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,92895502)
	e2:SetHintTiming(0,TIMING_END_PHASE)
	e2:SetCost(c92895501.drcost)
	e2:SetTarget(c92895501.drtg)
	e2:SetOperation(c92895501.drop)
	c:RegisterEffect(e2)
	-- ②：自己·对方回合，可以从以下选择1个，把那属性的手卡的怪兽各1只给对方观看发动。●地·炎：给与对方1500伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(92895501,2))  --"展示地·炎属性的怪兽"
	e3:SetCategory(CATEGORY_DAMAGE)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_FREE_CHAIN)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,92895502)
	e3:SetHintTiming(0,TIMING_END_PHASE)
	e3:SetCost(c92895501.dmgcost)
	e3:SetTarget(c92895501.dmgtg)
	e3:SetOperation(c92895501.dmgop)
	c:RegisterEffect(e3)
end
-- ①号效果的发动条件判定函数
function c92895501.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己或对方的主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- ①号效果的对象怪兽过滤条件：自己场上表侧表示的、机械族以外的「征服斗魂」怪兽，且能回到手卡，并且有可用的怪兽区域
function c92895501.spfilter(c,tp)
	return c:IsSetCard(0x195) and c:IsFaceup() and c:IsAbleToHand() and not c:IsRace(RACE_MACHINE)
		-- 判断该怪兽离开场后，自己场上是否有可用于特殊召唤的怪兽区域
		and Duel.GetMZoneCount(tp,c)>0
end
-- ①号效果的发动准备（Target）
function c92895501.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c92895501.spfilter(chkc,tp) end
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		-- 检查自己场上是否存在满足条件的、可作为对象的怪兽
		and Duel.IsExistingTarget(c92895501.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
		-- 检查当前连锁中是否尚未发动过该卡的效果（用于实现同一连锁上不能发动的限制）
		and Duel.GetFlagEffect(tp,92895501)==0 end
	-- 在当前连锁中注册标识，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,92895501,RESET_CHAIN,0,1)
	-- 提示玩家选择要返回手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择自己场上1只满足条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c92895501.spfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息：将选中的怪兽送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 设置效果处理信息：将这张卡特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①号效果的效果处理（Operation）
function c92895501.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍与连锁相关，则将其送回持有者手卡
	if tc:IsRelateToChain() and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0
		and tc:IsLocation(LOCATION_HAND) and c:IsRelateToChain() then
		-- 将手卡的这张卡表侧表示特殊召唤
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②号效果（暗属性）的展示怪兽过滤条件：手卡中未公开的暗属性怪兽
function c92895501.drcfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and not c:IsPublic()
end
-- ②号效果（暗属性）的发动代价（Cost）
function c92895501.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1只未公开的暗属性怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c92895501.drcfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中1只未公开的暗属性怪兽
	local g=Duel.SelectMatchingCard(tp,c92895501.drcfilter,tp,LOCATION_HAND,0,1,1,nil)
	-- 将选中的怪兽给对方观看确认
	Duel.ConfirmCards(1-tp,g)
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(g,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	Duel.ShuffleHand(tp)
end
-- ②号效果（暗属性）的发动准备（Target）
function c92895501.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己是否可以从卡组抽卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 检查当前连锁中是否尚未发动过该卡的效果（用于实现同一连锁上不能发动的限制）
		and Duel.GetFlagEffect(tp,92895501)==0 end
	-- 在当前连锁中注册标识，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,92895501,RESET_CHAIN,0,1)
	-- 设置效果处理的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为1（抽1张卡）
	Duel.SetTargetParam(1)
	-- 设置效果处理信息：自己从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②号效果（暗属性）的效果处理（Operation）
function c92895501.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标玩家和抽卡数量
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家因效果抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- ②号效果（地·炎属性）的展示怪兽过滤条件：手卡中未公开的地属性或炎属性怪兽
function c92895501.dmgcfilter(c)
	return c:IsAttribute(ATTRIBUTE_EARTH+ATTRIBUTE_FIRE) and not c:IsPublic()
end
-- ②号效果（地·炎属性）的发动代价（Cost）
function c92895501.dmgcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取手卡中所有未公开的地属性和炎属性怪兽
	local g=Duel.GetMatchingGroup(c92895501.dmgcfilter,tp,LOCATION_HAND,0,nil)
	-- 检查手卡中是否存在地属性和炎属性怪兽各1只
	if chk==0 then return g:CheckSubGroup(aux.gfcheck,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE) end
	-- 提示玩家选择要给对方确认的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 选择手卡中地属性和炎属性的怪兽各1只
	local sg=g:SelectSubGroup(tp,aux.gfcheck,false,2,2,Card.IsAttribute,ATTRIBUTE_EARTH,ATTRIBUTE_FIRE)
	-- 将选中的2只怪兽给对方观看确认
	Duel.ConfirmCards(1-tp,sg)
	if e:GetHandler():IsSetCard(0x195) then Duel.RaiseEvent(sg,EVENT_CUSTOM+9091064,e,REASON_COST,tp,tp,0) end
	Duel.ShuffleHand(tp)
end
-- ②号效果（地·炎属性）的发动准备（Target）
function c92895501.dmgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查当前连锁中是否尚未发动过该卡的效果（用于实现同一连锁上不能发动的限制）
	if chk==0 then return Duel.GetFlagEffect(tp,92895501)==0 end
	-- 在当前连锁中注册标识，防止同一连锁重复发动
	Duel.RegisterFlagEffect(tp,92895501,RESET_CHAIN,0,1)
	-- 设置效果处理的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置效果处理的目标参数为1500（伤害值）
	Duel.SetTargetParam(1500)
	-- 设置效果处理信息：给与对方1500伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1500)
end
-- ②号效果（地·炎属性）的效果处理（Operation）
function c92895501.dmgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理的目标玩家和伤害数值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 给与目标玩家因效果造成的伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
