--青眼の混沌龍
-- 效果：
-- 「混沌形态」降临
-- 这张卡不用仪式召唤不能特殊召唤。
-- ①：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ②：使用「青眼白龙」作仪式召唤的这张卡的攻击宣言时才能发动。对方场上的全部怪兽的表示形式变更。这个效果让表示形式变更的怪兽的攻击力·守备力变成0。这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c20654247.initial_effect(c)
	-- 记录该卡具有「青眼白龙」的卡名代码
	aux.AddCodeList(c,89631139)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置该卡的特殊召唤条件为必须通过仪式召唤
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置该卡不会被对方的效果选为对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 场上的这张卡不会被对方的效果破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置该卡不会被对方的效果破坏
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- 使用「青眼白龙」作仪式召唤的这张卡的攻击宣言时才能发动。对方场上的全部怪兽的表示形式变更。这个效果让表示形式变更的怪兽的攻击力·守备力变成0。这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20654247,0))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c20654247.poscon)
	e4:SetTarget(c20654247.postg)
	e4:SetOperation(c20654247.posop)
	c:RegisterEffect(e4)
	-- 特殊召唤成功时触发的效果，用于标记该卡是否使用了「青眼白龙」作为素材
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c20654247.matcon)
	e0:SetOperation(c20654247.matop)
	c:RegisterEffect(e0)
	-- 检查该卡的素材中是否包含「青眼白龙」
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c20654247.valcheck)
	e5:SetLabelObject(e0)
	c:RegisterEffect(e5)
end
-- 判断该卡是否通过仪式召唤且已标记使用了「青眼白龙」作为素材
function c20654247.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 为该卡设置一个标记，表示其已通过仪式召唤且使用了「青眼白龙」作为素材
function c20654247.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20654247,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 检查该卡的召唤素材中是否包含「青眼白龙」，并设置标记
function c20654247.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsCode,1,nil,89631139) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 判断该卡是否已标记使用了「青眼白龙」作为素材
function c20654247.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(20654247)>0
end
-- 准备发动效果，检查对方场上是否存在可变更表示形式的怪兽
function c20654247.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一张可变更表示形式的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可变更表示形式的怪兽
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	-- 设置连锁操作信息，表示将要变更对方场上怪兽的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- 执行效果，变更对方场上所有怪兽的表示形式并将其攻击力和守备力设为0，同时赋予自身穿透效果
function c20654247.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取对方场上所有可变更表示形式的怪兽
	local tg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	while tc do
		-- 尝试变更该怪兽的表示形式为表侧守备、里侧守备、表侧攻击、表侧攻击
		if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
			-- 将该怪兽的攻击力设为0
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 将该怪兽的守备力设为0
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_SET_DEFENSE_FINAL)
			e2:SetValue(0)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
		tc=tg:GetNext()
	end
	if c:IsRelateToEffect(e) then
		-- 赋予自身穿透效果
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
