--ダブルツールD＆C
-- 效果：
-- 自己场上的「动力工具龙」或者4星以上的机械族「变形斗士」怪兽才能装备。
-- ①：每回合让以下效果适用。
-- ●自己回合：装备怪兽的攻击力上升1000，成为装备怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
-- ●对方回合：对方不能选择装备怪兽以外的怪兽作为攻击对象。
-- ②：对方回合，装备怪兽和对方怪兽进行战斗的伤害步骤结束时发动。那只对方怪兽破坏。
function c63730624.initial_effect(c)
	-- 自己场上的「动力工具龙」或者4星以上的机械族「变形斗士」怪兽才能装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c63730624.target)
	e1:SetOperation(c63730624.operation)
	c:RegisterEffect(e1)
	-- 自己场上的「动力工具龙」或者4星以上的机械族「变形斗士」怪兽才能装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(c63730624.eqlimit)
	c:RegisterEffect(e2)
	-- ●自己回合：装备怪兽的攻击力上升1000
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetCondition(c63730624.scon1)
	e3:SetValue(1000)
	c:RegisterEffect(e3)
	-- 成为装备怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCode(EVENT_BE_BATTLE_TARGET)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCondition(c63730624.scon2)
	e4:SetOperation(c63730624.sop2)
	c:RegisterEffect(e4)
	-- 成为装备怪兽的攻击对象的怪兽的效果只在那次战斗阶段内无效化。
	local e7=Effect.CreateEffect(c)
	e7:SetType(EFFECT_TYPE_FIELD)
	e7:SetCode(EFFECT_DISABLE)
	e7:SetRange(LOCATION_SZONE)
	e7:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e7:SetTarget(c63730624.distg)
	c:RegisterEffect(e7)
	local e8=e7:Clone()
	e8:SetCode(EFFECT_DISABLE_EFFECT)
	c:RegisterEffect(e8)
	-- ●对方回合：对方不能选择装备怪兽以外的怪兽作为攻击对象。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(c63730624.ocon1)
	e5:SetValue(c63730624.atlimit)
	c:RegisterEffect(e5)
	-- ②：对方回合，装备怪兽和对方怪兽进行战斗的伤害步骤结束时发动。那只对方怪兽破坏。
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_DESTROY)
	e6:SetDescription(aux.Stringid(63730624,0))  --"破坏"
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetRange(LOCATION_SZONE)
	e6:SetCondition(c63730624.ocon2)
	e6:SetTarget(c63730624.otg2)
	e6:SetOperation(c63730624.oop2)
	c:RegisterEffect(e6)
end
-- 装备限制：只能装备给控制者场上的「动力工具龙」或4星以上的机械族「变形斗士」怪兽
function c63730624.eqlimit(e,c)
	return c:GetControler()==e:GetHandler():GetControler()
		and (c:IsCode(2403771) or (c:IsSetCard(0x26) and c:IsLevelAbove(4) and c:IsRace(RACE_MACHINE)))
end
-- 过滤条件：自己场上表侧表示的「动力工具龙」或4星以上的机械族「变形斗士」怪兽
function c63730624.filter(c,tp)
	return c:IsControler(tp) and c:IsFaceup()
		and (c:IsCode(2403771) or (c:IsSetCard(0x26) and c:IsLevelAbove(4) and c:IsRace(RACE_MACHINE)))
end
-- 效果发动时的目标选择与处理
function c63730624.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c63730624.filter(chkc,tp) end
	-- 检查场上是否存在可以装备的合法目标
	if chk==0 then return Duel.IsExistingTarget(c63730624.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择并锁定1只符合条件的怪兽作为装备对象
	Duel.SelectTarget(tp,c63730624.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理信息为装备此卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：将此卡装备给选择的怪兽
function c63730624.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取发动时选择的装备对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsControler(tp) and tc:IsFaceup() then
		-- 将此卡作为装备卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 攻击力上升效果的适用条件：当前是自己回合
function c63730624.scon1(e)
	-- 判断当前回合玩家是否为装备卡的控制者
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
-- 给攻击对象添加标记的条件：自己回合且装备怪兽进行攻击
function c63730624.scon2(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合，且攻击怪兽是装备怪兽
	return Duel.GetTurnPlayer()==tp and Duel.GetAttacker()==e:GetHandler():GetEquipTarget()
end
-- 给攻击对象添加标记的效果处理：在攻击对象上注册一个只在战斗阶段内有效的Flag
function c63730624.sop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被攻击的怪兽（攻击对象）
	local d=Duel.GetAttackTarget()
	d:RegisterFlagEffect(63730624,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,1)
end
-- 无效化效果的目标过滤：带有该Flag的怪兽
function c63730624.distg(e,c)
	return c:GetFlagEffect(63730624)~=0
end
-- 攻击限制效果的适用条件：存在装备怪兽且当前是对方回合
function c63730624.ocon1(e)
	-- 判断是否存在装备怪兽，且当前回合玩家不是装备卡的控制者
	return e:GetHandler():GetEquipTarget() and Duel.GetTurnPlayer()~=e:GetHandler():GetControler()
end
-- 攻击限制效果的目标过滤：不能选择装备怪兽以外的怪兽
function c63730624.atlimit(e,c)
	return c~=e:GetHandler():GetEquipTarget()
end
-- 伤害步骤结束时破坏对方怪兽效果的发动条件：对方回合，装备怪兽与对方怪兽进行战斗
function c63730624.ocon2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的怪兽（对方怪兽）
	local a=Duel.GetAttacker()
	-- 获取被攻击的怪兽（装备怪兽）
	local d=Duel.GetAttackTarget()
	local tc=e:GetHandler():GetEquipTarget()
	-- 判断是否存在装备怪兽、当前为对方回合、装备怪兽是被攻击对象，且对方怪兽仍处于战斗关系中
	return tc and Duel.GetTurnPlayer()~=tp and d==tc and a:IsRelateToBattle()
end
-- 破坏效果的发动准备：设置破坏操作信息
function c63730624.otg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果处理信息为破坏进行攻击的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,Duel.GetAttacker(),1,0,0)
end
-- 破坏效果的实际处理：破坏进行攻击的对方怪兽
function c63730624.oop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行攻击的对方怪兽
	local a=Duel.GetAttacker()
	if a:IsRelateToBattle() then
		-- 因效果破坏该对方怪兽
		Duel.Destroy(a,REASON_EFFECT)
	end
end
