--トラップ・ギャザー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽的攻击力上升自己墓地的陷阱卡数量×400。
-- ②：装备怪兽战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时，把这张卡送去墓地才能发动。从自己墓地把1张陷阱卡在自己场上盖放。
-- ③：自己场上的表侧表示的陷阱卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
local s,id,o=GetID()
-- 初始化并注册这张卡的所有效果：发动时作为装备卡装备给对象怪兽（e1）、①攻击力上升（e2）、②两个触发时机的送墓盖放陷阱卡效果（e3/e4）、③代替破坏效果（e5）以及装备对象限制（e6）。
function s.initial_effect(c)
	-- ①：装备怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：装备怪兽的攻击力上升自己墓地的陷阱卡数量×400。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
	-- 这个卡名的②③的效果1回合各能使用1次。②：装备怪兽战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时，把这张卡送去墓地才能发动。从自己墓地把1张陷阱卡在自己场上盖放。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"盖放墓地的陷阱卡"
	e3:SetCategory(CATEGORY_SSET)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLED)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(s.setcon1)
	e3:SetCost(s.setcost)
	e3:SetTarget(s.settg)
	e3:SetOperation(s.setop)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_BATTLE_DAMAGE)
	e4:SetCondition(s.setcon2)
	c:RegisterEffect(e4)
	-- ③：自己场上的表侧表示的陷阱卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_DESTROY_REPLACE)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1,id+o)
	e5:SetTarget(s.desreptg)
	e5:SetValue(s.desrepval)
	e5:SetOperation(s.desrepop)
	c:RegisterEffect(e5)
	-- ①：装备怪兽
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- s.target是这张卡发动时的目标选择函数：检查场上是否存在表侧表示怪兽可作为对象，让玩家选择1只表侧表示怪兽作为装备对象，并将操作信息设置为装备这张卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动合法性检查：确认场上存在至少1只表侧表示怪兽可以作为装备对象，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向操作玩家显示“请选择要装备的卡”的选择提示，用于装备对象选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己或对方场上选择1只表侧表示怪兽，并将其登记为这张卡效果的对象（装备目标）。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置当前连锁的操作信息：本次效果为装备这张卡，操作对象为这张卡自身，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- s.operation是效果处理函数：取得对象怪兽，确认这张卡和对象仍与效果关联且对象表侧表示，若满足则将这张卡装备给对象怪兽。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- s.value定义①的攻击力上升数值：按这张卡控制者墓地的陷阱卡数量×400计算。
function s.value(e,c)
	-- 统计这张卡控制者墓地的陷阱卡数量并乘以400，作为装备怪兽的攻击力上升值。
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,TYPE_TRAP)*400
end
-- s.setcon1是②在“装备怪兽战斗破坏对方怪兽的伤害计算后”时点的触发条件：装备怪兽仍在战斗相关状态，且其战斗对象是被战斗破坏的对方怪兽。
function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	return ec:IsRelateToBattle() and ec:IsControler(tp) and bc~=nil and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- s.setcon2是②在“给与对方战斗伤害时”时点的触发条件：装备怪兽仍在战斗相关状态，并且造成伤害的对象是对方（ep≠tp）。
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsRelateToBattle() and ec:IsControler(tp) and ep~=tp
end
-- s.setcost是②的发动代价判定与处理：确认这张卡可以送去墓地作为代价，然后将其送去墓地。
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 实际将这张卡从场上送去墓地，作为②效果的发动代价。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- s.filter是②盖放目标的过滤器：选择自己墓地中可以盖放（SSetable）的陷阱卡。
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- s.settg是②的效果发动可执行性判定：这张卡仍在魔陷区或者我方魔陷区有空位，并且自己墓地存在可以盖放的陷阱卡。
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查盖放所需的魔陷区空位：若这张卡作为装备卡不在魔陷区，则需要我方魔陷区仍有空位才能盖放。
	if chk==0 then return (e:GetHandler():IsLocation(LOCATION_SZONE) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 检查自己墓地是否存在至少1张满足s.filter的陷阱卡，作为②效果的盖放对象。
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
end
-- s.setop是②效果处理：确认魔陷区有空位后，从自己墓地选择1张可盖放且不受王家长眠之谷影响的陷阱卡，盖放在自己场上。
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若我方魔陷区没有空位，则无法盖放，终止效果处理。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 向操作玩家显示“请选择要盖放的卡”的选择提示，用于盖放对象选择界面。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从自己墓地选择1张可盖放且不受王家长眠之谷影响的陷阱卡（在s.filter基础上额外通过aux.NecroValleyFilter过滤）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选中的陷阱卡以里侧表示盖放在自己魔陷区。
		Duel.SSet(tp,tc)
	end
end
-- s.repfilter是③代替破坏的判定过滤器：被破坏的卡是自己场上表侧表示的陷阱卡，破坏原因为效果破坏，且不是已经由代替破坏处理过的卡。
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsType(TYPE_TRAP)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsFaceup()
end
-- s.desreptg是③的发动条件：当前存在满足repfilter的即将被效果破坏的陷阱卡，且这张卡可以除外并且尚未被破坏确认或战斗破坏确认。
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问玩家是否发动③的代替破坏效果（选择“是”则代替破坏）。
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- s.desrepval用于代替破坏效果的计算：对将被破坏的卡，若满足s.repfilter，则返回true，表示可以由这张卡代替破坏。
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- s.desrepop是③效果处理：展示这张卡的发动动画后，将这张卡除外，代替那些将被破坏的陷阱卡被破坏。
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示这张卡的卡图，作为效果处理时的发动提示。
	Duel.Hint(HINT_CARD,0,id)
	-- 将这张卡除外，完成代替破坏的处理。
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
