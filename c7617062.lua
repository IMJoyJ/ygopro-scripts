--ゴーストリック・ミュージアム
-- 效果：
-- 只要这张卡在场上存在，名字带有「鬼计」的怪兽以外的自己场上的怪兽不能攻击，双方场上的怪兽不能向里侧守备表示怪兽攻击，可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家。此外，给与玩家战斗伤害的怪兽在伤害步骤结束时变成里侧守备表示。
function c7617062.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上存在，名字带有「鬼计」的怪兽以外的自己场上的怪兽不能攻击
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c7617062.ftarget)
	c:RegisterEffect(e2)
	-- 双方场上的怪兽不能向里侧守备表示怪兽攻击
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetValue(c7617062.bttg)
	c:RegisterEffect(e3)
	-- 可以在对方场上的怪兽只有里侧守备表示怪兽的场合直接攻击对方玩家
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DIRECT_ATTACK)
	e4:SetRange(LOCATION_FZONE)
	e4:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e4:SetTarget(c7617062.dirtg)
	c:RegisterEffect(e4)
	-- 给与玩家战斗伤害的怪兽在伤害步骤结束时变成里侧守备表示
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetRange(LOCATION_FZONE)
	e5:SetCode(EVENT_BATTLE_DAMAGE)
	e5:SetOperation(c7617062.regop)
	c:RegisterEffect(e5)
	-- 给与玩家战斗伤害的怪兽在伤害步骤结束时变成里侧守备表示
	local e6=Effect.CreateEffect(c)
	e6:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e6:SetRange(LOCATION_FZONE)
	e6:SetCode(EVENT_DAMAGE_STEP_END)
	e6:SetCondition(c7617062.poscon)
	e6:SetOperation(c7617062.posop)
	e6:SetLabelObject(e5)
	c:RegisterEffect(e6)
end
-- 判断攻击目标是否为里侧表示怪兽
function c7617062.bttg(e,c)
	return c:IsFacedown()
end
-- 判断对方场上是否只有里侧守备表示怪兽（即不存在表侧表示怪兽），以决定是否可以进行直接攻击
function c7617062.dirtg(e,c)
	-- 检查对方场上是否不存在表侧表示的怪兽
	return not Duel.IsExistingMatchingCard(Card.IsFaceup,c:GetControler(),0,LOCATION_MZONE,1,nil)
end
-- 过滤出自己场上名字带有「鬼计」以外的怪兽
function c7617062.ftarget(e,c)
	return not c:IsSetCard(0x8d)
end
-- 在发生战斗伤害时，为本卡和造成伤害的怪兽注册标记，以便在伤害步骤结束时进行处理
function c7617062.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:RegisterFlagEffect(7617062,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
	eg:GetFirst():RegisterFlagEffect(7617063,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE,0,1)
end
-- 检查本卡是否注册了战斗伤害标记，作为伤害步骤结束时发动效果的条件
function c7617062.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(7617062)>0
end
-- 过滤出带有造成战斗伤害标记的怪兽
function c7617062.filter(c)
	return c:GetFlagEffect(7617063)>0
end
-- 在伤害步骤结束时，将所有造成战斗伤害的怪兽变成里侧守备表示
function c7617062.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取双方场上所有带有造成战斗伤害标记的怪兽
	local g=Duel.GetMatchingGroup(c7617062.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将目标怪兽改变为里侧守备表示
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)
	end
end
