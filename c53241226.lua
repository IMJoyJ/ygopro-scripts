--クロス・オーバー
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以对方场上1只表侧表示怪兽和自己场上1只战士族怪兽为对象才能发动。那只对方的表侧表示怪兽当作装备卡使用给那只自己怪兽装备，直到回合结束时那只自己怪兽的战斗发生的对对方的战斗伤害变成0。装备怪兽被战斗·效果破坏的场合，作为代替把用这张卡的效果来装备的怪兽破坏。
function c53241226.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以对方场上1只表侧表示怪兽和自己场上1只战士族怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,53241226+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c53241226.target)
	e1:SetOperation(c53241226.activate)
	c:RegisterEffect(e1)
end
-- 筛选对方场上可装备的表侧表示怪兽：需表侧表示且没有‘不能改变控制权’的限制。
function c53241226.eqfilter(c)
	return c:IsFaceup() and c:IsAbleToChangeControler()
end
-- 筛选自己场上可作为装备对象的战士族怪兽：需表侧表示且种族为战士族。
function c53241226.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 效果发动时的目标选择处理：检查魔陷区有空格、对方场上存在符合条件的怪兽、自己场上存在战士族怪兽，并选择两只对象。
function c53241226.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己魔陷区的可用区域数量，用于判断是否能放置装备卡。
	local ct=Duel.GetLocationCount(tp,LOCATION_SZONE)
	if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then ct=ct-1 end
	if chk==0 then return ct>0
		-- 检查对方场上是否存在至少1只表侧表示且可改变控制权的怪兽。
		and Duel.IsExistingTarget(c53241226.eqfilter,tp,0,LOCATION_MZONE,1,nil)
		-- 检查自己场上是否存在至少1只表侧表示战士族怪兽。
		and Duel.IsExistingTarget(c53241226.tgfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 弹出“请选择对方的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只符合条件的表侧表示怪兽作为对象，并记录为连锁对象。
	local g=Duel.SelectTarget(tp,c53241226.eqfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 弹出“请选择自己的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只符合条件的表侧表示战士族怪兽作为对象。
	Duel.SelectTarget(tp,c53241226.tgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果处理：将对方怪兽作为装备卡装备给自己怪兽，并赋予装备限制、代替破坏和战斗伤害为0的效果。
function c53241226.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	-- 获取本次连锁处理中记录的对象卡组。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local hc=g:GetFirst()
	if hc==tc then hc=g:GetNext() end
	if hc:IsControler(tp) and tc:IsFaceup() and tc:IsRelateToEffect(e)
		and tc:IsControler(1-tp) and tc:IsLocation(LOCATION_MZONE)
		-- 确认对方怪兽仍可改变控制权且装备成功，则继续设置后续效果。
		and tc:IsAbleToChangeControler() and Duel.Equip(tp,tc,hc,false) then
		-- 那只对方的表侧表示怪兽当作装备卡使用给那只自己怪兽装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(hc)
		e1:SetValue(c53241226.eqlimit)
		tc:RegisterEffect(e1,true)
		-- 装备怪兽被战斗·效果破坏的场合，作为代替把用这张卡的效果来装备的怪兽破坏。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(c53241226.desrepval)
		tc:RegisterEffect(e2,true)
		-- 直到回合结束时那只自己怪兽的战斗发生的对对方的战斗伤害变成0。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_NO_BATTLE_DAMAGE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		hc:RegisterEffect(e3,true)
	end
end
-- 装备限制判定：这张装备卡只能装备给作为对象的那只自己怪兽。
function c53241226.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 代替破坏判定：当装备怪兽被战斗或效果破坏时返回真，触发代替破坏。
function c53241226.desrepval(e,re,r,rp)
	return r&(REASON_BATTLE|REASON_EFFECT)~=0
end
