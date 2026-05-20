--竜殺しの剣
-- 效果：
-- 战士族怪兽才能装备。
-- ①：装备怪兽的攻击力上升700。
-- ②：装备怪兽和龙族怪兽进行战斗的伤害计算后发动。和装备怪兽进行战斗的那只怪兽在那次战斗阶段结束时破坏。
function c61405855.initial_effect(c)
	-- 战士族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c61405855.target)
	e1:SetOperation(c61405855.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升700。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(700)
	c:RegisterEffect(e2)
	-- 战士族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c61405855.eqlimit)
	c:RegisterEffect(e3)
	-- ②：装备怪兽和龙族怪兽进行战斗的伤害计算后发动。和装备怪兽进行战斗的那只怪兽在那次战斗阶段结束时破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(61405855,0))  --"破坏"
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c61405855.descon)
	e4:SetTarget(c61405855.destg)
	e4:SetOperation(c61405855.desop)
	c:RegisterEffect(e4)
end
-- 装备限制：只能装备给战士族怪兽
function c61405855.eqlimit(e,c)
	return c:IsRace(RACE_WARRIOR)
end
-- 过滤场上表侧表示的战士族怪兽
function c61405855.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_WARRIOR)
end
-- 装备魔法卡发动时的对象选择与效果处理
function c61405855.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c61405855.filter(chkc) end
	-- 检查场上是否存在可以作为装备对象的表侧表示战士族怪兽
	if chk==0 then return Duel.IsExistingTarget(c61405855.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示的战士族怪兽作为装备对象
	Duel.SelectTarget(tp,c61405855.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动成功后的效果处理
function c61405855.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 检查装备怪兽是否与龙族怪兽进行了战斗
function c61405855.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler():GetEquipTarget()
	local bc=c:GetBattleTarget()
	return bc and bc:IsRace(RACE_DRAGON)
end
-- 伤害计算后发动，将与装备怪兽进行战斗的龙族怪兽设为效果处理对象
function c61405855.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local bc=e:GetHandler():GetEquipTarget():GetBattleTarget()
	-- 将进行战斗的对方怪兽设为当前连锁的对象
	Duel.SetTargetCard(bc)
end
-- 伤害计算后的效果处理：给战斗过的怪兽添加标记，并注册一个在战斗阶段结束时将其破坏的延迟效果
function c61405855.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的那只怪兽
	local bc=Duel.GetFirstTarget()
	if bc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		bc:RegisterFlagEffect(61405855,RESET_PHASE+PHASE_BATTLE+RESET_EVENT+RESETS_STANDARD,0,1,fid)
		-- 和装备怪兽进行战斗的那只怪兽在那次战斗阶段结束时破坏。
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(61405855,1))
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e1:SetCountLimit(1)
		e1:SetLabel(fid)
		e1:SetLabelObject(bc)
		e1:SetCondition(c61405855.descon2)
		e1:SetOperation(c61405855.desop2)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE)
		-- 注册在战斗阶段结束时触发的全局时点效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 检查目标怪兽是否仍带有对应的标记以确定是否执行破坏
function c61405855.descon2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	return tc:GetFlagEffectLabel(61405855)==e:GetLabel()
end
-- 战斗阶段结束时的破坏处理
function c61405855.desop2(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 提示发动卡片“杀龙剑”的效果
	Duel.Hint(HINT_CARD,0,61405855)
	-- 因效果将目标怪兽破坏
	Duel.Destroy(tc,REASON_EFFECT)
end
