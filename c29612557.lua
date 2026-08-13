--サイクロン・ブーメラン
-- 效果：
-- 「元素英雄 荒野侠」才能装备。装备怪兽攻击力上升500。装备怪兽被其他卡的效果破坏送去墓地时，场上的魔法·陷阱卡全部破坏。给与对方基本分破坏的魔法·陷阱卡数量×100的伤害。
function c29612557.initial_effect(c)
	-- 将『元素英雄』系列字段（0x3008）注册到本卡，供系列相关判定使用。
	aux.AddSetNameMonsterList(c,0x3008)
	-- 「元素英雄 荒野侠」才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c29612557.target)
	e1:SetOperation(c29612557.operation)
	c:RegisterEffect(e1)
	-- 「元素英雄 荒野侠」才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c29612557.eqlimit)
	c:RegisterEffect(e2)
	-- 装备怪兽攻击力上升500。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(500)
	c:RegisterEffect(e3)
	-- 装备怪兽被其他卡的效果破坏送去墓地时，场上的魔法·陷阱卡全部破坏。给与对方基本分破坏的魔法·陷阱卡数量×100的伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(29612557,0))  --"破坏并伤害"
	e4:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_LEAVE_FIELD)
	e4:SetCondition(c29612557.descon)
	e4:SetTarget(c29612557.destg)
	e4:SetOperation(c29612557.desop)
	c:RegisterEffect(e4)
end
-- 定义装备限制条件：只有卡号为86188410的「元素英雄 荒野侠」才能成为这张卡的装备对象。
function c29612557.eqlimit(e,c)
	return c:IsCode(86188410)
end
-- 定义选择过滤条件：选择表侧表示且卡号为86188410的「元素英雄 荒野侠」作为装备对象。
function c29612557.filter(c)
	return c:IsFaceup() and c:IsCode(86188410)
end
-- 装备魔法发动时的目标处理：检查存在符合条件的荒野侠，提示玩家选择1只荒野侠，并将其登记为效果对象，同时设置装备类别的操作信息。
function c29612557.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c29612557.filter(chkc) end
	-- 发动合法性检查：若不存在表侧表示的「元素英雄 荒野侠」，则效果不能发动。
	if chk==0 then return Duel.IsExistingTarget(c29612557.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 给发动玩家显示选择提示，要求选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从双方场上选择1张表侧表示的「元素英雄 荒野侠」作为装备对象并登记。
	Duel.SelectTarget(tp,c29612557.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：将这张卡装备给对象（类别为装备）。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：取得装备对象，若本卡仍与效果关联、对象仍合法且表侧表示，则将本卡装备到该荒野侠上。
function c29612557.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将旋风回力镖作为装备魔法卡装备到对象怪兽身上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- 判定触发条件：这张装备卡因失去装备对象而离场，且原装备对象是被其他卡的效果破坏并送入墓地。
function c29612557.descon(e,tp,eg,ep,ev,re,r,rp)
	local ec=e:GetHandler():GetPreviousEquipTarget()
	return e:GetHandler():IsReason(REASON_LOST_TARGET) and ec:IsLocation(LOCATION_GRAVE)
		and bit.band(ec:GetReason(),0x41)==0x41
end
-- 定义魔法·陷阱卡筛选条件：卡类型为魔法卡或陷阱卡。
function c29612557.dfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 诱发效果的发动时处理：无条件可发动；获取场上所有魔法·陷阱卡，并登记破坏所有魔陷及给对方造成对应数量×100伤害的操作信息。
function c29612557.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 获取场上（双方）所有魔法·陷阱卡的集合。
	local g=Duel.GetMatchingGroup(c29612557.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置操作信息：破坏上述全部魔法·陷阱卡，数量为其张数。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,g:GetCount(),0,0)
	-- 设置操作信息：给对方造成魔陷数量×100的效果伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:GetCount()*100)
end
-- 效果处理：重新获取场上所有魔法·陷阱卡，将其全部破坏，并按实际破坏数量给对方造成伤害。
function c29612557.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有魔法·陷阱卡的集合。
	local g=Duel.GetMatchingGroup(c29612557.dfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将获取到的魔法·陷阱卡全部破坏，返回实际破坏数量。
	local ct=Duel.Destroy(g,REASON_EFFECT)
	-- 给对方玩家造成实际破坏数量×100的效果伤害。
	Duel.Damage(1-tp,ct*100,REASON_EFFECT)
end
