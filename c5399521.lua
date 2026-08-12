--音響戦士マイクス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：另一边的自己的灵摆区域没有「音响战士」卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：自己结束阶段，以除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡可以把自己场上3个音响指示物取除，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
function c5399521.initial_effect(c)
	-- 为这张卡添加灵摆怪兽属性，使其可以灵摆召唤以及在灵摆区域作为灵摆卡发动
	aux.EnablePendulumAttribute(c)
	-- ①：另一边的自己的灵摆区域没有「音响战士」卡存在的场合，这张卡的灵摆刻度变成4。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_LSCALE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c5399521.slcon)
	e2:SetValue(4)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CHANGE_RSCALE)
	c:RegisterEffect(e3)
	-- ②：自己结束阶段，以除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_PZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(c5399521.thcon)
	e4:SetTarget(c5399521.thtg)
	e4:SetOperation(c5399521.thop)
	c:RegisterEffect(e4)
	-- ①：这张卡可以把自己场上3个音响指示物取除，从手卡特殊召唤。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SPSUMMON_PROC)
	e5:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e5:SetRange(LOCATION_HAND)
	e5:SetCondition(c5399521.spcon)
	e5:SetOperation(c5399521.spop)
	c:RegisterEffect(e5)
	-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_SUMMON_SUCCESS)
	e6:SetOperation(c5399521.sumop)
	c:RegisterEffect(e6)
	local e7=e6:Clone()
	e7:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e7)
end
c5399521.mentioned_counter={
	[0x35]=true,
}
-- 灵摆效果②的发动条件函数，判断当前是否为发动者的自己结束阶段
function c5399521.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己，即只在自己的结束阶段才能发动
	return Duel.GetTurnPlayer()==tp
end
-- 对象卡过滤函数：要求为表侧表示的「音响战士」（0x1066）怪兽且可以加入手卡
function c5399521.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 灵摆效果②的对象选择处理：确认可作为对象的卡、选择1只被除外的自己的「音响战士」怪兽并设置回手牌的操作信息
function c5399521.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c5399521.thfilter(chkc) end
	-- 发动时检查自己除外区是否存在至少1只能成为对象、满足条件的「音响战士」怪兽
	if chk==0 then return Duel.IsExistingTarget(c5399521.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向自己发送选择提示消息「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让自己选择1只被除外的满足条件的「音响战士」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c5399521.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置操作信息：确定将选择的1张卡回收到手牌，供星尘龙、王家长眠之谷等效果检测
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果②的效果处理：取得对象卡，若仍与本效果关联则加入手卡并展示给对方确认
function c5399521.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得当前连锁的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果处理为由将对象怪兽加入持有者手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方确认
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 灵摆效果①的适用条件函数，判断另一边的自己灵摆区域是否存在「音响战士」卡
function c5399521.slcon(e)
	-- 检查自己灵摆区域除这张卡外是否存在「音响战士」（0x1066）卡，不存在则条件成立、刻度变成4
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x1066)
end
-- 特殊召唤规则条件的判定函数：自己主要怪兽区域有空位且可以取除3个音响指示物作为代价
function c5399521.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己主要怪兽区域是否有可使用的空格
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在能够以代价取除的3个音响指示物（0x35）
		and Duel.IsCanRemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 特殊召唤手续的处理：将自己场上3个音响指示物取除作为代价
function c5399521.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 作为特殊召唤的代价，把自己场上3个音响指示物取除
	Duel.RemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 怪兽效果②的处理：若本回合尚未适用过该效果，则注册1次额外的通常召唤次数并记录标识
function c5399521.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查本回合是否已经适用过这张卡的追加召唤效果，已适用则不再重复处理
	if Duel.GetFlagEffect(tp,5399521)~=0 then return end
	-- 这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(5399521,0))  --"使用「音响战士 麦克风」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 把增加通常召唤次数的效果注册给玩家，持续到这个回合结束
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合的标识效果，标记这张卡的追加召唤效果本回合已适用
	Duel.RegisterFlagEffect(tp,5399521,RESET_PHASE+PHASE_END,0,1)
end
