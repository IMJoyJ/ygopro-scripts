--アラヒメの御巫
-- 效果：
-- 「御巫神乐」降临
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡在手卡·墓地存在，自己墓地有其他的「御巫」卡存在的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
-- ②：这张卡装备中的场合，自己·对方的结束阶段才能发动。这张卡和装备怪兽回到手卡。
-- ③：这张卡不会被战斗破坏，这张卡的战斗发生的对自己的战斗伤害由对方代受。
local s,id,o=GetID()
-- 注册卡片效果：e1为手卡·墓地起动的当作装备卡装备效果，e2为不会被战斗破坏，e3为战斗伤害由对方代受，e4为结束阶段将自身与装备怪兽回手卡的效果。
function s.initial_effect(c)
	-- 记录这张卡在卡名中记载了「御巫神乐」。
	aux.AddCodeList(c,16310544)
	c:EnableReviveLimit()
	-- ①：这张卡在手卡·墓地存在，自己墓地有其他的「御巫」卡存在的场合，以场上1只表侧表示怪兽为对象才能发动。这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.eqcon)
	e1:SetTarget(s.eqtg)
	e1:SetOperation(s.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡不会被战斗破坏
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 这张卡的战斗发生的对自己的战斗伤害由对方代受。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_REFLECT_BATTLE_DAMAGE)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：这张卡装备中的场合，自己·对方的结束阶段才能发动。这张卡和装备怪兽回到手卡。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))
	e4:SetCategory(CATEGORY_TOHAND)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTarget(s.thtg)
	e4:SetOperation(s.thop)
	c:RegisterEffect(e4)
end
-- 检查场上是否能唯一存在该卡，且自己墓地是否存在除自身以外的其他「御巫」卡。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():CheckUniqueOnField(tp)
		-- 检查自己墓地是否存在除自身以外的其他「御巫」卡。
		and Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_GRAVE,0,1,e:GetHandler(),0x18d)
end
-- 效果①的靶向处理：检查魔陷区是否有空位，以及场上是否存在表侧表示怪兽作为对象。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 检查自己魔陷区是否有可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查场上是否存在可以作为对象的表侧表示怪兽。
		and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若此卡在墓地发动，则设置此卡离开墓地的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- 效果①的执行：将自身作为装备卡装备给目标怪兽，并添加装备限制。若无法装备，则送去墓地。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 获取效果①选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 检查魔陷区是否有空位、对象怪兽是否仍表侧表示存在、是否仍与效果相关联，以及自身是否能唯一存在于场上。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsFacedown() or not tc:IsRelateToEffect(e) or not c:CheckUniqueOnField(tp) then
		-- 将自身送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将自身作为装备卡装备给目标怪兽，若装备失败则结束。
	if not Duel.Equip(tp,c,tc) then return end
	-- 这张卡当作装备魔法卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(s.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 装备限制：只能装备给作为效果对象的怪兽。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果②的靶向处理：检查装备怪兽和自身是否能回到手卡，并设置回手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if chk==0 then return ec and ec:IsAbleToHand() and c:IsAbleToHand() end
	ec:CreateEffectRelation(e)
	local g=Group.FromCards(ec,c)
	-- 设置将自身和装备怪兽回到手卡的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,2,0,0)
end
-- 效果②的执行：将自身和装备怪兽回到持有者手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if not c:IsRelateToEffect(e) or not ec:IsRelateToEffect(e) then return end
	local g=Group.FromCards(c,ec)
	-- 将自身和装备怪兽送回持有者的手卡。
	Duel.SendtoHand(g,nil,REASON_EFFECT)
end
