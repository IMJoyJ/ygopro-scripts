--ミュートリアル・アームズ
-- 效果：
-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡不会成为对方的陷阱卡的效果的对象。
-- ②：对方把怪兽的效果发动时，从自己的手卡·场上把1张卡除外，以场上1只怪兽为对象才能发动。那只怪兽除外。
-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」魔法卡为对象才能发动。那张卡加入手卡。
function c7574904.initial_effect(c)
	-- 这张卡不用「秘异三变」卡的效果不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c7574904.splimit)
	c:RegisterEffect(e1)
	-- ①：这张卡不会成为对方的陷阱卡的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c7574904.ctval)
	c:RegisterEffect(e2)
	-- ②：对方把怪兽的效果发动时，从自己的手卡·场上把1张卡除外，以场上1只怪兽为对象才能发动。那只怪兽除外。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetCode(EVENT_CHAINING)
	e3:SetType(EFFECT_TYPE_QUICK_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,7574904)
	e3:SetCondition(c7574904.rmcon)
	e3:SetCost(c7574904.rmcost)
	e3:SetTarget(c7574904.rmtg)
	e3:SetOperation(c7574904.rmop)
	c:RegisterEffect(e3)
	-- ③：这张卡被对方破坏的场合，以除外的1张自己的「秘异三变」魔法卡为对象才能发动。那张卡加入手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,7574905)
	e4:SetCondition(c7574904.thcon)
	e4:SetTarget(c7574904.thtg)
	e4:SetOperation(c7574904.thop)
	c:RegisterEffect(e4)
end
-- 特殊召唤限制：判定是否由「秘异三变」卡的效果进行特殊召唤
function c7574904.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x157)
end
-- 抗性判定：判定是否为对方发动的陷阱卡的效果对象
function c7574904.ctval(e,re,rp)
	-- 过滤对方发动的陷阱卡的效果
	return aux.tgoval(e,re,rp) and re:IsActiveType(TYPE_TRAP)
end
-- 效果②的发动条件：对方发动怪兽效果时，且自身未被战斗破坏
function c7574904.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and ep==1-tp
		and re:IsActiveType(TYPE_MONSTER)
end
-- 过滤场上可以作为效果对象并除外的怪兽
function c7574904.rmtgfilter(c,e)
	return c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 过滤可以作为cost除外的卡，且除外后场上仍有可作为效果对象的怪兽
function c7574904.rmcostfilter(c,e,tp)
	-- 判定该卡是否能作为cost除外，且场上存在至少1只可作为效果对象的怪兽
	return c:IsAbleToRemoveAsCost() and Duel.IsExistingMatchingCard(c7574904.rmtgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c,e)
end
-- 效果②的cost：从自己的手卡·场上把1张卡除外
function c7574904.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定手卡或场上是否存在可作为cost除外的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c7574904.rmcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择手卡或场上的1张卡作为cost除外
	local g=Duel.SelectMatchingCard(tp,c7574904.rmcostfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选择的卡作为cost除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的靶向/发动准备：选择场上1只怪兽为对象
function c7574904.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	-- 判定场上是否存在可以除外的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择场上1只可以除外的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁信息，表示该效果的操作为除外指定的怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
-- 效果②的效果处理：将作为对象的怪兽除外
function c7574904.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将作为对象的怪兽除外
		Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	end
end
-- 效果③的发动条件：这张卡被对方破坏
function c7574904.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp)
end
-- 过滤除外的表侧表示的「秘异三变」魔法卡
function c7574904.thtgfilter(c)
	return c:IsSetCard(0x157) and c:IsType(TYPE_SPELL) and c:IsAbleToHand() and c:IsFaceup()
end
-- 效果③的靶向/发动准备：选择除外的1张自己的「秘异三变」魔法卡为对象
function c7574904.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and c7574904.thtgfilter(chkc) end
	-- 判定除外的卡中是否存在可以加入手牌的「秘异三变」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c7574904.thtgfilter,tp,LOCATION_REMOVED,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择除外的1张自己的「秘异三变」魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c7574904.thtgfilter,tp,LOCATION_REMOVED,0,1,1,nil)
	-- 设置连锁信息，表示该效果的操作为将卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果③的效果处理：将作为对象的卡加入手牌
function c7574904.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡片加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
