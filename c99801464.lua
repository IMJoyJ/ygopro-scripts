--銀翼のAXE－サリー
-- 效果：
-- 这个卡名的效果1回合只能使用1次。
-- ①：以场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力·守备力上升100的装备卡使用给那只怪兽装备。这个效果在对方回合也能发动。
function c99801464.initial_effect(c)
	-- 这个卡名的效果1回合只能使用1次。①：以场上1只表侧表示怪兽为对象才能发动。从自己的手卡·场上把这张卡当作攻击力·守备力上升100的装备卡使用给那只怪兽装备。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetCountLimit(1,99801464)
	-- 设置效果的发动条件，使用aux.dscon限定不能在伤害步骤中发动（若在伤害步骤则需在伤害计算前）。
	e1:SetCondition(aux.dscon)
	e1:SetTarget(c99801464.eqtg)
	e1:SetOperation(c99801464.eqop)
	c:RegisterEffect(e1)
end
-- 定义筛选条件：选择场上表侧表示怪兽（IsFaceup）作为装备对象。
function c99801464.filter(c)
	return c:IsFaceup()
end
-- 效果发动时的目标选择处理：获取效果持有者，进行连锁对象检查（是否为场上表侧表示怪兽且不是自身），并初步判断是否可以发动。
function c99801464.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c99801464.filter(chkc) and chkc~=c end
	-- 发动合法性检查：自己的魔陷区必须存在空位，才能将这张卡装备上场。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动合法性检查：场上必须存在1只满足条件的表侧表示怪兽（且不是这张卡自身）作为装备对象。
		and Duel.IsExistingTarget(c99801464.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,c) end
	-- 向操作者发送选择提示信息，提示内容为“请选择要装备的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作者从自己和他人的怪兽区选择1只表侧表示怪兽作为装备对象，并登记为当前连锁的对象。
	Duel.SelectTarget(tp,c99801464.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,c)
	-- 登记本次效果的处理信息：将进行装备（CATEGORY_EQUIP）操作，对象为效果持有者这张卡，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理时的执行操作：检查这张卡和对象状态，若魔陷区无空位或对象已不合法则将此卡送去墓地；否则将此卡装备给对象，并附加只能装备给该对象的限制及攻击力·守备力上升100的效果。
function c99801464.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 继续装备前再次确认条件：魔陷区仍有空位，且对象怪兽仍是表侧表示且与效果相关。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因条件不满足无法装备，将这张卡以效果原因送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将这张卡作为装备卡装备给目标怪兽，占用自己的魔陷区。
	Duel.Equip(tp,c,tc)
	-- 给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetLabelObject(tc)
	e1:SetValue(c99801464.eqlimit)
	c:RegisterEffect(e1)
	-- 攻击力·守备力上升100
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(100)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
end
-- 定义装备限制：只有原本指定的目标怪兽（e:GetLabelObject()）才能装备这张卡，防止装备到其他怪兽。
function c99801464.eqlimit(e,c)
	return c==e:GetLabelObject()
end
