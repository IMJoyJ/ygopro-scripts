--犬賞金
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己怪兽的攻击破坏对方怪兽时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
function c55351724.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己怪兽的攻击破坏对方怪兽时，以自己墓地1张卡为对象才能发动。那张卡加入手卡。这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetCountLimit(1,55351724+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c55351724.condition)
	e1:SetTarget(c55351724.target)
	e1:SetOperation(c55351724.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自己怪兽的攻击破坏对方怪兽时
function c55351724.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	-- 判断破坏对方怪兽的怪兽是否为当前进行攻击的自己怪兽，且该战斗是与对方怪兽进行的战斗
	return tc==Duel.GetAttacker() and tc:IsStatus(STATUS_OPPO_BATTLE) and tc:IsControler(tp)
end
-- 效果发动时的对象选择与合法性检查
function c55351724.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and chkc:IsAbleToHand() end
	-- 在发动阶段（chk==0）检查自己墓地是否存在至少1张可以加入手牌的卡
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向玩家发送提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张可以加入手牌的卡作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息，表明此效果的处理分类为将选中的1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理：将对象卡加入手牌，并注册本回合不能发动该卡及同名卡效果的限制
function c55351724.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动时选择的对象卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡仍与效果相关，且成功加入手牌，则执行后续限制效果
	if tc:IsRelateToEffect(e) and Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
		-- 这个回合，自己不能作这个效果加入手卡的卡以及那些同名卡的效果的发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(c55351724.actlimit)
		e1:SetLabel(tc:GetCode())
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 向玩家注册该限制效果，使其在本回合内生效
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制效果的判定函数，阻止与加入手牌的卡同名的卡片效果的发动
function c55351724.actlimit(e,re,tp)
	return re:GetHandler():IsCode(e:GetLabel())
end
