--ワンショット・ワンド
-- 效果：
-- 魔法师族怪兽才能装备。装备怪兽的攻击力上升800。此外，装备怪兽进行战斗的伤害计算后，可以把这张卡破坏并从卡组抽1张卡。
function c36042825.initial_effect(c)
	-- 魔法师族怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c36042825.target)
	e1:SetOperation(c36042825.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升800。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(800)
	c:RegisterEffect(e2)
	-- 魔法师族怪兽才能装备。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetValue(c36042825.eqlimit)
	c:RegisterEffect(e3)
	-- 此外，装备怪兽进行战斗的伤害计算后，可以把这张卡破坏并从卡组抽1张卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(36042825,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLED)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c36042825.drcon)
	e4:SetTarget(c36042825.drtg)
	e4:SetOperation(c36042825.drop)
	c:RegisterEffect(e4)
end
-- 定义装备限制条件，判断对象是否为魔法师族怪兽。
function c36042825.eqlimit(e,c)
	return c:IsRace(RACE_SPELLCASTER)
end
-- 定义过滤器，检查卡片是否为表侧表示的魔法师族怪兽。
function c36042825.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 装备魔法卡发动时的目标选择处理，检查场上是否存在魔法师族怪兽并选择作为对象。
function c36042825.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c36042825.filter(chkc) end
	-- 检查场上是否存在可以装备这张卡的魔法师族怪兽（发动条件判断）。
	if chk==0 then return Duel.IsExistingTarget(c36042825.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择装备对象的消息提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 玩家选择场上的一只魔法师族怪兽作为装备对象。
	Duel.SelectTarget(tp,c36042825.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理类型为装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备魔法卡发动时的实际处理，将这张卡装备给选择的怪兽。
function c36042825.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给对象怪兽。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 诱发效果的条件判断，检查装备怪兽是否进行了战斗。
function c36042825.drcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetEquipTarget():IsRelateToBattle()
end
-- 诱发效果的目标选择处理，设置破坏这张卡和抽卡的效果分类。
function c36042825.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽卡（诱发效果的发动条件）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	-- 设置效果处理类型包含破坏这张卡。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 设置效果处理类型包含抽卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 诱发效果的实际处理，破坏这张卡并让玩家抽卡。
function c36042825.drop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否还在场上并将其破坏，作为抽卡的前提条件。
	if c:IsRelateToEffect(e) and Duel.Destroy(c,REASON_EFFECT)>0 then
		-- 玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
