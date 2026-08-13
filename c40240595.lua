--進化の繭
-- 效果：
-- 这张卡可以从手卡当作装备卡使用给场上表侧表示存在的「飞蛾宝宝」装备。用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用。
function c40240595.initial_effect(c)
	-- 对应效果原文：‘这张卡可以从手卡当作装备卡使用给场上表侧表示存在的「飞蛾宝宝」装备。用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40240595,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetTarget(c40240595.eqtg)
	e1:SetOperation(c40240595.eqop)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：选择我方场上表侧表示且卡号为58192742的「飞蛾宝宝」作为装备对象。
function c40240595.filter(c)
	return c:IsFaceup() and c:IsCode(58192742)
end
-- 效果的目标选择函数：在发动时确定对象，并在连锁处理时校验对象；若未指定对象且为初始检查，则要求场上有符合条件的「飞蛾宝宝」。
function c40240595.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c40240595.filter(chkc) end
	-- 发动条件检查：我方魔陷区需要有可用空格，才能将此卡从手卡装备到场上。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 发动条件检查：我方主要怪兽区存在至少1只满足过滤条件的「飞蛾宝宝」可作为装备对象。
		and Duel.IsExistingTarget(c40240595.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示“请选择要装备的卡”，用于选择装备对象时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从我方场上的「飞蛾宝宝」中选择1只作为装备对象，并将其登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c40240595.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将进化之茧装备给选中的「飞蛾宝宝」，若条件不符则送墓；装备成功后为装备状态的进化之茧创建装备限制、回合结束计数以及攻击力/守备力变化效果。
function c40240595.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取发动时选择的目标「飞蛾宝宝」。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认：装备区有空位、目标仍由我方控制、表侧表示且与效果关联，否则装备失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 因装备条件不满足，将进化之茧从手牌送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将进化之茧作为装备卡装备给目标「飞蛾宝宝」。
	Duel.Equip(tp,c,tc)
	-- 对应效果原文中‘给场上表侧表示存在的「飞蛾宝宝」装备’的限定：设置装备限制，只允许装备给发动时选择的那只「飞蛾宝宝」（记录在LabelObject中）。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetValue(c40240595.eqlimit)
	e1:SetLabelObject(tc)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e1)
	-- 对应效果原文中‘用这个效果把这张卡装备的「飞蛾宝宝」的攻击力·守备力按「进化之茧」的数值适用’的辅助计数：每个自己回合结束阶段将进化之茧的回合计数器+1。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCondition(c40240595.checkcon)
	e2:SetOperation(c40240595.checkop)
	e2:SetCountLimit(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	-- 对应效果原文中‘攻击力·守备力按「进化之茧」的数值适用’中的攻击力部分：装备状态下将「飞蛾宝宝」的原本攻击力变为进化之茧的攻击力数值（0）。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_SET_BASE_ATTACK)
	e3:SetValue(0)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e3)
	-- 对应效果原文中‘攻击力·守备力按「进化之茧」的数值适用’中的守备力部分：装备状态下将「飞蛾宝宝」的原本守备力变为进化之茧的守备力数值（2000）。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_SET_BASE_DEFENSE)
	e4:SetValue(2000)
	e4:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e4)
	c:SetTurnCounter(0)
end
-- 结束阶段计数效果的触发条件：当前回合玩家为装备卡的控制者tp。
function c40240595.checkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否是tp，只有在自己的结束阶段才执行计数。
	return Duel.GetTurnPlayer()==tp
end
-- 结束阶段操作：将进化之茧的回合计数器加1，用于记录装备持续回合数。
function c40240595.checkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=c:GetTurnCounter()
	ct=ct+1
	c:SetTurnCounter(ct)
end
-- 装备限制判定：只允许装备给e:GetLabelObject()指定的那只「飞蛾宝宝」，防止转移装备对象。
function c40240595.eqlimit(e,c)
	return c==e:GetLabelObject()
end
