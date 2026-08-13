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
	-- 对应①效果：自己或者对方的怪兽的攻击宣言时，把自己场上1只「姬丝基勒」怪兽或者「璃拉」怪兽解放才能发动。那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(35487920,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,35487920)
	e2:SetCost(c35487920.cost1)
	e2:SetOperation(c35487920.operation1)
	c:RegisterEffect(e2)
	-- 对应②效果：自己·对方的结束阶段，以自己墓地1只「姬丝基勒」怪兽或者「璃拉」怪兽为对象才能发动。那只怪兽回到卡组。自己场上没有怪兽存在的场合，也能不回到卡组加入手卡。
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
-- 筛选可作为解放代价的怪兽：属于「姬丝基勒」或「璃拉」系列，并且是自己控制的怪兽或表侧表示的怪兽。
function c35487920.cfilter1(c,tp)
	return c:IsSetCard(0x152,0x153) and (c:IsControler(tp) or c:IsFaceup())
end
-- ①效果的发动费用处理：在攻击宣言时，检查并执行解放自己场上1只符合条件的「姬丝基勒」或「璃拉」怪兽。
function c35487920.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否存在至少1只满足条件的怪兽可以被解放，以此判断能否支付发动代价。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c35487920.cfilter1,1,nil,tp) end
	-- 从自己场上选择1只满足条件的怪兽作为解放代价。
	local sg=Duel.SelectReleaseGroup(tp,c35487920.cfilter1,1,1,nil,tp)
	-- 将选择的怪兽解放，作为效果的发动代价。
	Duel.Release(sg,REASON_COST)
end
-- ①效果实际处理：无效当前攻击。
function c35487920.operation1(e,tp,eg,ep,ev,re,r,rp)
	-- 无效这次攻击宣言的攻击。
	Duel.NegateAttack()
end
-- ②效果的发动条件判断：只在结束阶段可以发动。
function c35487920.condition2(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前阶段为结束阶段。
	return Duel.GetCurrentPhase()==PHASE_END
end
-- ②效果的对象筛选：自己墓地的「姬丝基勒」或「璃拉」系列怪兽，且能够回卡组；若check（自己场上无怪兽）为真，则也能选择可以加入手卡的怪兽。
function c35487920.tgfilter2(c,check)
	return c:IsSetCard(0x152,0x153) and c:IsType(TYPE_MONSTER)
		and (c:IsAbleToDeck() or (check and c:IsAbleToHand()))
end
-- ②效果发动时的选对象处理：根据自己场上是否有怪兽决定可选择范围，从自己墓地选择1只符合条件的「姬丝基勒」或「璃拉」怪兽作为对象，并登记回卡组的操作信息。
function c35487920.target2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查自己场上没有怪兽（没有怪兽时check为真，允许后续选择加入手卡的处理）。
	local check=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c35487920.tgfilter2(chkc,check) end
	-- 发动时需要自己墓地存在至少1只满足条件的怪兽作为对象。
	if chk==0 then return Duel.IsExistingTarget(c35487920.tgfilter2,tp,LOCATION_GRAVE,0,1,nil,check) end
	-- 向玩家显示选择对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己墓地选择1只满足条件的怪兽作为效果对象。
	local g=Duel.SelectTarget(tp,c35487920.tgfilter2,tp,LOCATION_GRAVE,0,1,1,nil,check)
	-- 将已选择的对象设置为本次连锁的回卡组操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- ②效果处理：将对象怪兽返回卡组；若自己场上没有怪兽且对象能加入手卡，则玩家可选择将其加入手卡，否则送回卡组。
function c35487920.operation2(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果处理的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	-- 判断自己场上没有怪兽且对象怪兽能够加入手卡，用于决定是否提供上手选项。
	if Duel.GetMatchingGroupCount(nil,tp,LOCATION_MZONE,0,nil)==0 and tc:IsAbleToHand()
		-- 当对象不能回卡组时直接满足加入手卡条件；否则弹出选项供玩家选择，选择第0项（加入手卡）时执行加入手卡，未选择则回卡组。
		and (not tc:IsAbleToDeck() or Duel.SelectOption(tp,1190,aux.Stringid(35487920,2))==0) then  --"回到卡组"
		-- 将对象怪兽加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	else
		-- 将对象怪兽送回持有者卡组并洗切。
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
