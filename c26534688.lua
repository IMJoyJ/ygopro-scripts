--深海の都 マガラニカ
-- 效果：
-- 这个卡名在规则上当作「海」使用。
-- ①：作为这张卡的发动时的效果处理，可以从卡组选1只水属性怪兽在卡组最上面放置。
-- ②：1回合1次，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升1星或者2星。
-- ③：1回合1次，自己主要阶段，自己对水属性同调怪兽的特殊召唤成功的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
function c26534688.initial_effect(c)
	-- ①：作为这张卡的发动时的效果处理，可以从卡组选1只水属性怪兽在卡组最上面放置。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(c26534688.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只水属性怪兽为对象才能发动。那只怪兽的等级直到回合结束时上升1星或者2星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(26534688,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c26534688.lvtg)
	e2:SetOperation(c26534688.lvop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，自己主要阶段，自己对水属性同调怪兽的特殊召唤成功的场合才能发动。把对方手卡确认，从那之中选1张卡直到结束阶段表侧表示除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(26534688,1))
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c26534688.rmcon)
	e3:SetTarget(c26534688.rmtg)
	e3:SetOperation(c26534688.rmop)
	c:RegisterEffect(e3)
end
-- 这张卡发动时的效果处理：若卡组中有水属性怪兽且玩家选择发动，则从卡组选1只水属性怪兽，洗切卡组后将其放到卡组最上方，并确认卡组顶。
function c26534688.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方卡组中所有水属性怪兽的集合，作为可从卡组选择放置到顶的候选。
	local g=Duel.GetMatchingGroup(Card.IsAttribute,tp,LOCATION_DECK,0,nil,ATTRIBUTE_WATER)
	-- 判定卡组中是否存在水属性怪兽，并询问玩家是否要发动该处理，是则继续执行。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(26534688,2)) then  --"是否从卡组选1只水属性怪兽在卡组最上面放置？"
		-- 显示‘请选择要在卡组最上面放置的卡’的提示消息，引导玩家选择待放置的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26534688,3))  --"请选择要在卡组最上面放置的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将己方卡组洗切，确保卡组顺序被随机化后再进行置顶操作。
		Duel.ShuffleDeck(tp)
		-- 将选中的水属性怪兽移动到卡组最上方，即放置在卡组顶。
		Duel.MoveSequence(tc,SEQ_DECKTOP)
		-- 确认己方卡组最上方1张卡，展示刚刚放到卡组顶的水属性怪兽。
		Duel.ConfirmDecktop(tp,1)
	end
end
-- ②的对象筛选条件：怪兽需为表侧表示、水属性且等级在1星以上。
function c26534688.lvfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsLevelAbove(1)
end
-- ②的发动时目标选择：选择自己场上1只表侧表示水属性怪兽作为效果对象。包含合法性检查和对象登记。
function c26534688.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c26534688.lvfilter(chkc) end
	-- 在发动合法性确认阶段，检查自己场上是否存在满足筛选条件的表侧表示水属性怪兽，若没有则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c26534688.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 显示‘请选择效果的对象’的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只满足条件的水属性怪兽，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c26534688.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- ②的效果处理：取得对象怪兽，若仍与效果相关且表侧表示，则由玩家宣言上升等级数（1或2），给对象怪兽附加直到回合结束时等级上升相应数值的效果。
function c26534688.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动②时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 显示选择上升等级数（1或2）的提示消息。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(26534688,4))  --"请选择要上升等级的怪兽"
		-- 让玩家宣言1或2，作为等级上升的数值。
		local lv=Duel.AnnounceNumber(tp,1,2)
		-- 那只怪兽的等级直到回合结束时上升1星或者2星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(lv)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ③的诱发条件用怪兽筛选：满足表侧表示、水属性、同调怪兽且是由当前玩家特殊召唤的怪兽。
function c26534688.rmfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_SYNCHRO) and c:IsSummonPlayer(tp)
end
-- ③的发动条件判断：在自己的主要阶段，且自己成功特殊召唤了水属性同调怪兽时才能发动。
function c26534688.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 具体判定：当前回合玩家是自己、处于主要阶段1或2，并且这次特殊召唤成功的怪兽群中存在满足条件的水属性同调怪兽。
	return Duel.GetTurnPlayer()==tp and (Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2) and eg:IsExists(c26534688.rmfilter,1,nil,tp)
end
-- ③的发动时目标/操作信息设定：确认对方手牌中有可除外的卡，并登记效果将除外对方手牌1张卡。
function c26534688.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：对方手牌中是否存在至少1张可以被除外的卡，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil) end
	-- 设置操作信息为除外效果：预估从对方手牌除外1张卡，供相关卡牌（如星尘龙等）进行效果监测。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- ③的效果处理：确认对方手牌，选择其中1张表侧表示除外，直到结束阶段；并注册结束阶段将其返回手牌的效果。
function c26534688.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中所有能够被除外的卡，用于确认和选择。
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()==0 then return end
	-- 将对方手牌全部展示给当前玩家确认，以执行‘把对方手卡确认’。
	Duel.ConfirmCards(tp,g)
	-- 显示‘请选择要除外的卡’的提示，引导玩家选择1张手牌除外。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	-- 将选中的手牌以表侧表示除外，原因是效果处理。
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	-- 洗切对方手牌，因为已让对方确认过手牌并从中选择了一张。
	Duel.ShuffleHand(1-tp)
	local c=e:GetHandler()
	local fid=c:GetFieldID()
	-- 直到结束阶段表侧表示除外。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabel(fid)
	e1:SetLabelObject(tc)
	e1:SetCondition(c26534688.retcon)
	e1:SetOperation(c26534688.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将‘结束阶段时把除外的卡返回手牌’的效果注册到当前决斗中，使其在结束阶段执行。
	Duel.RegisterEffect(e1,tp)
	tc:RegisterFlagEffect(26534688,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1,fid)
end
-- 返回效果的触发条件：判定结束阶段时，要返回的那张卡是否仍然是本效果除外的对象（通过标记识别），是则执行返回，否则取消该效果。
function c26534688.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(26534688)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
-- 返回效果的处理：把之前因③效果除外的那张卡送回持有者的手牌。
function c26534688.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 因效果将除外的那张卡送回其持有者手牌，完成‘直到结束阶段除外’的返回。
	Duel.SendtoHand(tc,nil,REASON_EFFECT)
end
