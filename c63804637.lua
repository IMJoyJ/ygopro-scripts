--幻奏のイリュージョン
-- 效果：
-- ①：以自己场上1只「幻奏」怪兽为对象才能发动。这个回合，那只自己怪兽不受对方的魔法·陷阱卡的效果影响，同1次的战斗阶段中可以作2次攻击。
function c63804637.initial_effect(c)
	-- ①：以自己场上1只「幻奏」怪兽为对象才能发动。这个回合，那只自己怪兽不受对方的魔法·陷阱卡的效果影响，同1次的战斗阶段中可以作2次攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c63804637.target)
	e1:SetOperation(c63804637.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上表侧表示的「幻奏」怪兽
function c63804637.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 效果发动时的对象选择与合法性检查
function c63804637.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63804637.filter(chkc) end
	-- 检查自己场上是否存在符合条件的「幻奏」怪兽作为对象
	if chk==0 then return Duel.IsExistingTarget(c63804637.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的「幻奏」怪兽作为效果对象
	Duel.SelectTarget(tp,c63804637.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：使目标怪兽获得不受对方魔陷影响以及同一次战斗阶段可作2次攻击的效果
function c63804637.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsControler(tp) then
		-- 这个回合，那只自己怪兽不受对方的魔法·陷阱卡的效果影响
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_IMMUNE_EFFECT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c63804637.efilter)
		e1:SetOwnerPlayer(tp)
		tc:RegisterEffect(e1)
		-- 同1次的战斗阶段中可以作2次攻击
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_EXTRA_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(1)
		tc:RegisterEffect(e2)
	end
end
-- 免疫过滤：判定来源是否为对方玩家发动的魔法或陷阱卡的效果
function c63804637.efilter(e,re)
	return e:GetOwnerPlayer()~=re:GetOwnerPlayer() and re:IsActiveType(TYPE_SPELL+TYPE_TRAP)
end
