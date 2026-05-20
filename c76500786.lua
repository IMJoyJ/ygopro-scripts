--一曲集中
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己的连接怪兽和对方怪兽进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力只在那次伤害计算时上升那所连接区的怪兽的等级·阶级的合计×400。
function c76500786.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己的连接怪兽和对方怪兽进行战斗的伤害计算时才能发动。那只自己怪兽的攻击力只在那次伤害计算时上升那所连接区的怪兽的等级·阶级的合计×400。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCountLimit(1,76500786+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c76500786.condition)
	e1:SetOperation(c76500786.activate)
	c:RegisterEffect(e1)
end
-- 定义辅助函数，用于获取怪兽的等级（超量怪兽则获取其阶级）
function c76500786.lv_or_rk(c)
	if c:IsType(TYPE_XYZ) then return c:GetRank()
	else return c:GetLevel() end
end
-- 判断发动条件：是否为自己的连接怪兽与对方怪兽进行战斗的伤害计算时，且该连接怪兽所连接区存在有等级或阶级的怪兽
function c76500786.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 获取进行战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 获取进行战斗的被攻击怪兽
	local at=Duel.GetAttackTarget()
	if not at then return false end
	if tc:IsControler(1-tp) then tc=at end
	e:SetLabelObject(tc)
	local lg=tc:GetLinkedGroup()
	return tc:IsControler(tp) and tc:IsLocation(LOCATION_MZONE) and tc:IsType(TYPE_LINK) and lg and lg:GetSum(c76500786.lv_or_rk)>0
end
-- 执行卡片发动效果：使进行战斗的自己连接怪兽的攻击力在伤害计算时上升其所连接区怪兽的等级·阶级合计×400
function c76500786.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	local lg=tc:GetLinkedGroup()
	if tc:IsControler(tp) and tc:IsRelateToBattle() and lg then
		local atk=lg:GetSum(c76500786.lv_or_rk)
		-- 那只自己怪兽的攻击力只在那次伤害计算时上升那所连接区的怪兽的等级·阶级的合计×400。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk*400)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
		tc:RegisterEffect(e1)
	end
end
