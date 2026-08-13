--SPYRAL GEAR－ラスト・リゾート
-- 效果：
-- ①：自己主要阶段以自己场上1只「秘旋谍」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
-- ②：1回合1次，这张卡的效果让这张卡装备中的场合，把这张卡以外的自己场上1张卡送去墓地才能发动。这个回合，装备怪兽可以直接攻击。
function c37433748.initial_effect(c)
	-- ①：自己主要阶段以自己场上1只「秘旋谍」怪兽为对象才能发动。从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。装备怪兽不会被战斗·效果破坏，不会成为对方的效果的对象。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(37433748,0))
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e1:SetTarget(c37433748.eqtg)
	e1:SetOperation(c37433748.eqop)
	c:RegisterEffect(e1)
end
-- 检查是否为表侧表示且属于「秘旋谍」字段的怪兽。
function c37433748.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xee)
end
-- ①发动时的对象选择：仅在指定条件下选择自己场上1只表侧表示且为「秘旋谍」字段、且不是这张卡自身的怪兽作为对象。
function c37433748.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c37433748.eqfilter(chkc) and chkc~=e:GetHandler() end
	-- 检查自己魔陷区是否有空位可以放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在满足条件的「秘旋谍」怪兽可以作为对象。
		and Duel.IsExistingTarget(c37433748.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 弹出发动时选择装备对象的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让自己选择1只场上表侧表示的「秘旋谍」怪兽作为效果对象。
	Duel.SelectTarget(tp,c37433748.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
end
-- ①效果处理：将这张卡视为装备卡装备给对象怪兽，并赋予装备怪兽抗性以及②效果。
function c37433748.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	if c:IsLocation(LOCATION_MZONE) and c:IsFacedown() then return end
	-- 获取效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	-- 若魔陷区无空位、对象怪兽已转移控制权或变为里侧或与效果失去关联，则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备处理失败时将这张卡送去墓地。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 把这张卡当作装备卡装备给对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 从自己的手卡·场上把这只怪兽当作装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c37433748.eqlimit)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
	-- 装备怪兽不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetValue(1)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 装备怪兽不会成为对方的效果的对象。
	e4:SetValue(aux.tgoval)
	c:RegisterEffect(e4)
	-- ②：1回合1次，这张卡的效果让这张卡装备中的场合，把这张卡以外的自己场上1张卡送去墓地才能发动。这个回合，装备怪兽可以直接攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(37433748,1))
	e5:SetType(EFFECT_TYPE_IGNITION)
	e5:SetRange(LOCATION_SZONE)
	e5:SetCountLimit(1)
	e5:SetCondition(c37433748.dircon)
	e5:SetCost(c37433748.dircost)
	e5:SetOperation(c37433748.dirop)
	e5:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e5)
end
-- 限制这张装备卡只能装备给发动时选择的那只怪兽。
function c37433748.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ②效果发动条件：当前回合玩家可以进入战斗阶段。
function c37433748.dircon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否能够进入战斗阶段。
	return Duel.IsAbleToEnterBP()
end
-- 作为②效果代价的过滤器：可以送去墓地且不是装备怪兽自身。
function c37433748.cfilter(c,ec)
	return c:IsAbleToGraveAsCost() and c~=ec
end
-- ②效果代价：从自己场上把这张卡以外的一张卡送去墓地才能发动。
function c37433748.dircost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	-- 检查是否存在装备怪兽且自己场上有满足条件的卡可以作为代价。
	if chk==0 then return ec and Duel.IsExistingMatchingCard(c37433748.cfilter,tp,LOCATION_ONFIELD,0,1,c,ec) end
	-- 弹出发动②效果时选择送去墓地卡片的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择自己场上1张满足条件且不是装备怪兽的卡作为代价。
	local g=Duel.SelectMatchingCard(tp,c37433748.cfilter,tp,LOCATION_ONFIELD,0,1,1,c,ec)
	-- 将选择的卡送去墓地作为发动代价。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②效果处理：给装备怪兽赋予本回合可以直接攻击的效果。
function c37433748.dirop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 这个回合，装备怪兽可以直接攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
