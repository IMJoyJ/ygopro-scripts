--星遺物－『星鎧』
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：怪兽反转召唤成功时才能发动。这张卡从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
-- ③：通常召唤的这张卡存在的场合，以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡回到持有者手卡。这个效果在对方回合也能发动。
function c83477829.initial_effect(c)
	-- ①：怪兽反转召唤成功时才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(83477829,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_HAND)
	e1:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	e1:SetCountLimit(1,83477829)
	e1:SetTarget(c83477829.sptg)
	e1:SetOperation(c83477829.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合才能发动。从卡组把1张「星遗物」卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(83477829,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,83477830)
	e2:SetTarget(c83477829.tg)
	e2:SetOperation(c83477829.op)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	-- ③：通常召唤的这张卡存在的场合，以从额外卡组特殊召唤的对方场上1只表侧表示怪兽为对象才能发动。那只怪兽和这张卡回到持有者手卡。这个效果在对方回合也能发动。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(83477829,2))  --"回到手卡"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,83477831)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCondition(c83477829.thcon)
	e4:SetTarget(c83477829.thtg)
	e4:SetOperation(c83477829.thop)
	c:RegisterEffect(e4)
end
-- 效果①（手卡特殊召唤）的发动检测与靶向函数
function c83477829.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0（检测阶段）时，判断自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置当前连锁的操作信息为：特殊召唤自己（1张卡）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①（手卡特殊召唤）的效果处理函数
function c83477829.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将这张卡以表侧表示特殊召唤到自己的怪兽区域
	Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
end
-- 过滤卡组中「星遗物」卡片且能加入手牌的过滤函数
function c83477829.filter(c)
	return c:IsSetCard(0xfe) and c:IsAbleToHand()
end
-- 效果②（检索「星遗物」卡）的发动检测与靶向函数
function c83477829.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在chk为0时，判断卡组中是否存在至少1张满足过滤条件的「星遗物」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c83477829.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置当前连锁的操作信息为：从卡组将1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果②（检索「星遗物」卡）的效果处理函数
function c83477829.op(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择1张满足过滤条件的「星遗物」卡
	local g=Duel.SelectMatchingCard(tp,c83477829.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡片因效果加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果③（弹回手牌）的发动条件函数：这张卡必须是通常召唤（非特殊召唤）上场的
function c83477829.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(c:GetSummonType(),SUMMON_TYPE_SPECIAL)==0
end
-- 过滤对方场上表侧表示、能回手牌且是从额外卡组特殊召唤的怪兽的过滤函数
function c83477829.thfilter(c)
	return c:IsFaceup() and c:IsAbleToHand() and c:IsSummonLocation(LOCATION_EXTRA)
end
-- 效果③（弹回手牌）的发动检测与靶向函数
function c83477829.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	-- 在chk为0时，判断对方场上是否存在至少1只满足过滤条件的额外卡组怪兽
	if chk==0 then return Duel.IsExistingTarget(c83477829.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 向玩家提示选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择对方场上1只满足过滤条件的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c83477829.thfilter,tp,0,LOCATION_MZONE,1,1,nil)
	g:AddCard(e:GetHandler())
	-- 设置当前连锁的操作信息为：将包含对象怪兽和这张卡在内的2张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果③（弹回手牌）的效果处理函数
function c83477829.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		local rg=Group.FromCards(c,tc)
		-- 将这张卡和对象怪兽一起因效果送回持有者的手牌
		Duel.SendtoHand(rg,nil,REASON_EFFECT)
	end
end
