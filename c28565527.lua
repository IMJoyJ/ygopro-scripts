--黄龍の召喚士
-- 效果：
-- 「黄龙召唤士」的效果1回合只能使用1次。
-- ①：把自己场上1只怪兽解放，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
function c28565527.initial_effect(c)
	-- 「黄龙召唤士」的效果1回合只能使用1次。①：把自己场上1只怪兽解放，以场上1只怪兽为对象才能发动。那只怪兽回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(28565527,0))  --"回到手牌"
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,28565527)
	e1:SetCost(c28565527.cost)
	e1:SetTarget(c28565527.target)
	e1:SetOperation(c28565527.operation)
	c:RegisterEffect(e1)
end
-- 定义代价辅助过滤函数：用于确认将某只怪兽作为解放代价后，场上仍有至少1只可成为回手牌对象的怪兽。
function c28565527.cfilter(c)
	-- 检查双方怪兽区是否存在至少1只除c以外、可作为效果对象且能被送回手卡的怪兽。
	return Duel.IsExistingTarget(Card.IsAbleToHand,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
-- 代价函数：在发动前选择自己场上1只满足条件的怪兽解放作为代价；合法性检查时确认存在这样的可解放怪兽。
function c28565527.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查阶段：确认自己场上存在至少1只满足cfilter条件的可解放怪兽（即解放后场上仍有可回手牌对象的怪兽）。
	if chk==0 then return Duel.CheckReleaseGroup(tp,c28565527.cfilter,1,nil) end
	-- 从自己场上选择1只满足cfilter条件的怪兽作为解放代价。
	local g=Duel.SelectReleaseGroup(tp,c28565527.cfilter,1,1,nil)
	-- 将选择出的怪兽解放，作为发动效果的代价。
	Duel.Release(g,REASON_COST)
end
-- 目标选择函数：效果发动时指定场上1只可回手牌的怪兽为对象，并设置回手牌的操作信息；chkc时验证对象是否在怪兽区且可回手牌。
function c28565527.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToHand() end
	if chk==0 then return true end
	-- 弹出选择提示，提示玩家选择要返回手牌的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让发动玩家从双方怪兽区选择1只可回手牌的怪兽作为效果对象（取对象）。
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置本次连锁的操作信息：将对象g的1张卡加入手牌（回手牌），用于后续时点和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理函数：将发动时选择的对象怪兽送回持有者手卡。
function c28565527.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象怪兽送回其持有者手卡（REASON_EFFECT表示效果处理）。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
