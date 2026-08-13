--ミレニアム・アイズ・サクリファイス
-- 效果：
-- 「纳祭之魔」＋效果怪兽
-- ①：1回合1次，对方怪兽的效果发动时，以对方的场上·墓地1只效果怪兽为对象才能发动。那只对方的效果怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
function c41578483.initial_effect(c)
	c:EnableReviveLimit()
	-- 为「千年眼纳祭神」添加融合召唤手续：融合素材为1只卡号64631466的「纳祭之魔」和1只效果怪兽（TYPE_EFFECT）。
	aux.AddFusionProcCodeFun(c,64631466,aux.FilterBoolFunction(Card.IsFusionType,TYPE_EFFECT),1,true,true)
	-- ①：1回合1次，对方怪兽的效果发动时，以对方的场上·墓地1只效果怪兽为对象才能发动。那只对方的效果怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41578483,0))
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1)
	e1:SetCondition(c41578483.eqcon)
	e1:SetTarget(c41578483.eqtg)
	e1:SetOperation(c41578483.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的各自数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c41578483.atkval)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	e3:SetValue(c41578483.defval)
	c:RegisterEffect(e3)
	-- 那个效果无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c41578483.distg)
	c:RegisterEffect(e4)
	-- 那个效果无效化。
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetCode(EVENT_CHAIN_SOLVING)
	e6:SetRange(LOCATION_MZONE)
	e6:SetCondition(c41578483.discon)
	e6:SetOperation(c41578483.disop)
	c:RegisterEffect(e6)
	-- ③：原本卡名和这张卡的效果装备的怪兽相同的怪兽不能攻击，那个效果无效化。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetRange(LOCATION_MZONE)
	e5:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e5:SetTarget(c41578483.atktg)
	c:RegisterEffect(e5)
end
-- 定义一个始终返回 true 的辅助函数，表示不限制可装备的怪兽（该函数在本段脚本中未被实际调用）。
function c41578483.can_equip_monster(c)
	return true
end
-- 效果发动条件：对方发动怪兽效果（ep≠tp 且 re 为怪兽效果）时，本效果可以发动。
function c41578483.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and re:IsActiveType(TYPE_MONSTER)
end
-- 对象筛选条件：选择对方场上表侧表示或墓地中的效果怪兽，且该怪兽控制权可以被转移（能够被装备）。
function c41578483.eqfilter(c)
	return (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_EFFECT) and c:IsAbleToChangeControler()
end
-- 目标选择处理：chkc时检查所选卡是否为对方场上/墓地且满足条件的表侧或墓地效果怪兽；chk==0时检查己方魔陷区有空位且存在合法对象。
function c41578483.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE+LOCATION_GRAVE) and chkc:IsControler(1-tp) and c41578483.eqfilter(chkc) end
	-- 非正式处理时（chk==0）的发动条件之一：确认己方魔陷区有空位，用于放置装备卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且确认对方场上或墓地存在至少1只满足eqfilter条件的效果怪兽可作为对象。
		and Duel.IsExistingTarget(c41578483.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 为玩家弹出选择提示，提示消息类型为『请选择要装备的卡』。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从对方场上/墓地中满足条件的怪兽中选择1只，并设定为当前连锁的处理对象。
	local g=Duel.SelectTarget(tp,c41578483.eqfilter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:GetFirst():IsLocation(LOCATION_GRAVE) then
		-- 若选择的对象位于墓地，则设置操作信息 CATEGORY_LEAVE_GRAVE，使该卡离开墓地的动向能被正确检测。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 装备限制函数：被装备的怪兽只能装备给该效果的拥有者（即「千年眼纳祭神」本人），避免被转装备到其他怪兽。
function c41578483.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 装备处理：将目标怪兽装备给这张卡，成功后给目标怪兽打上标记，并给它注册一个仅能装备给本卡的装备限制效果。
function c41578483.equip_monster(c,tp,tc)
	-- 尝试执行 Duel.Equip 将目标怪兽作为装备卡装备给这张卡；若装备失败则结束处理，不执行后续标记与限制效果的注册。
	if not Duel.Equip(tp,tc,c,false) then return end
	tc:RegisterFlagEffect(41578483,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 那只对方的效果怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
	e1:SetCode(EFFECT_EQUIP_LIMIT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	e1:SetValue(c41578483.eqlimit)
	tc:RegisterEffect(e1)
end
-- 效果处理时取出对象：若对象怪兽仍为表侧表示且与之前发动的效果相关，并且仍是对方控制的效果怪兽，则进行装备。
function c41578483.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁处理的第一个对象（即目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_EFFECT) and tc:IsControler(1-tp) then
		c41578483.equip_monster(c,tp,tc)
	end
end
-- 计算攻击力上升值：遍历装备区中的卡，把带有本效果标记且表侧表示的怪兽的攻击力累加，作为这张卡的攻击力上升量。
function c41578483.atkval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(41578483)~=0 and tc:IsFaceup() and tc:GetAttack()>=0 then
			atk=atk+tc:GetAttack()
		end
		tc=g:GetNext()
	end
	return atk
end
-- 计算守备力上升值：遍历装备区中的卡，把带有本效果标记且表侧表示的怪兽的守备力累加，作为这张卡的守备力上升量。
function c41578483.defval(e,c)
	local atk=0
	local g=c:GetEquipGroup()
	local tc=g:GetFirst()
	while tc do
		if tc:GetFlagEffect(41578483)~=0 and tc:IsFaceup() and tc:GetDefense()>=0 then
			atk=atk+tc:GetDefense()
		end
		tc=g:GetNext()
	end
	return atk
end
-- 过滤条件：这张卡的装备区中，带有41578483标记且表侧表示的怪兽（即由本效果装备的怪兽）。
function c41578483.disfilter(c)
	return c:IsFaceup() and c:GetFlagEffect(41578483)~=0
end
-- 无效化对象判定：场上表侧表示的效果怪兽（原本种类也含效果）中，原本卡名与装备区中由本效果装备的怪兽相同的怪兽会被无效。
function c41578483.distg(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	return (c:IsType(TYPE_EFFECT) or c:GetOriginalType()&TYPE_EFFECT~=0) and g:IsExists(Card.IsOriginalCodeRule,1,nil,c:GetOriginalCodeRule())
end
-- 连锁无效的发动条件：当前发动的效果是怪兽效果，且发动者怪兽的原本卡名与本卡装备区中由本效果装备的怪兽相同。
function c41578483.discon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and g:IsExists(Card.IsOriginalCodeRule,1,nil,rc:GetOriginalCodeRule())
end
-- 连锁无效的处理：将那次怪兽效果发动通过 Duel.NegateEffect 无效。
function c41578483.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 使编号为ev的连锁的效果无效。
	Duel.NegateEffect(ev)
end
-- 不能攻击的对象判定：若场上怪兽的卡名与装备区中由本效果装备的怪兽的卡名相同，则该怪兽不能攻击。
function c41578483.atktg(e,c)
	local g=e:GetHandler():GetEquipGroup():Filter(c41578483.disfilter,nil)
	return g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
