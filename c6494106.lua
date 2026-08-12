--妬絶の呪眼
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「咒眼」怪兽存在的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果的对象可以变成2只。
function c6494106.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「咒眼」怪兽存在的场合，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。自己的魔法与陷阱区域有「太阴之咒眼」存在的场合，这个效果的对象可以变成2只。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,6494106+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c6494106.condition)
	e1:SetTarget(c6494106.target)
	e1:SetOperation(c6494106.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「咒眼」怪兽
function c6494106.filter(c)
	return c:IsSetCard(0x129) and c:IsFaceup()
end
-- 发动条件：自己场上有「咒眼」怪兽存在
function c6494106.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1张表侧表示的「咒眼」怪兽
	return Duel.IsExistingMatchingCard(c6494106.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：自己魔陷区表侧表示的「太阴之咒眼」
function c6494106.filter1(c)
	return c:IsFaceup() and c:IsCode(44133040)
end
-- 效果发动时的对象选择处理
function c6494106.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	-- 在发动阶段检查场上是否存在至少1只可以回到手牌的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local tg=1
	-- 检查自己的魔法与陷阱区域是否存在表侧表示的「太阴之咒眼」
	if Duel.IsExistingMatchingCard(c6494106.filter1,tp,LOCATION_SZONE,0,1,nil) then
		tg=2
	end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择1只或2只（取决于是否满足「太阴之咒眼」在场条件）场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,tg,nil)
	-- 设置操作信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
-- 效果处理的执行
function c6494106.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将仍符合条件的卡片因效果送回持有者的手牌
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
