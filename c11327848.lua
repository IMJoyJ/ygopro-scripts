--修士号ディプロマン
-- 效果：
-- ①：这张卡上级召唤成功的场合，以自己墓地1只怪兽和对方场上1只表侧表示怪兽为对象才能发动。那只墓地的怪兽当作装备卡使用给那只对方怪兽装备。只要这个效果把怪兽装备中，装备怪兽的攻击力下降那个攻击力数值。
-- ②：只要这张卡在怪兽区域存在，有自己的魔法与陷阱区域的装备卡装备的对方怪兽的效果不能发动。
function c11327848.initial_effect(c)
	-- ①：这张卡上级召唤成功的场合，以自己墓地1只怪兽和对方场上1只表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(11327848,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c11327848.eqcon)
	e1:SetTarget(c11327848.eqtg)
	e1:SetOperation(c11327848.eqop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，有自己的魔法与陷阱区域的装备卡装备的对方怪兽的效果不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ACTIVATE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,1)
	e2:SetValue(c11327848.aclimit)
	c:RegisterEffect(e2)
end
-- 判断此卡是否为上级召唤成功
function c11327848.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end
-- 过滤墓地中的怪兽
function c11327848.eqfilter(c)
	return c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 过滤对方场上的表侧表示怪兽
function c11327848.tgfilter(c)
	return c:IsFaceup()
end
-- 设置效果发动时的选择目标
function c11327848.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 判断是否满足选择目标的条件：自己墓地存在1只怪兽
	if chk==0 then return Duel.IsExistingTarget(c11327848.eqfilter,tp,LOCATION_GRAVE,0,1,nil)
		-- 判断是否满足选择目标的条件：对方场上存在1只表侧表示怪兽
		and Duel.IsExistingTarget(c11327848.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 从自己墓地选择1只怪兽作为装备对象
	local g1=Duel.SelectTarget(tp,c11327848.eqfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	-- 从对方场上选择1只表侧表示怪兽作为装备对象
	local g2=Duel.SelectTarget(tp,c11327848.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，标明将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g1,1,0,0)
end
-- 设置效果发动后的处理操作
function c11327848.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取连锁中选定的目标卡组，并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	local tc1=g:Filter(Card.IsControler,nil,tp):GetFirst()
	local tc2=g:Filter(Card.IsControler,nil,1-tp):GetFirst()
	if tc1 and tc2 and tc2:IsFaceup() then
		local atk=tc1:GetAttack()
		-- 尝试将选中的卡装备给对方怪兽，若失败则返回
		if not Duel.Equip(tp,tc1,tc2,false) then return end
		-- 装备对象限制效果，确保只能装备给指定的对方怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetLabelObject(tc2)
		e1:SetValue(c11327848.eqlimit)
		tc1:RegisterEffect(e1)
		-- 装备怪兽的攻击力下降其自身攻击力数值的效果
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(-atk)
		tc1:RegisterEffect(e2)
	end
end
-- 装备对象限制函数，确保只能装备给指定的对方怪兽
function c11327848.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 限制对方怪兽效果发动的函数，当对方怪兽有装备卡时不能发动
function c11327848.aclimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER) and re:GetHandler():GetEquipGroup():IsExists(Card.IsControler,1,nil,e:GetHandlerPlayer())
end
