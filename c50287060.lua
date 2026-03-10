--暗黒魔族ギルファー・デーモン
-- 效果：
-- ①：这张卡被送去墓地时，以场上1只表侧表示怪兽为对象才能发动。墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
function c50287060.initial_effect(c)
	-- 效果原文内容：①：这张卡被送去墓地时，以场上1只表侧表示怪兽为对象才能发动。墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
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
-- 规则层面操作：检查是否满足发动条件，即玩家场上是否存在可选择的表侧表示怪兽。
function c50287060.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 规则层面操作：判断玩家魔陷区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 规则层面操作：确认场上是否存在至少一只表侧表示的怪兽作为目标。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 规则层面操作：向玩家发送提示信息，提示其选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 规则层面操作：选择一个场上的表侧表示怪兽作为装备对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 规则层面操作：设置连锁的操作信息，表明此效果将涉及从墓地离开的卡片。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
-- 规则层面操作：定义装备限制函数，确保只有装备卡本身能装备给目标怪兽。
function c50287060.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 规则层面操作：执行装备效果，包括判断是否满足装备条件并进行实际装备。
function c50287060.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 规则层面操作：检查玩家魔陷区是否有空位以进行装备。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 规则层面操作：获取当前连锁中选定的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 规则层面操作：将此卡作为装备卡装备给指定的怪兽。
		Duel.Equip(tp,c,tc)
		-- 效果原文内容：墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c50287060.eqlimit)
		c:RegisterEffect(e1)
		-- 效果原文内容：墓地的这张卡当作攻击力下降500的装备卡使用给那只怪兽装备。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(-500)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
	end
end
