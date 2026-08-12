--フェニックス・ギア・ブレード
-- 效果：
-- 战士族怪兽或炎属性怪兽才能装备。这个卡名的③的效果1回合只能使用1次。
-- ①：装备怪兽的攻击力上升300。
-- ②：装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。这次战斗阶段中，自己的战士族怪兽以及炎属性怪兽各可以作2次攻击。
-- ③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果，创建多个效果并注册到卡片上
function s.initial_effect(c)
	-- ①：装备怪兽的攻击力上升300。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- 战士族怪兽或炎属性怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(s.eqlim)
	c:RegisterEffect(e2)
	-- ①：装备怪兽的攻击力上升300。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(300)
	c:RegisterEffect(e3)
	-- ②：装备怪兽攻击的伤害步骤结束时，把这张卡送去墓地才能发动。这次战斗阶段中，自己的战士族怪兽以及炎属性怪兽各可以作2次攻击。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,0))
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_DAMAGE_STEP_END)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.dacon)
	e4:SetCost(s.dacost)
	e4:SetOperation(s.daop)
	c:RegisterEffect(e4)
	-- ③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_TOHAND)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e5:SetCode(EVENT_TO_GRAVE)
	e5:SetCountLimit(1,id)
	e5:SetProperty(EFFECT_FLAG_DELAY)
	e5:SetCondition(s.thcon)
	e5:SetTarget(s.thtg)
	e5:SetOperation(s.thop)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetCode(EVENT_REMOVE)
	c:RegisterEffect(e6)
end
-- 筛选可装备的怪兽，必须是正面表示且满足装备限制条件
function s.filter(c)
	return c:IsFaceup() and s.eqlim(nil,c)
end
-- 设置装备效果的目标选择逻辑，选择一个正面表示的怪兽作为装备对象
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.filter(chkc) end
	-- 检查是否有符合条件的装备目标
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择一个正面表示的怪兽作为装备对象
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置装备效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将装备卡装备给目标怪兽
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的装备目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 确认装备卡和目标怪兽都有效且正面表示时进行装备
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then Duel.Equip(tp,c,tc) end
end
-- 定义装备限制条件，只能装备给战士族或炎属性怪兽
function s.eqlim(e,c)
	return c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断是否满足发动②效果的条件，即装备怪兽为攻击怪兽且参与战斗
function s.dacon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetHandler():GetEquipTarget()
	-- 装备怪兽为攻击怪兽且参与战斗
	return Duel.GetAttacker()==tc and tc:IsRelateToBattle()
end
-- 设置②效果的发动费用，将装备卡送去墓地
function s.dacost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToGraveAsCost() end
	-- 将装备卡送去墓地作为发动费用
	Duel.SendtoGrave(c,REASON_COST)
end
-- 发动②效果，使己方战士族或炎属性怪兽在本次战斗阶段中可额外攻击一次
function s.daop(e,tp,eg,ep,ev,re,r,rp)
	-- ③：这张卡为让怪兽的效果发动，被送去墓地的场合或者被除外的场合才能发动。这张卡加入手卡。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.datg)
	e1:SetReset(RESET_PHASE+PHASE_BATTLE)
	e1:SetValue(1)
	-- 注册额外攻击效果到玩家场上
	Duel.RegisterEffect(e1,tp)
end
-- 定义额外攻击效果的目标筛选条件，只能是战士族或炎属性怪兽
function s.datg(e,c)
	return c:IsRace(RACE_WARRIOR) or c:IsAttribute(ATTRIBUTE_FIRE)
end
-- 判断③效果是否满足发动条件，即装备卡因效果发动被送去墓地且该效果为怪兽效果
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
end
-- 设置③效果的发动目标，将装备卡加入手牌
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand() end
	-- 设置③效果的操作信息，指定将装备卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
end
-- 执行③效果，将装备卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认装备卡有效时将其加入手牌
	if c:IsRelateToEffect(e) then Duel.SendtoHand(c,nil,REASON_EFFECT) end
end
