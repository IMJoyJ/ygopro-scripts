--外法の騎士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「勇者衍生物」存在的场合，以对方场上最多2张卡为对象才能发动。这张卡的控制权移给对方，作为对象的卡回到持有者手卡。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 创建外法之骑士的卡效果，包括①②两个效果
function c42198835.initial_effect(c)
	-- 记录该卡与「勇者衍生物」的关联
	aux.AddCodeList(c,3285552)
	-- 效果①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(42198835,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,42198835)
	e1:SetCondition(c42198835.spcon)
	e1:SetTarget(c42198835.sptg)
	e1:SetOperation(c42198835.spop)
	c:RegisterEffect(e1)
	-- 效果②：自己场上有「勇者衍生物」存在的场合，以对方场上最多2张卡为对象才能发动。这张卡的控制权移给对方，作为对象的卡回到持有者手卡。这个效果在对方回合也能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(42198835,1))
	e2:SetCategory(CATEGORY_CONTROL+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e2:SetCountLimit(1,42198835+o)
	e2:SetCondition(c42198835.rhcon)
	e2:SetTarget(c42198835.rhtg)
	e2:SetOperation(c42198835.rhop)
	c:RegisterEffect(e2)
end
-- 过滤器函数，用于判断场上是否存在「勇者衍生物」
function c42198835.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- 效果①的发动条件判断函数，判断是否在主要阶段且满足场上无怪兽或存在「勇者衍生物」
function c42198835.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否处于主要阶段1或主要阶段2
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 判断自己场上是否没有怪兽
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 判断自己场上是否存在「勇者衍生物」
		or Duel.IsExistingMatchingCard(c42198835.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果①的发动时点处理函数，判断是否满足特殊召唤条件
function c42198835.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的召唤空间
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置效果①的发动信息，表示将要特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理函数，执行特殊召唤操作
function c42198835.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 执行特殊召唤操作，将此卡特殊召唤到场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果②的发动条件判断函数，判断是否场上有「勇者衍生物」
function c42198835.rhcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自己场上是否存在「勇者衍生物」
	return Duel.IsExistingMatchingCard(c42198835.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- 效果②的发动时点处理函数，判断是否满足控制权转移和回手条件
function c42198835.rhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged()
		-- 判断对方场上是否存在可返回手牌的卡
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上最多2张可返回手牌的卡作为对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 设置效果②的发动信息，表示将要改变控制权
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
	-- 设置效果②的发动信息，表示将要将对象卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果②的发动处理函数，执行控制权转移和回手操作
function c42198835.rhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中指定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 判断此卡和目标卡是否有效且满足发动条件
	if c:IsRelateToEffect(e) and Duel.GetControl(c,1-tp)>0 and tg:GetCount()>0 then
		-- 将目标卡送回持有者手牌
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
