--アマゾネスの呪詛師
-- 效果：
-- 到回合终了时为止，自己场上1只表侧表示的名称中含有「亚马逊」字样的怪兽与对方场上1只表侧表示的怪兽的原本攻击力相互交换。
function c81325903.initial_effect(c)
	-- 到回合终了时为止，自己场上1只表侧表示的名称中含有「亚马逊」字样的怪兽与对方场上1只表侧表示的怪兽的原本攻击力相互交换。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c81325903.target)
	e1:SetOperation(c81325903.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且卡名含有「亚马逊」的卡
function c81325903.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x4)
end
-- 效果发动的靶向检测，判断双方场上是否存在符合条件的可选择对象
function c81325903.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 在效果发动时，检测自己场上是否存在至少1只表侧表示的「亚马逊」怪兽
	if chk==0 then return Duel.IsExistingTarget(c81325903.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 同时检测对方场上是否存在至少1只表侧表示的怪兽
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「亚马逊」怪兽作为效果对象
	Duel.SelectTarget(tp,c81325903.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择对方场上1只表侧表示的怪兽作为效果对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_MZONE,1,1,nil)
end
-- 效果处理：获取对象怪兽，若均表侧表示且仍与效果关联，则交换它们的原本攻击力，持续到回合结束
function c81325903.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc1=g:GetFirst()
	local tc2=g:GetNext()
	if tc1:IsFaceup() and tc2:IsFaceup() and tc1:IsRelateToEffect(e) and tc2:IsRelateToEffect(e) then
		local atk1=tc1:GetBaseAttack()
		local atk2=tc2:GetBaseAttack()
		-- 到回合终了时为止，自己场上1只表侧表示的名称中含有「亚马逊」字样的怪兽与对方场上1只表侧表示的怪兽的原本攻击力相互交换。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e1:SetValue(atk2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc1:RegisterEffect(e1)
		-- 到回合终了时为止，自己场上1只表侧表示的名称中含有「亚马逊」字样的怪兽与对方场上1只表侧表示的怪兽的原本攻击力相互交换。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_SET_BASE_ATTACK_FINAL)
		e2:SetValue(atk1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc2:RegisterEffect(e2)
	end
end
