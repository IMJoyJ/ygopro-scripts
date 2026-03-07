--青眼の亜白龍
-- 效果：
-- 这张卡不能通常召唤。把手卡1只「青眼白龙」给对方观看的场合可以特殊召唤。这个方法的「青眼亚白龙」的特殊召唤1回合只能有1次。
-- ①：这张卡的卡名只要在场上·墓地存在当作「青眼白龙」使用。
-- ②：1回合1次，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
function c38517737.initial_effect(c)
	c:EnableReviveLimit()
	-- 特殊召唤条件设置，要求手牌中存在未公开的青眼白龙才能特殊召唤此卡，且每回合只能发动一次
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,38517737+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c38517737.spcon)
	e1:SetTarget(c38517737.sptg)
	e1:SetOperation(c38517737.spop)
	c:RegisterEffect(e1)
	-- 使此卡在场上或墓地中时视为青眼白龙
	aux.EnableChangeCode(c,89631139,LOCATION_MZONE+LOCATION_GRAVE)
	-- 效果②：1回合1次，以对方场上1只怪兽为对象才能发动（这个效果发动的回合，这张卡不能攻击）。那只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(38517737,0))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCountLimit(1)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c38517737.descost)
	e3:SetTarget(c38517737.destg)
	e3:SetOperation(c38517737.desop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选手牌中未公开的青眼白龙
function c38517737.spcfilter(c)
	return c:IsCode(89631139) and not c:IsPublic()
end
-- 判断是否满足特殊召唤条件，包括场上是否有空位以及手牌中是否存在未公开的青眼白龙
function c38517737.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查当前玩家场上主怪兽区是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查当前玩家手牌中是否存在至少一张未公开的青眼白龙
		and Duel.IsExistingMatchingCard(c38517737.spcfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 选择并确认给对方观看的青眼白龙，设置为特殊召唤的条件对象
function c38517737.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取当前玩家手牌中所有未公开的青眼白龙
	local g=Duel.GetMatchingGroup(c38517737.spcfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择要给对方确认的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤完成后的处理，将选定的卡确认给对方并洗切手牌
function c38517737.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选定的卡确认给对方玩家
	Duel.ConfirmCards(1-tp,g)
	-- 将当前玩家的手牌洗切
	Duel.ShuffleHand(tp)
end
-- 发动效果②时的费用支付，确保此卡在该回合未攻击过
function c38517737.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetAttackAnnouncedCount()==0 end
	-- 设置此卡在本回合不能攻击的效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_OATH)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	e:GetHandler():RegisterEffect(e1)
end
-- 效果②的发动条件判断，确认对方场上是否存在可破坏的怪兽
function c38517737.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少一只怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的一个怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果②的处理信息，确定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果②的处理函数，对选定的怪兽进行破坏
function c38517737.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中选定的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
