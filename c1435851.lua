--ドラゴンの秘宝
-- 效果：
-- 龙族才能装备。1只装备怪兽的攻击力·守备力上升300。
function c1435851.initial_effect(c)
	-- 调用通用装备魔法辅助函数，为这张装备魔法卡注册基础装备逻辑：可装备给我方/对方场上的表侧龙族怪兽，并通过eqlimit设定仅龙族可装备。
	aux.AddEquipSpellEffect(c,true,true,c1435851.filter,c1435851.eqlimit)
	-- 对应效果原文“1只装备怪兽的攻击力·守备力上升300。”中的攻击力部分：1只装备怪兽的攻击力上升300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
	-- 对应效果原文“1只装备怪兽的攻击力·守备力上升300。”中的守备力部分：1只装备怪兽的守备力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(300)
	c:RegisterEffect(e3)
end
-- 装备限制判定函数：只有龙族怪兽才能装备这张卡（满足装备限制条件）。
function c1435851.eqlimit(e,c)
	return c:IsRace(RACE_DRAGON)
end
-- 装备对象过滤条件：怪兽必须表侧表示且为龙族，才能被选为这张装备卡的装备对象。
function c1435851.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
-- 装备魔法发动时的目标选择处理：检查并选择场上表侧表示的龙族怪兽为装备对象，设置装备分类的操作信息，供效果处理时使用。
function c1435851.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c1435851.filter(chkc) end
	-- 发动合法性检查：当且仅当场上存在至少1只表侧表示龙族怪兽时可发动。
	if chk==0 then return Duel.IsExistingTarget(c1435851.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家显示“请选择要装备的卡”的选择提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让发动玩家从双方场上选择1只表侧表示的龙族怪兽，并将其登记为本次装备效果的对象。
	Duel.SelectTarget(tp,c1435851.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备处理（CATEGORY_EQUIP），对象为这张装备魔法卡自身，用于连锁处理和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备效果处理阶段：取得装备对象，确认装备卡与目标仍与效果关联且目标表侧表示后，将这张卡装备给目标怪兽。
function c1435851.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时登记的目标怪兽，作为本次装备的对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张装备魔法卡装备到目标怪兽身上，完成装备动作。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
