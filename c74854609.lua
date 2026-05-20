--ゼクト・コンバージョン
-- 效果：
-- 自己场上的名字带有「甲虫装机」的怪兽被选择作为攻击对象时才能发动。攻击对象怪兽当作装备卡使用给1只攻击怪兽装备。只要因这个效果被名字带有「甲虫装机」的怪兽装备中，自己得到那只装备怪兽的控制权。
function c74854609.initial_effect(c)
	-- 自己场上的名字带有「甲虫装机」的怪兽被选择作为攻击对象时才能发动。攻击对象怪兽当作装备卡使用给1只攻击怪兽装备。只要因这个效果被名字带有「甲虫装机」的怪兽装备中，自己得到那只装备怪兽的控制权。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c74854609.condition)
	e1:SetTarget(c74854609.target)
	e1:SetOperation(c74854609.operation)
	c:RegisterEffect(e1)
end
-- 判断发动条件：对方怪兽攻击自己场上表侧表示的「甲虫装机」怪兽
function c74854609.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	-- 获取本次战斗的被攻击怪兽
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsSetCard(0x56) and a:IsControler(1-tp)
end
-- 判断是否满足发动时的基本条件，并选择攻击怪兽作为效果的对象
function c74854609.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取本次战斗的攻击怪兽
	local a=Duel.GetAttacker()
	if chkc then return a==chkc end
	-- 在发动阶段，检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		and a:IsOnField() and a:IsCanBeEffectTarget(e) end
	-- 将攻击怪兽设为本效果的对象
	Duel.SetTargetCard(a)
end
-- 定义装备限制：该卡只能装备给指定的攻击怪兽
function c74854609.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- 效果处理：将被攻击的怪兽作为装备卡装备给攻击怪兽，并获得该攻击怪兽的控制权
function c74854609.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取被攻击的怪兽（即准备作为装备卡的怪兽）
	local ec=Duel.GetAttackTarget()
	-- 获取作为效果对象的攻击怪兽（即准备被装备的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsAttackable() and not tc:IsStatus(STATUS_ATTACK_CANCELED)
		and ec:IsLocation(LOCATION_MZONE) and ec:IsFaceup() then
		-- 将被攻击的怪兽作为装备卡装备给攻击怪兽，若装备失败则返回
		if not Duel.Equip(tp,ec,tc) then return end
		-- 攻击对象怪兽当作装备卡使用给1只攻击怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c74854609.eqlimit)
		e1:SetLabelObject(tc)
		ec:RegisterEffect(e1)
		-- 只要因这个效果被名字带有「甲虫装机」的怪兽装备中，自己得到那只装备怪兽的控制权。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_SET_CONTROL)
		e2:SetValue(tp)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD-RESET_TURN_SET)
		ec:RegisterEffect(e2)
	end
end
