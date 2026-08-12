--メタモル・クレイ・フォートレス
-- 效果：
-- ①：以自己场上1只4星以上的怪兽为对象才能发动。这张卡发动后变成效果怪兽（岩石族·地·4星·攻/守1000）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
-- ②：这张卡的效果特殊召唤的这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的攻击力数值，这张卡在攻击的伤害步骤结束时变成守备表示。
function c43959432.initial_effect(c)
	-- ①：以自己场上1只4星以上的怪兽为对象才能发动。这张卡发动后变成效果怪兽（岩石族·地·4星·攻/守1000）在怪兽区域特殊召唤。那之后，作为对象的表侧表示怪兽当作装备卡使用给这张卡装备。这张卡也当作陷阱卡使用。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c43959432.target)
	e1:SetOperation(c43959432.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡的效果特殊召唤的这张卡的攻击力·守备力上升这张卡的效果装备的怪兽的攻击力数值，这张卡在攻击的伤害步骤结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_DAMAGE_STEP_END)
	e2:SetCondition(c43959432.poscon)
	e2:SetOperation(c43959432.posop)
	c:RegisterEffect(e2)
	-- 以自己场上1只4星以上的怪兽为对象才能发动。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c43959432.atkcon)
	e3:SetValue(c43959432.atkval)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e4)
end
-- 检索满足条件的4星以上表侧表示怪兽
function c43959432.filter(c)
	return c:IsFaceup() and c:IsLevelAbove(4)
end
-- 判断是否满足发动条件
function c43959432.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c43959432.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 判断自己场上是否有足够的怪兽区域
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检索满足条件的4星以上表侧表示怪兽
		and Duel.IsExistingTarget(c43959432.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 判断自己是否可以特殊召唤此卡
		and Duel.IsPlayerCanSpecialSummonMonster(tp,43959432,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的4星以上表侧表示怪兽作为对象
	local g=Duel.SelectTarget(tp,c43959432.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 发动效果并特殊召唤此卡为效果怪兽
function c43959432.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自己是否可以特殊召唤此卡
	if not Duel.IsPlayerCanSpecialSummonMonster(tp,43959432,0,TYPES_EFFECT_TRAP_MONSTER,1000,1000,4,RACE_ROCK,ATTRIBUTE_EARTH) then return end
	c:AddMonsterAttribute(TYPE_EFFECT+TYPE_TRAP)
	-- 将此卡特殊召唤到自己场上
	if Duel.SpecialSummon(c,SUMMON_VALUE_SELF,tp,tp,true,false,POS_FACEUP)==0 then return end
	-- 获取此卡的装备对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 将对象怪兽装备给此卡
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备限制效果
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e4:SetCode(EFFECT_EQUIP_LIMIT)
		e4:SetReset(RESET_EVENT+RESETS_STANDARD)
		e4:SetValue(c43959432.eqlimit)
		tc:RegisterEffect(e4,true)
		e:SetLabelObject(tc)
	end
end
-- 判断是否满足攻击后变为守备表示的条件
function c43959432.poscon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 此卡为特殊召唤且为攻击怪兽且参与战斗
	return c:GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF and c==Duel.GetAttacker() and c:IsRelateToBattle()
end
-- 将此卡变为守备表示
function c43959432.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将此卡变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 判断是否满足攻击力增加的条件
function c43959432.atkcon(e)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 计算装备怪兽的攻击力作为此卡的攻击力
function c43959432.atkval(e,c)
	local tc=e:GetLabelObject():GetLabelObject()
	if not tc or tc:GetEquipTarget()~=c then return 0 end
	local atk=tc:GetAttack()
	if atk<0 then atk=0 end
	return atk
end
-- 设置装备限制效果的判断函数
function c43959432.eqlimit(e,c)
	return e:GetOwner()==c
end
