--先史遺産ネブラ・ディスク
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：这张卡召唤成功时才能发动。从卡组把「先史遗产 内布拉星象盘」以外的1张「先史遗产」卡加入手卡。
-- ②：这张卡在墓地存在，自己场上的怪兽只有「先史遗产」怪兽的场合才能发动。这张卡守备表示特殊召唤。这个效果发动的回合，自己不能把「先史遗产」卡以外的卡的效果发动。
function c24861088.initial_effect(c)
	-- ①：这张卡召唤成功时才能发动。从卡组把「先史遗产 内布拉星象盘」以外的1张「先史遗产」卡加入手卡。
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
	-- 设置一个计数器，用于记录玩家在回合中发动的非「先史遗产」卡的效果次数。
	Duel.AddCustomActivityCounter(24861088,ACTIVITY_CHAIN,c24861088.chainfilter)
end
-- 计数器的过滤函数，判断效果是否为「先史遗产」卡的效果。
function c24861088.chainfilter(re,tp,cid)
	return re:GetHandler():IsSetCard(0x70)
end
-- 检索满足条件的卡片组，筛选出「先史遗产」卡且不是自身，并且可以加入手牌。
function c24861088.filter(c)
	return c:IsSetCard(0x70) and not c:IsCode(24861088) and c:IsAbleToHand()
end
-- 设置效果处理时的连锁操作信息，确定要处理的卡为1张从卡组加入手牌的卡。
function c24861088.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足检索条件，即卡组中是否存在至少1张符合条件的「先史遗产」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(c24861088.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置效果处理时的连锁操作信息，确定要处理的卡为1张从卡组加入手牌的卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 执行检索效果，选择一张符合条件的卡加入手牌并确认对方查看。
function c24861088.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择一张符合条件的卡。
	local g=Duel.SelectMatchingCard(tp,c24861088.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以效果原因送入手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认查看送入手牌的卡。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 判断场上怪兽是否为「先史遗产」怪兽或是否为里侧表示。
function c24861088.cfilter(c)
	return c:IsFacedown() or not c:IsSetCard(0x70)
end
-- 判断特殊召唤条件是否满足，即自己场上存在怪兽且所有怪兽均为「先史遗产」怪兽。
function c24861088.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		-- 判断自己场上是否存在非「先史遗产」怪兽。
		and not Duel.IsExistingMatchingCard(c24861088.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 设置发动特殊召唤效果时的费用，禁止在本回合发动非「先史遗产」卡的效果。
function c24861088.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否已发动过非「先史遗产」卡的效果。
	if chk==0 then return Duel.GetCustomActivityCount(24861088,tp,ACTIVITY_CHAIN)==0 end
	-- 创建并注册一个禁止发动效果的永久性效果，仅对非「先史遗产」卡生效。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(1,0)
	e1:SetValue(c24861088.aclimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将创建的效果注册到场上。
	Duel.RegisterEffect(e1,tp)
end
-- 定义禁止发动效果的判断函数，若效果来源不是「先史遗产」卡则禁止发动。
function c24861088.aclimit(e,re,tp)
	return not re:GetHandler():IsSetCard(0x70)
end
-- 设置特殊召唤效果的目标处理信息，确定要特殊召唤的卡为自身。
function c24861088.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足特殊召唤的条件，即场上存在空位且自身可以特殊召唤。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置效果处理时的连锁操作信息，确定要处理的卡为1张特殊召唤的卡。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤效果，将自身以守备表示特殊召唤到场上。
function c24861088.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以守备表示特殊召唤到场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
