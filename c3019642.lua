--サイバー・ダーク・キール
-- 效果：
-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡的效果装备的怪兽的攻击力数值。
-- ③：这张卡战斗破坏对方怪兽的场合发动。给与对方300伤害。
-- ④：这张卡被战斗破坏的场合，作为代替把这张卡的效果装备的怪兽破坏。
function c3019642.initial_effect(c)
	-- ①：这张卡召唤成功的场合，以自己墓地1只3星以下的龙族怪兽为对象发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3019642,0))  --"装备"
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c3019642.eqtg)
	e1:SetOperation(c3019642.eqop)
	c:RegisterEffect(e1)
	-- ③：这张卡战斗破坏对方怪兽的场合发动。给与对方300伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3019642,1))  --"伤害"
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 检测本次战斗是否为该卡与对方怪兽的战斗
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c3019642.damtg)
	e2:SetOperation(c3019642.damop)
	c:RegisterEffect(e2)
end
-- 筛选满足条件的墓地龙族怪兽（3星以下且未被禁止）
function c3019642.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 设置装备卡选择目标，从己方墓地选择一只符合条件的龙族怪兽
function c3019642.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断选择的卡片是否满足墓地、控制者和种族条件
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and (chkc:IsControler(tp) or Duel.IsPlayerAffectedByEffect(tp,64753988)) and c3019642.filter(chkc) end
	if chk==0 then return true end
	-- 根据是否受到64753988效果影响，决定选择目标的区域
	local loc=Duel.IsPlayerAffectedByEffect(tp,64753988) and LOCATION_GRAVE or 0
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一只符合条件的墓地龙族怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c3019642.filter,tp,LOCATION_GRAVE,loc,1,1,nil)
	-- 设置操作信息，标记将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 执行装备操作，将选中的怪兽装备给此卡并注册相关效果
function c3019642.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标卡
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		local atk=tc:GetTextAttack()
		if atk<0 then atk=0 end
		-- 尝试将目标怪兽装备给此卡，失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 装备对象限制效果，确保只有此卡能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c3019642.eqlimit)
		tc:RegisterEffect(e1)
		-- 装备卡攻击力提升效果，提升值为装备怪兽的攻击力
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetProperty(EFFECT_FLAG_OWNER_RELATE+EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetValue(atk)
		tc:RegisterEffect(e2)
		-- 装备卡破坏代替效果，当此卡被战斗破坏时，代替破坏装备怪兽
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_EQUIP)
		e3:SetCode(EFFECT_DESTROY_SUBSTITUTE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		e3:SetValue(c3019642.repval)
		tc:RegisterEffect(e3)
	end
end
-- 装备对象限制函数，确保只有此卡能装备该怪兽
function c3019642.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 破坏代替函数，仅当因战斗破坏时生效
function c3019642.repval(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
-- 设置伤害效果的目标玩家和伤害值
function c3019642.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置伤害效果的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害效果的伤害值为300
	Duel.SetTargetParam(300)
	-- 设置操作信息，标记将要造成伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
end
-- 执行伤害效果，对目标玩家造成300点伤害
function c3019642.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标玩家和伤害值
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对指定玩家造成指定伤害值
	Duel.Damage(p,d,REASON_EFFECT)
end
