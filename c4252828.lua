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
-- 起动效果（装备）的发动条件：检查e1的标签对象（此前用此效果装备的怪兽）是否仍存在并装备于这张卡；若不存在或已不再以此卡为对象或已无装备标记，则允许发动。
function c4252828.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=e:GetLabelObject()
	return ec==nil or not ec:IsHasCardTarget(c) or ec:GetFlagEffect(4252828)==0
end
-- 条件过滤器：选择自己场上表侧表示且等级3以下的怪兽。
function c4252828.filter(c)
	return c:IsFaceup() and c:IsLevelBelow(3)
end
-- 装备效果的发动时处理：需要自己魔陷区有空位，且存在表侧表示3星以下、除自身以外的合法对象；同时处理连锁时验证对象卡是否满足条件。
function c4252828.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c4252828.filter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己魔陷区是否有空闲位置，因为装备的怪兽卡将放置在魔陷区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在满足条件的表侧3星以下怪兽可以作为装备对象（且不能选择发动效果的这张卡）。
		and Duel.IsExistingTarget(c4252828.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 向自己显示选择装备对象的提示信息（请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让自己从符合条件的怪兽中选择1只作为装备目标，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c4252828.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- 装备限制函数：该怪兽作为装备卡时，只能装备给效果的所有者（即海洋弓手这张卡）。
function c4252828.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备效果处理：将选择的对象怪兽装备给海洋弓手；成功后给该怪兽打上装备标记，并赋予装备限制和给海洋弓手提升800攻击力的效果。
function c4252828.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) then
		-- 尝试将对象怪兽作为装备卡装备给海洋弓手；若装备失败（如没有空位或条件不满足）则结束处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		tc:RegisterFlagEffect(4252828,RESET_EVENT+RESETS_STANDARD,0,0)
		e:SetLabelObject(tc)
		-- 当作装备卡使用只有1只给这张卡装备（装备对象限制为只能装备给海洋弓手）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c4252828.eqlimit)
		tc:RegisterEffect(e1)
		-- 这个效果把怪兽装备的场合，这张卡的攻击力上升800。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(800)
		tc:RegisterEffect(e2)
	end
end
-- 代替破坏的触发条件：本卡将要被破坏时，检查是否存在通过本卡装备的怪兽，且该怪兽仍装备在本卡上、可被破坏且不在预定破坏状态；同时本次破坏不是由代替破坏引起的。
function c4252828.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=e:GetLabelObject():GetLabelObject()
	if chk==0 then return ec and ec:IsHasCardTarget(c) and ec:GetFlagEffect(4252828)~=0
		and ec:IsDestructable(e) and not ec:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not c:IsReason(REASON_REPLACE) end
	-- 让玩家选择是否用装备怪兽代替这张卡被破坏。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 代替破坏处理：选择用装备的怪兽代替破坏，将破坏对象转移为那只装备怪兽。
function c4252828.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 以效果和代替破坏为理由，将装备中的怪兽破坏，代替海洋弓手被破坏。
	Duel.Destroy(e:GetLabelObject():GetLabelObject(),REASON_EFFECT+REASON_REPLACE)
end
