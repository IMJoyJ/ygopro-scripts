--トラップ・ギャザー
-- 效果：
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：装备怪兽的攻击力上升自己墓地的陷阱卡数量×400。
-- ②：装备怪兽战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时，把这张卡送去墓地才能发动。从自己墓地把1张陷阱卡在自己场上盖放。
-- ③：自己场上的表侧表示的陷阱卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
local s,id,o=GetID()
-- 初始化陷阱收集的全部效果
function s.initial_effect(c)
	-- ①：装备怪兽的攻击力上升自己墓地的陷阱卡数量×400。
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
	-- ②：装备怪兽战斗破坏对方怪兽的伤害计算后或者给与对方战斗伤害时，把这张卡送去墓地才能发动。从自己墓地把1张陷阱卡在自己场上盖放。
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
	-- ③：自己场上的表侧表示的陷阱卡被效果破坏的场合，可以作为代替把场上的这张卡除外。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_EQUIP_LIMIT)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e6:SetValue(1)
	c:RegisterEffect(e6)
end
-- 设置装备目标选择
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足装备目标选择条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择装备目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择装备目标
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取装备目标
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备动作
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 计算装备怪兽攻击力提升值
function s.value(e,c)
	-- 计算墓地陷阱卡数量并乘以400
	return Duel.GetMatchingGroupCount(Card.IsType,e:GetHandler():GetControler(),LOCATION_GRAVE,0,nil,TYPE_TRAP)*400
end
-- 判断②效果发动条件（战斗破坏对方怪兽）
function s.setcon1(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	local bc=ec:GetBattleTarget()
	return ec:IsRelateToBattle() and ec:IsControler(tp) and bc~=nil and bc:IsStatus(STATUS_BATTLE_DESTROYED)
end
-- 判断②效果发动条件（造成战斗伤害）
function s.setcon2(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetEquipTarget()
	return ec:IsRelateToBattle() and ec:IsControler(tp) and ep~=tp
end
-- 设置②效果发动费用
function s.setcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地作为②效果发动费用
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 定义选择墓地陷阱卡的过滤函数
function s.filter(c)
	return c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- 设置②效果发动时的盖放陷阱卡选择条件
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否满足②效果发动条件（场上是否有空位或自身在场上）
	if chk==0 then return (e:GetHandler():IsLocation(LOCATION_SZONE) or Duel.GetLocationCount(tp,LOCATION_SZONE)>0)
		-- 判断是否满足②效果发动条件（墓地是否有陷阱卡）
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
end
-- 执行②效果的盖放陷阱卡操作
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否还有空位
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 提示玩家选择要盖放的陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择墓地陷阱卡
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.filter),tp,LOCATION_GRAVE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的陷阱卡盖放在场上
		Duel.SSet(tp,tc)
	end
end
-- 定义破坏代替的过滤函数
function s.repfilter(c,tp)
	return c:IsControler(tp) and c:IsOnField() and c:IsType(TYPE_TRAP)
		and c:IsReason(REASON_EFFECT) and not c:IsReason(REASON_REPLACE) and c:IsFaceup()
end
-- 设置③效果发动条件
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,tp)
		and c:IsAbleToRemove() and not c:IsStatus(STATUS_DESTROY_CONFIRMED+STATUS_BATTLE_DESTROYED) end
	-- 询问玩家是否发动③效果
	return Duel.SelectEffectYesNo(tp,c,96)
end
-- 设置③效果的代替值
function s.desrepval(e,c)
	return s.repfilter(c,e:GetHandlerPlayer())
end
-- 执行③效果的除外操作
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示发动③效果的提示动画
	Duel.Hint(HINT_CARD,0,id)
	-- 将自身除外作为③效果的代替
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
end
