--音響戦士マイクス
-- 效果：
-- ←1 【灵摆】 1→
-- ①：另一边的自己的灵摆区域没有「音响战士」卡存在的场合，这张卡的灵摆刻度变成4。
-- ②：自己结束阶段，以除外的1只自己的「音响战士」怪兽为对象才能发动。那只怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡可以把自己场上3个音响指示物取除，从手卡特殊召唤。
-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
function c5399521.initial_effect(c)
	-- 为怪兽卡注册灵摆怪兽属性（包括灵摆召唤和作为灵摆卡发动）。
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
-- 灵摆效果②的条件判定函数：是否为自己的回合。
function c5399521.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否为自己。
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：检索除外状态的、表侧表示的「音响战士」怪兽且能加入手卡。
function c5399521.thfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x1066) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 灵摆效果②的发动准备与目标选择函数。
function c5399521.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_REMOVED) and c5399521.thfilter(chkc) end
	-- 判定除外区是否存在至少1只满足条件的「音响战士」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c5399521.thfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 向玩家发送选择要加入手牌的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1只「音响战士」怪兽作为效果处理的对象。
	local g=Duel.SelectTarget(tp,c5399521.thfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置当前连锁的操作信息，表明该效果包含将1张选定卡片加入手牌的操作。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 灵摆效果②的效果处理函数。
function c5399521.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取在发动时选择的作为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的怪兽加入持有者的手牌。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,tc)
	end
end
-- 灵摆效果①的条件判定函数：另一边的灵摆区域没有「音响战士」卡。
function c5399521.slcon(e)
	-- 判定自己的另一侧灵摆区域是否存在「音响战士」卡。
	return not Duel.IsExistingMatchingCard(Card.IsSetCard,e:GetHandlerPlayer(),LOCATION_PZONE,0,1,e:GetHandler(),0x1066)
end
-- 怪兽效果①的特殊召唤条件判定函数。
function c5399521.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 判定自己场上是否有可用的怪兽区域。
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己场上是否能作为COST取除3个音响指示物。
		and Duel.IsCanRemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 怪兽效果①的特殊召唤COST处理函数。
function c5399521.spop(e,tp,eg,ep,ev,re,r,rp,c)
	-- 从自己场上取除3个音响指示物。
	Duel.RemoveCounter(tp,1,0,0x35,3,REASON_COST)
end
-- 怪兽效果②的召唤/特殊召唤成功时的效果处理函数。
function c5399521.sumop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定本回合是否已经适用过该追加召唤的效果，若已适用则不再处理。
	if Duel.GetFlagEffect(tp,5399521)~=0 then return end
	-- ②：这张卡召唤·特殊召唤成功的回合，自己在通常召唤外加上只有1次，自己主要阶段可以把1只怪兽召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(5399521,0))  --"使用「音响战士 麦克风」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 为玩家注册增加一次通常召唤机会的全局效果。
	Duel.RegisterEffect(e1,tp)
	-- 为玩家注册本回合已适用过该追加召唤效果的标记。
	Duel.RegisterFlagEffect(tp,5399521,RESET_PHASE+PHASE_END,0,1)
end
