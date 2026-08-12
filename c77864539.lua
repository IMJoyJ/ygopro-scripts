--機皇廠
-- 效果：
-- 场上表侧表示存在的名字带有「机皇」的怪兽被选择作为攻击对象时才能发动。选择自己墓地存在的1只名字带有「机皇兵」的怪兽加入手卡。那之后，成为攻击对象的怪兽破坏。
function c77864539.initial_effect(c)
	-- 场上表侧表示存在的名字带有「机皇」的怪兽被选择作为攻击对象时才能发动。选择自己墓地存在的1只名字带有「机皇兵」的怪兽加入手卡。那之后，成为攻击对象的怪兽破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(c77864539.condition)
	e1:SetTarget(c77864539.target)
	e1:SetOperation(c77864539.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：被选择作为攻击对象的怪兽是否是表侧表示的「机皇」怪兽
function c77864539.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的攻击对象怪兽
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsSetCard(0x13)
end
-- 过滤墓地中名字带有「机皇兵」且能加入手牌的怪兽
function c77864539.filter(c)
	return c:IsSetCard(0x6013) and c:IsAbleToHand()
end
-- 效果发动的对象选择与操作准备，选择墓地的「机皇兵」怪兽为对象，并注册破坏标记与设置操作信息
function c77864539.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c77864539.filter(chkc) end
	-- 检查墓地是否存在可加入手牌的「机皇兵」怪兽
	if chk==0 then return Duel.IsExistingTarget(c77864539.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「机皇兵」怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c77864539.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 获取当前的攻击对象怪兽
	local d=Duel.GetAttackTarget()
	d:RegisterFlagEffect(77864539,RESET_EVENT+0x3fe0000,0,1)
	-- 设置效果处理的操作信息，表明此效果包含破坏攻击对象怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
-- 效果处理：将对象怪兽加入手牌，之后破坏成为攻击对象的怪兽
function c77864539.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的作为效果对象的「机皇兵」怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为效果对象的「机皇兵」怪兽加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 让对方玩家确认加入手牌的卡片
		Duel.ConfirmCards(1-tp,tc)
		-- 获取当前的攻击对象怪兽
		local d=Duel.GetAttackTarget()
		if d:GetFlagEffect(77864539)~=0 then
			-- 将成为攻击对象的怪兽破坏
			Duel.Destroy(d,REASON_EFFECT)
		end
	end
end
