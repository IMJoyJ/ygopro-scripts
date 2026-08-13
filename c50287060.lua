--暗黒魔族ギルファー・デーモン
-- 效果：
-- ①：这张卡被送去墓地时，以场上1只表侧表示怪兽为对象才能发动。墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
function c50287060.initial_effect(c)
	-- ①：这张卡被送去墓地时，以场上1只表侧表示怪兽为对象才能发动。墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(50287060,0))  --"装备"
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(c50287060.eqtg)
	e1:SetOperation(c50287060.eqop)
	c:RegisterEffect(e1)
end
-- 效果发动时的目标选择与条件判定：若有已选对象则检查其是否仍为场上表侧表示怪兽并位于怪兽区；若为发动判定阶段，则检查己方魔陷区是否有空位且场上是否存在可选择的表侧表示怪兽。
function c50287060.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查己方魔陷区是否存在至少1个空位，以决定能否将墓地中的这张卡装备给怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在至少1只表侧表示怪兽，可作为这张卡装备的对象。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示选择装备对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从场上的表侧表示怪兽中选择1只作为效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息，声明墓地的这张卡将离开墓地（用于关联王家长眠之谷等墓地效果）。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 定义装备限制条件：这张卡只能装备给效果发动时选择的那只怪兽。
function c50287060.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 效果处理：确认魔陷区有空位后，获取对象怪兽，将这张卡装备给该怪兽，并给它附加攻击力下降500的装备效果。
function c50287060.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果己方魔陷区没有空位，则无法装备，直接结束效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取效果发动时选择的那只对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 将墓地中的这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50287060.eqlimit)
		c:RegisterEffect(e1)
		-- 攻击力下降500。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
