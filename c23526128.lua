--雷盟－リターンストローク
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「雷盟」怪兽不会被对方的效果破坏。
-- ②：对方把魔法卡的效果发动时，让自己场上1只「雷盟」怪兽回到手卡才能发动。那个效果无效并破坏。
-- ③：把墓地的这张卡除外，以自己的场上·墓地1只「雷盟」怪兽为对象才能发动。那只怪兽回到手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册①的抗破坏效果，②的无效魔法卡效果的发动并破坏的效果，以及③的墓地回收怪兽效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在魔法与陷阱区域存在，自己场上的「雷盟」怪兽不会被对方的效果破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(s.indtg)
	-- 设置抗性来源：仅不会被对方玩家的卡的效果破坏
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
	-- ②：对方把魔法卡的效果发动时，让自己场上1只「雷盟」怪兽回到手卡才能发动。那个效果无效并破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"效果无效"
	e3:SetCategory(CATEGORY_DISABLE+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetCode(EVENT_CHAINING)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.discon)
	e3:SetCost(s.discost)
	e3:SetTarget(s.distg)
	e3:SetOperation(s.disop)
	c:RegisterEffect(e3)
	-- ③：把墓地的这张卡除外，以自己的场上·墓地1只「雷盟」怪兽为对象才能发动。那只怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))  --"回收怪兽"
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e4:SetCountLimit(1,id+o)
	-- ③的效果的发动代价：将墓地的这张卡除外
	e4:SetCost(aux.bfgcost)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 过滤受到抗性保护的本方场上的「雷盟」怪兽
function s.indtg(e,c)
	return c:IsSetCard(0x1df)
end
-- ②效果的发动条件：对方发动了魔法卡的效果，且该效果可以被无效
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否为对方发动的魔法卡效果，且该效果是可以被无效的效果
	return ep~=tp and re:IsActiveType(TYPE_SPELL) and Duel.IsChainDisablable(ev)
end
-- 过滤场上表侧表示可以作为cost弹回手牌的「雷盟」怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1df) and c:IsAbleToHandAsCost()
end
-- ②效果的发动代价：让自己场上1只表侧表示的「雷盟」怪兽回到手牌
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时，检查自己场上是否存在符合回到手卡条件的「雷盟」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要返回手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择1只符合条件的怪兽以支付Cost
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 在场上显式标出选为发动的卡的动画效果
	Duel.HintSelection(g)
	-- 将选中的怪兽作为发动代价送回持有者的手牌
	Duel.SendtoHand(g,nil,REASON_COST)
end
-- ②效果的发动准备与合法性检查：设置无效并破坏的效果操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息：使发动的魔法效果无效
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		-- 设置效果处理信息：破坏发动的魔法卡
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
-- ②效果的效果处理：使该魔法卡的效果无效并将其破坏
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 成功使效果无效且该魔法卡依然存在于该连锁中
	if Duel.NegateEffect(ev) and re:GetHandler():IsRelateToChain(ev) then
		-- 破坏被无效了效果的魔法卡
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
-- 过滤场上或墓地中可以回收的「雷盟」怪兽
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0x1df) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- ③效果的发动准备与合法性检查：选择自己场上或墓地的1只「雷盟」怪兽作为效果的对象
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return s.thfilter(chkc) and chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(tp) end
	-- 效果发动时，检查自己场上或墓地是否存在符合回收条件的「雷盟」怪兽
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 优先从场上选择（若不足则从墓地选择）1只符合条件的怪兽作为对象
	local g=aux.SelectTargetFromFieldFirst(tp,s.thfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：将目标怪兽加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- ③效果的效果处理：将作为对象的「雷盟」怪兽加入玩家手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的唯一对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查目标怪兽是否仍与本连锁相关，且不受王家长眠之谷的影响
	if tc:IsRelateToChain() and aux.NecroValleyFilter()(tc) then
		-- 将选中的怪兽送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
