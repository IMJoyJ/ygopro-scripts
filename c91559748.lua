--棘の妖精
-- 效果：
-- 对方不破坏这张卡，就不能对昆虫族怪兽进行攻击。与这张卡进行战斗的怪兽，在伤害步骤终了时变成守备表示。
function c91559748.initial_effect(c)
	-- 与这张卡进行战斗的怪兽，在伤害步骤终了时变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(91559748,0))  --"变成守备表示"
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DAMAGE_STEP_END)
	e1:SetCondition(c91559748.cpcon)
	e1:SetTarget(c91559748.cptg)
	e1:SetOperation(c91559748.cpop)
	c:RegisterEffect(e1)
	-- 对方不破坏这张卡，就不能对昆虫族怪兽进行攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c91559748.tg)
	c:RegisterEffect(e2)
end
-- 判断目标卡片是否为表侧表示的昆虫族怪兽
function c91559748.tg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT)
end
-- 在伤害步骤结束时，获取与自身战斗的怪兽并将其存入标签对象，同时判断是否满足发动条件
function c91559748.cpcon(e,tp,eg,ep,ev,re,r,rp)
	local t=e:GetHandler():GetBattleTarget()
	e:SetLabelObject(t)
	-- 利用辅助函数判断自身战斗状态，并确认战斗对手存在且与本次战斗关联
	return aux.dsercon(e,tp,eg,ep,ev,re,r,rp) and t and t:IsRelateToBattle()
end
-- 效果发动的准备，设置改变表示形式的操作信息
function c91559748.cptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置改变表示形式的操作信息，目标为与这张卡战斗的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,e:GetLabelObject(),1,0,0)
end
-- 效果处理，若与这张卡战斗的怪兽仍与战斗关联且为攻击表示，则将其变为表侧守备表示
function c91559748.cpop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if g:IsRelateToBattle() and g:IsAttackPos() then
		-- 将目标怪兽改变为表侧守备表示
		Duel.ChangePosition(g,POS_FACEUP_DEFENSE)
	end
end
