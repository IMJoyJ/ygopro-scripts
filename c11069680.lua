--ジャンク・コンバーター
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：从手卡把这张卡和1只调整丢弃才能发动。从卡组把1只「同调士」怪兽加入手卡。
-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
function c11069680.initial_effect(c)
	-- ①：从手卡把这张卡和1只调整丢弃才能发动。从卡组把1只「同调士」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11069680,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,11069680)
	e1:SetCost(c11069680.thcost)
	e1:SetTarget(c11069680.thtg)
	e1:SetOperation(c11069680.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡作为同调素材送去墓地的场合，以自己墓地1只调整为对象才能发动。那只怪兽守备表示特殊召唤。这个回合，这个效果特殊召唤的怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11069680,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,11069681)
	e2:SetCondition(c11069680.spcon)
	e2:SetTarget(c11069680.sptg)
	e2:SetOperation(c11069680.spop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断是否为调整怪兽且可丢弃
function c11069680.dfilter(c)
	return c:IsType(TYPE_TUNER) and c:IsDiscardable()
end
-- 效果①的发动费用处理函数
function c11069680.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable()
		-- 检查手牌中是否存在至少1只调整怪兽且当前卡可丢弃
		and Duel.IsExistingMatchingCard(c11069680.dfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 向玩家提示选择要丢弃的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
	-- 选择满足条件的调整怪兽
	local g=Duel.SelectMatchingCard(tp,c11069680.dfilter,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的卡丢入墓地作为发动费用
	Duel.SendtoGrave(g,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，用于检索卡组中「同调士」怪兽
function c11069680.thfilter(c)
	return c:IsSetCard(0x1017) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果①的发动效果处理函数
function c11069680.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张「同调士」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c11069680.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁操作信息，准备将卡组中的「同调士」怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的发动效果处理函数
function c11069680.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 从卡组中选择1张「同调士」怪兽
	local g=Duel.SelectMatchingCard(tp,c11069680.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的「同调士」怪兽加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 效果②的发动条件判断函数
function c11069680.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and r==REASON_SYNCHRO
end
-- 过滤函数，用于判断墓地中的调整怪兽是否可特殊召唤
function c11069680.spfilter(c,e,tp)
	return c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动效果处理函数
function c11069680.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c11069680.spfilter(chkc,e,tp) end
	-- 检查场上是否存在可用区域用于特殊召唤
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查墓地中是否存在至少1只可特殊召唤的调整怪兽
		and Duel.IsExistingTarget(c11069680.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家提示选择要特殊召唤的调整怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的调整怪兽作为特殊召唤对象
	local g=Duel.SelectTarget(tp,c11069680.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置连锁操作信息，准备特殊召唤调整怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果②的发动效果处理函数
function c11069680.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果的目标卡
	local tc=Duel.GetFirstTarget()
	-- 判断目标卡是否有效且成功执行特殊召唤步骤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
		-- 创建一个效果，使特殊召唤的怪兽在本回合不能发动效果
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_TRIGGER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 完成特殊召唤流程
	Duel.SpecialSummonComplete()
end
