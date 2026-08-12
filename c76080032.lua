--ZW－一角獣皇槍
-- 效果：
-- 自己的主要阶段时，手卡的这张卡可以当作攻击力上升1900的装备卡使用给自己场上的「混沌No.39 希望皇 霍普雷」装备。装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。「异热同心武器-独角兽皇枪」在自己场上只能有1张表侧表示存在。
function c76080032.initial_effect(c)
	c:SetUniqueOnField(1,0,76080032)
	-- 自己的主要阶段时，手卡的这张卡可以当作攻击力上升1900的装备卡使用给自己场上的「混沌No.39 希望皇 霍普雷」装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76080032,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c76080032.eqcon)
	e1:SetTarget(c76080032.eqtg)
	e1:SetOperation(c76080032.eqop)
	c:RegisterEffect(e1)
	-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetRange(LOCATION_SZONE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCondition(c76080032.discon)
	e3:SetOperation(c76080032.disop)
	c:RegisterEffect(e3)
	-- 装备怪兽和对方怪兽进行战斗的场合，只在战斗阶段内那只对方怪兽的效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetCondition(c76080032.discon)
	e4:SetTarget(c76080032.distg)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e5)
end
-- 检查自己场上是否已存在同名卡（满足“「异热同心武器-独角兽皇枪」在自己场上只能有1张表侧表示存在”的限制）
function c76080032.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
end
-- 过滤自己场上表侧表示的「混沌No.39 希望皇 霍普雷」
function c76080032.filter(c)
	return c:IsFaceup() and c:IsCode(56840427)
end
-- 装备效果的靶向判定与目标选择
function c76080032.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c76080032.filter(chkc) end
	-- 判定自己魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判定自己场上是否存在可以装备的「混沌No.39 希望皇 霍普雷」
		and Duel.IsExistingTarget(c76080032.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「混沌No.39 希望皇 霍普雷」作为效果对象
	Duel.SelectTarget(tp,c76080032.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 装备效果的执行处理
function c76080032.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取选择的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、目标怪兽是否仍在自己场上表侧表示、是否仍与效果相关，以及自身是否满足场上唯一存在的限制
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 若不满足装备条件，则将这张卡送去墓地
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	c76080032.zw_equip_monster(c,tp,tc)
end
-- 执行装备操作，并注册装备卡限制与攻击力上升效果
function c76080032.zw_equip_monster(c,tp,tc)
	-- 将这张卡作为装备卡装备给目标怪兽，若装备失败则返回
	if not Duel.Equip(tp,c,tc) then return end
	-- 当作...装备卡使用...装备
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c76080032.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 当作攻击力上升1900的装备卡使用
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1900)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 判定是否处于战斗阶段，且装备怪兽正在与对方怪兽进行战斗
function c76080032.discon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	-- 判定装备怪兽是否是攻击怪兽或被攻击怪兽，且存在战斗对象
	return ec and (ec==Duel.GetAttacker() or ec==Duel.GetAttackTarget()) and ec:GetBattleTarget()
		-- 判定当前是否处于战斗阶段（从战斗阶段开始到战斗阶段结束）
		and Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE
end
-- 战斗对象确定时，立即刷新场上卡片的状态以应用无效化效果
function c76080032.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 立即手动刷新该卡影响的卡片的无效状态
	Duel.AdjustInstantly(e:GetHandler())
end
-- 确定需要无效化效果的对方怪兽（即装备怪兽的战斗对象）
function c76080032.distg(e,c)
	local ec=e:GetHandler():GetEquipTarget()
	return ec and c==ec:GetBattleTarget()
end
-- 限制这张卡只能装备给作为效果对象的怪兽
function c76080032.eqlimit(e,c)
	return c==e:GetLabelObject()
end
