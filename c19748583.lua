--聖剣を抱く王妃ギネヴィア
-- 效果：
-- 「怀抱圣剑的王后 桂妮薇儿」的①的效果1回合只能使用1次。
-- ①：以自己场上1只「圣骑士」怪兽为对象才能发动。手卡·墓地的这张卡当作攻击力上升300的装备卡使用给那只自己怪兽装备。
-- ②：得到装备怪兽的属性的以下效果。
-- ●光：装备怪兽被效果破坏的场合，可以作为代替把这张卡破坏。
-- ●暗：装备怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后这张卡破坏。
function c19748583.initial_effect(c)
	-- 「怀抱圣剑的王后 桂妮薇儿」的①的效果1回合只能使用1次。①：以自己场上1只「圣骑士」怪兽为对象才能发动。手卡·墓地的这张卡当作攻击力上升300的装备卡使用给那只自己怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(19748583,0))  --"装备"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetRange(LOCATION_HAND+LOCATION_GRAVE)
	e1:SetCountLimit(1,19748583)
	e1:SetTarget(c19748583.eqtg)
	e1:SetOperation(c19748583.eqop)
	c:RegisterEffect(e1)
	-- ●光：装备怪兽被效果破坏的场合，可以作为代替把这张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetTarget(c19748583.reptg)
	e3:SetOperation(c19748583.repop)
	c:RegisterEffect(e3)
	-- ●暗：装备怪兽和对方怪兽进行战斗的伤害步骤开始时才能发动。那只怪兽破坏。那之后这张卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetCode(EVENT_BATTLE_START)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(c19748583.descon)
	e4:SetTarget(c19748583.destg)
	e4:SetOperation(c19748583.desop)
	c:RegisterEffect(e4)
end
-- 过滤函数：检查怪兽是否为表侧表示且属于「圣骑士」系列（0x107a），用于选取可作为装备对象的自己场上表侧表示「圣骑士」怪兽。
function c19748583.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x107a)
end
-- ①效果的发动条件与取对象设定：验证指定目标是否合法（自己场上表侧表示「圣骑士」怪兽）；在非处理时检查魔陷区是否有空位且存在合法对象，满足则允许发动。
function c19748583.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19748583.filter(chkc) end
	-- 检查自己魔陷区是否有空闲区域，确保手卡/墓地的这张卡能作为装备卡放置到魔陷区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在至少1只表侧表示「圣骑士」怪兽可作为效果对象。
		and Duel.IsExistingTarget(c19748583.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向操作者发送“请选择要装备的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让操作者从自己场上的表侧表示「圣骑士」怪兽中选择1只作为装备对象，并将其登记为当前连锁的对象。
	Duel.SelectTarget(tp,c19748583.filter,tp,LOCATION_MZONE,0,1,1,nil)
	if e:GetHandler():IsLocation(LOCATION_GRAVE) then
		-- 若这张卡在墓地发动，则登记本效果涉及墓地卡的离场信息（CATEGORY_LEAVE_GRAVE），使王家长眠之谷等卡片能够正确响应。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
	end
end
-- ①效果处理：若这张卡仍与效果相关且对象合法，则将此卡作为装备卡装备给对象怪兽，并给它附加“只能装备给「圣骑士」”的限制和攻击力+300的效果；若条件不满足则将此卡送去墓地。
function c19748583.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 取得发动时选择作为装备对象的怪兽。
	local tc=Duel.GetFirstTarget()
	-- 处理时再次确认魔陷区仍有空位、对象仍在自己场上且表侧表示、并且对象仍与本效果相关；任一不满足则装备处理失败。
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 or tc:IsControler(1-tp) or tc:IsFacedown() or not tc:IsRelateToEffect(e) then
		-- 装备条件不满足时，将这张卡从手卡/墓地送去墓地（若已在墓地则仍留墓地）。
		Duel.SendtoGrave(c,REASON_EFFECT)
		return
	end
	-- 将此卡作为装备卡装备给选择的对象怪兽。
	Duel.Equip(tp,c,tc)
	-- 以自己场上1只「圣骑士」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c19748583.eqlimit)
	c:RegisterEffect(e1)
	-- 攻击力上升300的装备卡
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	e2:SetReset(RESET_EVENT+RESETS_STANDARD)
	c:RegisterEffect(e2)
end
-- 装备限制判定：只有「圣骑士」字段的怪兽才能装备这张卡。
function c19748583.eqlimit(e,c)
	return c:IsSetCard(0x107a)
end
-- ②光属性代替破坏的触发条件：装备怪兽将要被效果破坏，且装备怪兽为光属性、这张装备卡本身可被破坏、尚未被确认破坏、且装备怪兽不是被“代替破坏”原因破坏；满足时返回真。
function c19748583.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget()
	if chk==0 then return bit.band(r,REASON_EFFECT)~=0 and tc and tc:IsAttribute(ATTRIBUTE_LIGHT)
		and c:IsDestructable(e) and not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and not tc:IsReason(REASON_REPLACE) end
	-- 询问效果持有者是否发动代替破坏（选择“是”则用这张装备卡的破坏来代替装备怪兽的破坏）。
	return Duel.SelectEffectYesNo(e:GetOwnerPlayer(),c,96)
end
-- 代替破坏处理：在装备怪兽要被效果破坏时，将这张装备卡破坏作为代替。
function c19748583.repop(e,tp,eg,ep,ev,re,r,rp)
	-- 破坏这张装备卡，破坏原因标记为效果破坏和代替破坏（REASON_EFFECT+REASON_REPLACE）。
	Duel.Destroy(e:GetHandler(),REASON_EFFECT+REASON_REPLACE)
end
-- ②暗属性效果的发动条件：这张卡作为装备卡存在，装备怪兽为暗属性，且该怪兽正在进行战斗（是攻击方或攻击对象），在伤害步骤开始时触发。
function c19748583.descon(e,tp,eg,ep,ev,re,r,rp)
	local tg=e:GetHandler():GetEquipTarget()
	-- 具体判定：装备怪兽为暗属性，并且是当前攻击怪兽或攻击目标。
	return tg and tg:IsAttribute(ATTRIBUTE_DARK) and (Duel.GetAttacker()==tg or Duel.GetAttackTarget()==tg)
end
-- ②暗属性效果的目标设定：获取与装备怪兽战斗的对方怪兽，若存在且控制者为对方，则将对方怪兽和这张装备卡登记为将要破坏的卡片，并设置破坏信息。
function c19748583.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tc=c:GetEquipTarget():GetBattleTarget()
	if chk==0 then return tc and tc:IsControler(1-tp) end
	local g=Group.FromCards(tc,c)
	-- 设置操作信息：本次效果将破坏对方怪兽和这张装备卡，共2张，供相关卡片的效果发动条件检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
end
-- ②暗属性效果处理：若这张卡仍与效果相关，则取得战斗对象怪兽；若该怪兽仍与战斗相关，先将其破坏，破坏成功后再把这张装备卡破坏。
function c19748583.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	local tc=c:GetEquipTarget():GetBattleTarget()
	-- 判断战斗对象怪兽是否仍与本次战斗相关（仍在场上且是战斗对象）；若满足，则将其破坏，并确认破坏成功。
	if tc:IsRelateToBattle() and Duel.Destroy(tc,REASON_EFFECT)~=0 then
		-- 中断当前效果处理链，使后续的“这张卡破坏”作为独立的效果处理执行，保证“那只怪兽破坏。那之后这张卡破坏。”的先后顺序。
		Duel.BreakEffect()
		-- 将这张装备卡破坏（那之后的效果）。
		Duel.Destroy(c,REASON_EFFECT)
	end
end
