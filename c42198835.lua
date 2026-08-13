--外法の騎士
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
-- ②：自己场上有「勇者衍生物」存在的场合，以对方场上最多2张卡为对象才能发动。这张卡的控制权移给对方，作为对象的卡回到持有者手卡。这个效果在对方回合也能发动。
local s,id,o=GetID()
-- 注册①从手卡特殊召唤自身和②转移控制权并弹回对方卡片的效果，并登记「勇者衍生物」为关联卡名。
function c42198835.initial_effect(c)
	-- 将「勇者衍生物」（卡号3285552）登记为这张卡的关联卡名，用于“记载着卡名”的判定。
	aux.AddCodeList(c,3285552)
	-- ①：自己场上没有怪兽存在的场合或者有「勇者衍生物」存在的场合，自己·对方的主要阶段才能发动。这张卡从手卡特殊召唤。
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
	-- ②：自己场上有「勇者衍生物」存在的场合，以对方场上最多2张卡为对象才能发动。这张卡的控制权移给对方，作为对象的卡回到持有者手卡。这个效果在对方回合也能发动。
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
-- 筛选条件是：表侧表示且卡名为「勇者衍生物」（卡号3285552）。
function c42198835.cfilter(c)
	return c:IsCode(3285552) and c:IsFaceup()
end
-- ①的发动条件：当前为双方的主要阶段，且满足“自己场上没有怪兽”或“自己场上有表侧表示的「勇者衍生物」”其中之一。
function c42198835.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 只有当前阶段是主要阶段1或主要阶段2时，才允许发动，否则返回false。
	if not (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) then return false end
	-- 检查自己怪兽区域是否存在怪兽：数量为0，即没有怪兽。
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		-- 或者检查自己场上是否存在表侧表示的「勇者衍生物」，存在1张即可。
		or Duel.IsExistingMatchingCard(c42198835.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ①的发动时点确认：自己怪兽区域有空位，且手牌的这张卡能够被特殊召唤。
function c42198835.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 确认自己主要怪兽区域可用空格数大于0。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 将本次特殊召唤的操作信息（对象为本卡、数量为1）写入连锁，供其他效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关，则将其表侧表示特殊召唤。
function c42198835.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 以表侧表示将这张卡特殊召唤到自己场上。
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- ②的发动条件：自己场上有表侧表示的「勇者衍生物」。
function c42198835.rhcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否至少存在1张表侧表示的「勇者衍生物」。
	return Duel.IsExistingMatchingCard(c42198835.cfilter,tp,LOCATION_ONFIELD,0,1,nil)
end
-- ②的发动时点确认：这张卡的控制权能够转移，且对方场上有可以返回手牌的卡；然后选择1~2张对方场上的卡作为对象。
function c42198835.rhtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and chkc:IsAbleToHand() end
	if chk==0 then return e:GetHandler():IsControlerCanBeChanged()
		-- 确认对方场上有至少1张符合条件、可以返回手牌的卡。
		and Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 弹出“请选择要返回手牌的卡”的选择提示，供玩家选择目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上1~2张可以返回手牌的卡作为效果对象（同时设为连锁对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,1,2,nil)
	-- 将这张卡控制权转移的效果分类写入连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
	-- 将对象卡返回手牌的效果分类及数量（按实际选择张数）写入连锁信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- ②效果处理：获取连锁对象卡；若这张卡仍与效果相关且控制权转移成功，则将仍相关的对象卡返回持有者手牌。
function c42198835.rhop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁选择的处理对象卡组（即发动时选中的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 判断是否继续处理：这张卡仍与效果相关、控制权成功转移给对方、且仍有对象卡需要返回手牌。
	if c:IsRelateToEffect(e) and Duel.GetControl(c,1-tp)>0 and tg:GetCount()>0 then
		-- 将对象卡返回其持有者手牌，原因是效果（REASON_EFFECT）。
		Duel.SendtoHand(tg,nil,REASON_EFFECT)
	end
end
