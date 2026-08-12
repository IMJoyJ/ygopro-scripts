--騎竜
-- 效果：
-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「暗魔界的战士 暗黑之剑」装备，或者把装备解除以表侧攻击表示特殊召唤。只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升900点。可以把装备状态的这张卡作为祭品，装备怪兽在这个回合可以直接攻击对方玩家。（1只怪兽可以装备的同盟最多1张。装备怪兽被战斗破坏的场合，作为代替把这张卡破坏。）
function c84814897.initial_effect(c)
	-- 1回合只有1次在自己的主要阶段可以当作装备卡使用给自己的「暗魔界的战士 暗黑之剑」装备
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(84814897,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c84814897.eqtg)
	e1:SetOperation(c84814897.eqop)
	c:RegisterEffect(e1)
	-- 或者把装备解除以表侧攻击表示特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(84814897,1))  --"解除装备状态表侧攻击表示特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	-- 设置特殊召唤效果的发动条件为自身处于同盟装备状态
	e2:SetCondition(aux.IsUnionState)
	e2:SetTarget(c84814897.sptg)
	e2:SetOperation(c84814897.spop)
	c:RegisterEffect(e2)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升900点
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(900)
	-- 设置攻击力上升效果的适用条件为自身处于同盟装备状态
	e3:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e3)
	-- 只在这个效果当作装备卡使用时，装备怪兽的攻击力·守备力上升900点
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	e4:SetValue(900)
	-- 设置守备力上升效果的适用条件为自身处于同盟装备状态
	e4:SetCondition(aux.IsUnionState)
	c:RegisterEffect(e4)
	-- 可以把装备状态的这张卡作为祭品，装备怪兽在这个回合可以直接攻击对方玩家
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(84814897,2))  --"装备怪兽在这个回合可以直接攻击"
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	-- 设置直接攻击效果的发动条件为自身处于同盟装备状态
	e5:SetCondition(aux.IsUnionState)
	e5:SetCost(c84814897.atkcost)
	e5:SetOperation(c84814897.atkop)
	c:RegisterEffect(e5)
	-- 装备怪兽被战斗破坏的场合，作为代替把这张卡破坏
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_EQUIP)
	e6:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e6:SetCode(EFFECT_DESTROY_SUBSTITUTE)
	-- 设置代替破坏效果的适用条件为自身处于同盟装备状态
	e6:SetCondition(aux.IsUnionState)
	e6:SetValue(c84814897.repval)
	c:RegisterEffect(e6)
	-- 1只怪兽可以装备的同盟最多1张
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_SINGLE)
	e7:SetCode(EFFECT_UNION_LIMIT)
	e7:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e7:SetValue(c84814897.eqlimit)
	c:RegisterEffect(e7)
end
c84814897.old_union=true
-- 确定代替破坏的适用条件为战斗破坏
function c84814897.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 限制同盟装备对象只能是「暗魔界的战士 暗黑之剑」
function c84814897.eqlimit(e,c)
	return c:IsCode(11321183)
end
-- 过滤场上表侧表示、卡名为「暗魔界的战士 暗黑之剑」且未装备同盟怪兽的怪兽
function c84814897.filter(c)
	return c:IsFaceup() and c:IsCode(11321183) and c:GetUnionCount()==0
end
-- 装备效果的发动准备与目标选择函数
function c84814897.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c84814897.filter(chkc) end
	-- 检查本回合是否未使用过同盟效果，且魔陷区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(84814897)==0 and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在可以装备的合法目标怪兽
		and Duel.IsExistingTarget(c84814897.filter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定一个合法的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c84814897.filter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 设置连锁中的操作信息为装备分类，目标为选择的怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
	e:GetHandler():RegisterFlagEffect(84814897,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 装备效果的执行函数
function c84814897.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中锁定的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	if not tc:IsRelateToEffect(e) or not c84814897.filter(tc) then
		-- 若装备目标已不合法，则将自身送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束处理
	if not Duel.Equip(tp,c,tc,false) then return end
	-- 将自身状态设置为同盟装备状态
	aux.SetUnionState(c)
end
-- 特殊召唤效果的发动准备与目标选择函数
function c84814897.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查本回合是否未使用过同盟效果，且怪兽区有空位
	if chk==0 then return e:GetHandler():GetFlagEffect(84814897)==0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,true,false,POS_FACEUP_ATTACK) end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置连锁中的操作信息为特殊召唤分类，目标为自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
	e:GetHandler():RegisterFlagEffect(84814897,RESET_EVENT+0x7e0000+RESET_PHASE+PHASE_END,0,1)
end
-- 特殊召唤效果的执行函数
function c84814897.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将自身以表侧攻击表示特殊召唤到场上
	Duel.SpecialSummon(c,0,tp,tp,true,false,POS_FACEUP_ATTACK)
end
-- 直接攻击效果的发动代价处理函数
function c84814897.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 向对方玩家提示当前发动的效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 将当前装备的怪兽锁定为效果处理的目标
	Duel.SetTargetCard(e:GetHandler():GetEquipTarget())
	-- 解放自身作为发动效果的代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 直接攻击效果的执行函数
function c84814897.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被锁定的原装备怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 装备怪兽在这个回合可以直接攻击对方玩家
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
