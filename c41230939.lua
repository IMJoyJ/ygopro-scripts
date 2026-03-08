--サイバー・ダーク・ホーン
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c41230939.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(41230939,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c41230939.eqtg)
	e1:SetOperation(c41230939.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的墓地龙族怪兽（3星以下且未被禁止）
function c41230939.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 选择并设置目标：从自己墓地选择1只3星以下的龙族怪兽作为装备对象
function c41230939.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标是否满足装备条件：位于墓地且为龙族且未被禁止
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c41230939.filter(chkc) end
	if chk==0 then return true end
	-- 根据是否受到64753988效果影响，确定选择目标的区域
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从指定区域选择1只符合条件的怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c41230939.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置操作信息：将装备的怪兽从墓地离开
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备处理函数：将选中的怪兽装备给此卡并设置相关效果
function c41230939.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将目标怪兽装备给此卡，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备限制效果：只有此卡能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c41230939.eqlimit)
		tc:RegisterEffect(e1)
		-- 设置攻击力提升效果：此卡攻击力上升装备怪兽的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- 设置代替破坏效果：此卡被战斗破坏时，用装备怪兽代替破坏
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c41230939.repval)
		tc:RegisterEffect(e3)
	end
end
-- 装备限制判断函数：只有此卡能装备该怪兽
function c41230939.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 代替破坏判断函数：仅当因战斗破坏时才生效
function c41230939.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
