--六武派二刀流
-- 效果：
-- 自己场上存在的怪兽只有表侧攻击表示存在的名字带有「六武众」的怪兽1只的场合才能发动。选择对方场上存在的2张卡回到持有者手卡。
function c75525309.initial_effect(c)
	-- 自己场上存在的怪兽只有表侧攻击表示存在的名字带有「六武众」的怪兽1只的场合才能发动。选择对方场上存在的2张卡回到持有者手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetCondition(c75525309.condition)
	e1:SetTarget(c75525309.target)
	e1:SetOperation(c75525309.activate)
	c:RegisterEffect(e1)
end
-- 判定发动条件：自己场上的怪兽是否仅有1只表侧攻击表示的「六武众」怪兽
function c75525309.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上怪兽区域的所有卡片
	local g=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local ct=g:GetCount()
	local tg=g:GetFirst()
	return ct==1 and tg:IsFaceup() and tg:IsAttackPos() and tg:IsSetCard(0x103d)
end
-- 效果的目标选择：检测并选择对方场上2张卡作为对象，并设置效果处理信息
function c75525309.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 在发动阶段（chk==0），检测对方场上是否存在至少2张可以回到手牌的卡片
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,nil) end
	-- 提示玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 选择对方场上2张可以回到手牌的卡片作为效果对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,0,LOCATION_ONFIELD,2,2,nil)
	-- 设置效果处理信息：将选中的卡片送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
end
-- 效果处理：获取对象卡片，并将仍符合条件的卡片送回持有者手牌
function c75525309.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍受效果影响的对象卡片送回持有者的手牌
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
