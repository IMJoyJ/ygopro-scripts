--ズババジェネラル
-- 效果：
-- 4星怪兽×2
-- 1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只战士族怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
function c31563350.initial_effect(c)
	-- 为卡片添加XYZ召唤手续：用任意2只4星怪兽叠放来超量召唤（4星怪兽×2）。
	aux.AddXyzProcedure(c,nil,4,2)
	c:EnableReviveLimit()
	-- 1回合1次，把这张卡1个超量素材取除才能发动。从手卡把1只战士族怪兽当作装备卡使用给这张卡装备。这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(31563350,0))  --"装备怪兽"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c31563350.eqcost)
	e1:SetTarget(c31563350.eqtg)
	e1:SetOperation(c31563350.eqop)
	c:RegisterEffect(e1)
end
-- 代价处理：发动时检查能否取除这张卡的1个超量素材；确定发动后实际取除1个超量素材作为代价。
function c31563350.eqcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 装备对象筛选条件：从手卡选择1只战士族怪兽，要求该怪兽为战士族、在我方场上不存在同名卡（满足场上唯一性），且不属于禁止卡。
function c31563350.filter(c,tp)
	return c:IsRace(RACE_WARRIOR) and c:CheckUniqueOnField(tp) and not c:IsForbidden()
end
-- 发动目标检查：我方魔陷区有空位，且手卡存在符合条件的战士族怪兽；由于效果处理时才选择装备的怪兽，因此发动时无需取对象。
function c31563350.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方魔陷区是否有可用空格，用于容纳将要装备的装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查手卡是否存在至少1张满足条件的战士族怪兽（可供选择装备）。
		and Duel.IsExistingMatchingCard(c31563350.filter,tp,LOCATION_HAND,0,1,nil,tp) end
end
-- 效果处理：再次确认魔陷区空位、本卡仍表侧且与发动效果关联后，从手卡选择1张符合条件的战士族怪兽，将其作为装备卡装备给本卡，并为该装备卡设置装备对象限制与攻击力上升效果。
function c31563350.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次检查魔陷区是否有空位，若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 向操作玩家显示选择装备卡的系统提示（请选择要装备的卡）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从手卡中选出1张满足过滤条件的战士族怪兽（此为处理时的选择，不取对象）。
	local g=Duel.SelectMatchingCard(tp,c31563350.filter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的战士族怪兽作为装备卡装备到这张卡上；若装备未能成功则终止后续处理。
		if not Duel.Equip(tp,tc,c) then return end
		-- “从手卡把1只战士族怪兽当作装备卡使用给这张卡装备”——为装备卡设置装备限制效果，使其只能装备给效果的所有者（即这张卡）。
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c31563350.eqlimit)
		tc:RegisterEffect(e1)
		local atk=tc:GetTextAttack()
		if atk>0 then
			-- 这张卡的攻击力上升这个效果装备的怪兽的攻击力数值。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_EQUIP)
			e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_OWNER_RELATE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			e2:SetValue(atk)
			tc:RegisterEffect(e2)
		end
	end
end
-- 装备限制判定函数：只有当被装备的对象是效果所有者（这张卡本身）时才允许装备。
function c31563350.eqlimit(e,c)
	return e:GetOwner()==c
end
