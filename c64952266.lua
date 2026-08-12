--アゲインスト・ウィンド
-- 效果：
-- 选择自己墓地存在的1只名字带有「黑羽」的怪兽发动。自己受到那只怪兽的攻击力数值的伤害，那只怪兽加入手卡。
function c64952266.initial_effect(c)
	-- 选择自己墓地存在的1只名字带有「黑羽」的怪兽发动。自己受到那只怪兽的攻击力数值的伤害，那只怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c64952266.target)
	e1:SetOperation(c64952266.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己墓地中名字带有「黑羽」且攻击力大于0、可以加入手卡的怪兽
function c64952266.filter(c)
	return c:IsSetCard(0x33) and c:IsType(TYPE_MONSTER) and c:GetAttack()>0 and c:IsAbleToHand()
end
-- 效果发动的目标选择与操作信息注册
function c64952266.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c64952266.filter(chkc) end
	-- 在发动阶段，检查自己墓地是否存在符合条件的怪兽
	if chk==0 then return Duel.IsExistingTarget(c64952266.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 设置提示信息：请选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只符合条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c64952266.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 注册操作信息：将选中的怪兽加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
	-- 注册操作信息：对自身造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,0)
end
-- 效果处理：给予自身伤害，并将目标怪兽加入手卡
function c64952266.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 若对象怪兽仍适用，则给予自身该怪兽攻击力数值的伤害
	if tc and tc:IsRelateToEffect(e) and Duel.Damage(tp,tc:GetAttack(),REASON_EFFECT)~=0 then
		-- 将该怪兽加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,tc)
	end
end
