--フェザー・ショット
-- 效果：
-- 选择自己场上表侧表示存在的1只「元素英雄 羽翼侠」发动。这个回合，选择的卡可以进行和自己场上的怪兽同样数目的攻击。那个场合，不能直接攻击对方玩家，其它的自己怪兽不能攻击。
function c19394153.initial_effect(c)
	-- 为卡片添加元素英雄系列编码
	aux.AddSetNameMonsterList(c,0x3008)
	-- 选择自己场上表侧表示存在的1只「元素英雄 羽翼侠」发动。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c19394153.condition)
	e1:SetTarget(c19394153.target)
	e1:SetOperation(c19394153.operation)
	c:RegisterEffect(e1)
end
-- 检查回合玩家能否进入战斗阶段
function c19394153.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查回合玩家能否进入战斗阶段
	return Duel.IsAbleToEnterBP()
end
-- 筛选场上表侧表示的元素英雄羽翼侠
function c19394153.filter(c)
	return c:IsFaceup() and c:IsCode(21844576)
end
-- 设置效果目标，选择场上表侧表示的元素英雄羽翼侠
function c19394153.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c19394153.filter(chkc) end
	-- 检查场上是否存在符合条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c19394153.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择符合条件的怪兽作为效果目标
	local g=Duel.SelectTarget(tp,c19394153.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置不能攻击效果，使除目标怪兽外的其他怪兽不能攻击
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ATTACK)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(c19394153.ftarget)
	e1:SetLabel(g:GetFirst():GetFieldID())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将不能攻击效果注册给玩家
	Duel.RegisterEffect(e1,tp)
end
-- 处理效果的发动，根据场上怪兽数量增加攻击次数并设置不能直接攻击
function c19394153.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取玩家场上怪兽数量
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)
		if ct>1 then
			-- 使目标怪兽获得额外攻击次数
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_EXTRA_ATTACK)
			e1:SetValue(ct-1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			-- 使目标怪兽不能直接攻击对方玩家
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
-- 设置不能攻击效果的目标条件，排除目标怪兽本身
function c19394153.ftarget(e,c)
	return e:GetLabel()~=c:GetFieldID()
end
