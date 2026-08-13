--先史遺産ネブラ・ディスク
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤成功时才能发动。从卡组把「先史遗产 内布拉星象盘」以外的1张「先史遗产」卡加入手卡。
-- ②：这张卡在墓地存在，自己场上的怪兽只有「先史遗产」怪兽的场合才能发动。这张卡守备表示特殊召唤。这个效果发动的回合，自己不能把「先史遗产」卡以外的卡的效果发动。
function c24861088.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：这张卡召唤成功时才能发动。从卡组把「先史遗产 内布拉星象盘」以外的1张「先史遗产」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(24861088,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,24861088)
	e1:SetTarget(c24861088.target)
	e1:SetOperation(c24861088.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在，自己场上的怪兽只有「先史遗产」怪兽的场合才能发动。这张卡守备表示特殊召唤。这个效果发动的回合，自己不能把「先史遗产」卡以外的卡的效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(24861088,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,24861088)
	e2:SetCondition(c24861088.spcon)
	e2:SetCost(c24861088.spcost)
	e2:SetTarget(c24861088.sptg)
	e2:SetOperation(c24861088.spop)
	c:RegisterEffect(e2)
	-- 注册一个自定义活动计数器（代号24861088，类型ACTIVITY_CHAIN）用于监测本回合发动效果的动作；当发动的效果卡不属于「先史遗产」字段时计数增加，供②效果发动前检查是否已使用过非「先史遗产」效果。
	Duel.AddCustomActivityCounter(24861088,ACTIVITY_CHAIN,c24861088.chainfilter)
end
-- 活动计数器的过滤回调：返回true表示该效果的发动者是「先史遗产」卡，不计数；返回false表示发动的是非「先史遗产」效果，计数器+1。
function c24861088.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0x70)
end
-- 检索用的过滤条件：卡具有「先史遗产」字段、不是「先史遗产 内布拉星象盘」自身、并且能被加入手卡，用于①检索卡组时的目标筛选。
function c24861088.filter(c)
	return c:IsSetCard(0x70) and not c:IsCode(24861088) and c:IsAbleToHand()
end
-- ①的效果目标处理：在发动时检查卡组是否存在满足filter条件的检索目标，若存在则允许发动，并登记本次效果将进行“从卡组加入手卡”的操作信息。
function c24861088.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动合法性检查（chk==0）：确认自己卡组中至少存在1张满足条件的「先史遗产」卡可供检索，否则①不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c24861088.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 向系统登记本次连锁的处理信息：效果分类为CATEGORY_TOHAND，预期将1张卡从自己卡组加入手卡（目标不固定，处理时再选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- ①的效果处理：提示玩家选择加入手牌的卡，从卡组选1张符合条件的「先史遗产」卡加入持有者手牌，并将选出的卡展示给对方玩家确认。
function c24861088.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示“请选择要加入手牌的卡”的选择提示，用于卡片选择界面的引导。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组中选出1张满足filter条件的「先史遗产」卡（除自身外），作为本次检索加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c24861088.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的检索卡以效果原因送入其持有者的手卡，完成加入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将检索到手牌的卡展示给对方玩家确认，保证信息公开。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义排除用过滤条件：如果怪兽处于里侧表示或不是「先史遗产」怪兽，则返回true；用于判断自己场上是否满足“只有先史遗产怪兽”的条件。
function c24861088.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x70)
end
-- ②的发动条件：自己场上有怪兽存在，并且不存在里侧表示或非「先史遗产」的怪兽，即自己场上的怪兽全部是表侧表示的「先史遗产」怪兽。
function c24861088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己主要怪兽区域是否存在怪兽（数量>0），作为发动②的前提条件之一。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 检查自己场上不存在满足cfilter的怪兽，即没有里侧表示或非「先史遗产」怪兽，确保场上怪兽全部为表侧「先史遗产」怪兽。
		and not Duel.IsExistingMatchingCard(c24861088.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- ②的发动代价：先确认本回合尚未发动过非「先史遗产」卡的效果；随后给己方施加一个持续到结束阶段的自肃效果，本回合不能再发动「先史遗产」以外的卡的效果。
function c24861088.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查：通过自定义活动计数器确认本回合己方发动效果时没有使用过非「先史遗产」卡（计数为0），否则不能支付代价发动②。
	if chk==0 then return Duel.GetCustomActivityCount(24861088,tp,ACTIVITY_CHAIN)==0 end
	-- ②：这张卡守备表示特殊召唤。这个效果发动的回合，自己不能把「先史遗产」卡以外的卡的效果发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c24861088.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的自肃效果e1注册到场上，使tp玩家在该效果有效期内不能发动非「先史遗产」卡的效果；该效果在结束阶段重置。
	Duel.RegisterEffect(e1,tp)
end
-- 自肃效果的值判定函数：如果尝试发动的效果的发动者不是「先史遗产」卡，则返回true（禁止发动），从而实现“自己不能把「先史遗产」卡以外的卡的效果发动”。
function c24861088.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x70)
end
-- ②特殊召唤的目标条件：确认自己场上有可用怪兽区域，且墓地的这张卡可以被特殊召唤为表侧守备表示。
function c24861088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动②时检查自己的主要怪兽区域是否有空位，确保特殊召唤能够进行。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 登记本次连锁的处理信息：效果分类为CATEGORY_SPECIAL_SUMMON，对象为墓地的这张卡自身（数量1），用于连锁及效果判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ②的效果处理：确认这张卡仍与效果相关后，将其以表侧守备表示特殊召唤到自己场上。
function c24861088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将墓地的这张卡以表侧守备表示特殊召唤到自己场上（保持正常的召唤条件/苏生限制检查）。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
