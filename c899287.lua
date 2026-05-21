--怪鳥グライフ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「急流山的金宫」加入手卡。
-- ②：这张卡召唤·特殊召唤成功的场合，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡破坏。
function c899287.initial_effect(c)
	-- 在卡片中注册关联卡片密码「急流山的金宫」
	aux.AddCodeList(c,72283691)
	-- ①：把这张卡从手卡丢弃才能发动。从卡组把1张「急流山的金宫」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(899287,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCost(c899287.thcost)
	e1:SetTarget(c899287.thtg)
	e1:SetOperation(c899287.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡召唤·特殊召唤成功的场合，以对方的魔法与陷阱区域1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(899287,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,899287)
	e2:SetTarget(c899287.destg)
	e2:SetOperation(c899287.desop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 效果①的代价（Cost）处理函数
function c899287.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsDiscardable() end
	-- 将自身作为发动代价从手卡丢弃送去墓地
	Duel.SendtoGrave(c,REASON_COST+REASON_DISCARD)
end
-- 过滤卡组中卡名为「急流山的金宫」且能加入手卡的卡片
function c899287.thfilter(c)
	return c:IsCode(72283691) and c:IsAbleToHand()
end
-- 效果①的发动准备与合法性检测函数
function c899287.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查卡组中是否存在可以加入手卡的「急流山的金宫」
	if chk==0 then return Duel.IsExistingMatchingCard(c899287.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示该效果包含将卡组的卡加入手卡的操作
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理（Operation）函数
function c899287.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取卡组中第一张满足条件的「急流山的金宫」
	local tg=Duel.GetFirstMatchingCard(c899287.thfilter,tp,LOCATION_DECK,0,nil)
	if tg then
		-- 将目标卡片加入手卡
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tg)
	end
end
-- 过滤魔法与陷阱区域中非场地区域（格子编号小于5）的卡片
function c899287.desfilter(c)
	return c:GetSequence()<5
end
-- 效果②的发动准备与对象选择函数
function c899287.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_SZONE) and chkc:IsControler(tp) and c899287.desfilter(chkc) end
	-- 检查对方的魔法与陷阱区域是否存在可以作为对象破坏的卡
	if chk==0 then return Duel.IsExistingTarget(c899287.desfilter,tp,0,LOCATION_SZONE,1,nil) end
	-- 向发动玩家发送选择要破坏的卡片的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方魔法与陷阱区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c899287.desfilter,tp,0,LOCATION_SZONE,1,1,nil)
	-- 设置连锁信息，表示该效果包含破坏所选对象的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的效果处理（Operation）函数
function c899287.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 因效果将对象卡片破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
