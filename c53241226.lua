--クロス・オーバー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽和自己场上1只战士族怪兽为对象才能发动。那只对方的表侧表示怪兽当作装备卡使用给那只自己怪兽装备，直到回合结束时那只自己怪兽的战斗发生的对对方的战斗伤害变成0。装备怪兽被战斗·效果破坏的场合，作为代替把用这张卡的效果来装备的怪兽破坏。
function c53241226.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53241226+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53241226.target)
	e1:SetOperation(c53241226.activate)
	c:RegisterEffect(e1)
end
-- 检索满足条件的对方怪兽（表侧表示且能改变控制权）
function c53241226.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 检索满足条件的己方怪兽（表侧表示且为战士族）
function c53241226.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果作用：判断是否满足发动条件，即己方魔法陷阱区域有空位、对方场上存在符合条件的怪兽、己方场上存在符合条件的战士族怪兽
function c53241226.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取己方魔法陷阱区域可用空格数
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	if chk==0 then return ct>0
		-- 判断对方场上是否存在满足条件的怪兽
		and Duel.IsExistingTarget(c53241226.eqfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 判断己方场上是否存在满足条件的战士族怪兽
		and Duel.IsExistingTarget(c53241226.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择对方的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上的怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c53241226.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 提示玩家选择自己的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择己方场上的战士族怪兽作为效果对象
	Duel.SelectTarget(tp,c53241226.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果作用：处理装备卡的装备过程，包括设置装备限制、代替破坏和战斗伤害归零效果
function c53241226.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取当前连锁的效果对象卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local hc=g:GetFirst()
	if hc==tc then hc=g:GetNext() end
	if hc:IsControler(tp) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:IsControler(1-tp) and tc:IsLocation(LOCATION_MZONE)
		-- 判断目标怪兽是否能被装备并执行装备操作
		and tc:IsAbleToChangeControler() and Duel.Equip(tp,tc,hc,false) then
		-- 效果原文内容：①：以对方场上1只表侧表示怪兽和自己场上1只战士族怪兽为对象才能发动。那只对方的表侧表示怪兽当作装备卡使用给那只自己怪兽装备，直到回合结束时那只自己怪兽的战斗发生的对对方的战斗伤害变成0。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(hc)
		e1:SetValue(c53241226.eqlimit)
		tc:RegisterEffect(e1,true)
		-- 效果原文内容：装备怪兽被战斗·效果破坏的场合，作为代替把用这张卡的效果来装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c53241226.desrepval)
		tc:RegisterEffect(e2,true)
		-- 效果原文内容：直到回合结束时那只自己怪兽的战斗发生的对对方的战斗伤害变成0。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		hc:RegisterEffect(e3,true)
	end
end
-- 限制该装备卡只能装备给指定的怪兽
function c53241226.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 判断是否为战斗或效果破坏，用于代替破坏效果
function c53241226.desrepval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end
