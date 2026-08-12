--Live☆Twin チャンネル
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽解放才能发动。那次攻击无效。
-- ②：自己·对方的结束阶段，以自己墓地1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽回到卡组。自己场上没有怪兽存在的场合，也能不回到卡组加入手卡。
function c35487920.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己或者对方的怪兽的攻击宣言时，把自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽解放才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35487920,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,35487920)
	e2:SetCost(c35487920.cost1)
	e2:SetOperation(c35487920.operation1)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段，以自己墓地1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽回到卡组。自己场上没有怪兽存在的场合，也能不回到卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(35487920,1))
	e3:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1,35487921)
	e3:SetCondition(c35487920.condition2)
	e3:SetTarget(c35487920.target2)
	e3:SetOperation(c35487920.operation2)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于判断场上是否满足条件的「姬丝基勒」或「璃拉」怪兽
function c35487920.cfilter1(c,tp)
	return c:IsSetCard(0x152,0x153) and (c:IsControler(tp) or c:IsFaceup())
end
-- 效果处理函数，检查并选择满足条件的怪兽进行解放作为代价
function c35487920.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否存在至少1张满足条件的可解放的「姬丝基勒」或「璃拉」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c35487920.cfilter1,1,nil,tp) end
	-- 从玩家场上选择1张满足条件的可解放的「姬丝基勒」或「璃拉」怪兽
	local sg=Duel.SelectReleaseGroup(tp,c35487920.cfilter1,1,1,nil,tp)
	-- 以REASON_COST原因解放选择的怪兽
	Duel.Release(sg,REASON_COST)
end
-- 效果处理函数，无效此次攻击
function c35487920.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 无效此次攻击
	Duel.NegateAttack()
end
-- 效果处理函数，判断是否处于结束阶段
function c35487920.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前阶段是否为结束阶段
	return Duel.GetCurrentPhase()==PHASE_END
end
-- 过滤函数，用于判断墓地中的「姬丝基勒」或「璃拉」怪兽是否可以回到卡组或手牌
function c35487920.tgfilter2(c,check)
	return c:IsSetCard(0x152,0x153) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToDeck() or (check and c:IsAbleToHand()))
end
-- 效果处理函数，选择目标怪兽并设置操作信息
function c35487920.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断自己场上是否没有怪兽
	local check=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35487920.tgfilter2(chkc,check) end
	-- 检查玩家墓地是否存在至少1张满足条件的「姬丝基勒」或「璃拉」怪兽
	if chk==0 then return Duel.IsExistingTarget(c35487920.tgfilter2,tp,LOCATION_GRAVE,0,1,nil,check) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从玩家墓地中选择1张满足条件的「姬丝基勒」或「璃拉」怪兽作为对象
	local g=Duel.SelectTarget(tp,c35487920.tgfilter2,tp,LOCATION_GRAVE,0,1,1,nil,check)
	-- 设置操作信息，表示将目标怪兽送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理函数，根据场上是否有怪兽决定将目标怪兽送回卡组或加入手牌
function c35487920.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁效果选择的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断自己场上是否没有怪兽且目标怪兽可以加入手牌
	if Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,nil)==0 and tc:IsAbleToHand()
		-- 如果目标怪兽不能送回卡组或玩家选择送回卡组，则选择送回手牌
		and (not tc:IsAbleToDeck() or Duel.SelectOption(tp,1190,aux.Stringid(35487920,2))==0) then  --"回到卡组"
		-- 将目标怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		-- 将目标怪兽送回卡组
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
