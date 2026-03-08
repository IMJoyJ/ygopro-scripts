--シー・アーチャー
-- 效果：
-- 1回合1次，可以把自己场上表侧表示存在的3星以下的怪兽当作装备卡使用只有1只给这张卡装备。这个效果把怪兽装备的场合，这张卡的攻击力上升800。这张卡被破坏的场合，可以作为代替把装备的怪兽破坏。
function c4252828.initial_effect(c)
	-- 1回合1次，可以把自己场上表侧表示存在的3星以下的怪兽当作装备卡使用只有1只给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(4252828,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c4252828.eqcon)
	e1:SetTarget(c4252828.eqtg)
	e1:SetOperation(c4252828.eqop)
	c:RegisterEffect(e1)
	-- 这张卡被破坏的场合，可以作为代替把装备的怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetTarget(c4252828.desreptg)
	e2:SetOperation(c4252828.desrepop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 判断装备效果是否可以发动，当没有装备怪兽或装备怪兽已不在场上或装备效果未触发时可发动。
function c4252828.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or not ec:IsHasCardTarget(c) or ec:GetFlagEffect(4252828)==0
end
-- 筛选场上表侧表示存在的3星以下的怪兽作为目标。
function c4252828.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3)
end
-- 设置装备效果的选择目标，检查是否有满足条件的怪兽可作为装备对象。
function c4252828.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4252828.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查玩家场上是否有足够的魔法陷阱区域来装备怪兽。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在满足条件的怪兽作为装备对象。
		and Duel.IsExistingTarget(c4252828.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的怪兽作为装备对象。
	local g=Duel.SelectTarget(tp,c4252828.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 限制装备对象只能是装备卡的持有者。
function c4252828.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 执行装备操作，将怪兽装备给海洋弓手，并设置装备限制和攻击力加成效果。
function c4252828.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取装备效果的目标怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 尝试将目标怪兽装备给海洋弓手，若失败则返回。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(4252828,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 设置装备对象的限制效果，确保只有海洋弓手能装备该怪兽。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c4252828.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置装备怪兽时攻击力上升800的效果。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(800)
		tc:RegisterEffect(e2)
	end
end
-- 判断是否可以发动代替破坏效果，检查是否有装备怪兽且未被预定破坏。
function c4252828.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=e:GetLabelObject():GetLabelObject()
	if chk==0 then return ec and ec:IsHasCardTarget(c) and ec:GetFlagEffect(4252828)~=0
		and ec:IsDestructable(e) and not ec:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not c:IsReason(REASON_REPLACE) end
	-- 向玩家确认是否发动代替破坏效果。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 执行代替破坏效果，将装备的怪兽破坏。
function c4252828.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 将装备的怪兽从游戏中破坏。
	Duel.Destroy(e:GetLabelObject():GetLabelObject(),REASON_EFFECT+REASON_REPLACE)
end
