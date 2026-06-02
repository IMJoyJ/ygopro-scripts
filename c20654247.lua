--青眼の混沌龍
-- 效果：
-- 「混沌形态」降临
-- 这张卡不用仪式召唤不能特殊召唤。
-- ①：场上的这张卡不会被对方的效果破坏，对方不能把场上的这张卡作为效果的对象。
-- ②：使用「青眼白龙」作仪式召唤的这张卡的攻击宣言时才能发动。对方场上的全部怪兽的表示形式变更。这个效果让表示形式变更的怪兽的攻击力·守备力变成0。这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
function c20654247.initial_effect(c)
	-- 在卡片的关联卡片列表中注册「青眼白龙」和「混沌形态」，以便进行相关卡名检测。
	aux.AddCodeList(c,89631139,21082832)
	c:EnableReviveLimit()
	-- 这张卡不用仪式召唤不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	-- 设置特殊召唤的限制条件为必须通过仪式召唤进行特殊召唤。
	e1:SetValue(aux.ritlimit)
	c:RegisterEffect(e1)
	-- 对方不能把场上的这张卡作为效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	-- 设置不能成为效果对象的效果过滤条件为对方玩家发动的卡的效果。
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 场上的这张卡不会被对方的效果破坏
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	-- 设置不会被效果破坏的过滤条件为对方玩家发动的卡的效果。
	e3:SetValue(aux.indoval)
	c:RegisterEffect(e3)
	-- ②：使用「青眼白龙」作仪式召唤的这张卡的攻击宣言时才能发动。对方场上的全部怪兽的表示形式变更。这个效果让表示形式变更的怪兽的攻击力·守备力变成0。这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(20654247,0))
	e4:SetCategory(CATEGORY_POSITION)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetCondition(c20654247.poscon)
	e4:SetTarget(c20654247.postg)
	e4:SetOperation(c20654247.posop)
	c:RegisterEffect(e4)
	-- ②：使用「青眼白龙」作仪式召唤的这张卡的攻击宣言时才能发动。对方场上的全部怪兽的表示形式变更。这个效果让表示形式变更的怪兽的攻击力·守备力变成0。这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_SPSUMMON_SUCCESS)
	e0:SetCondition(c20654247.matcon)
	e0:SetOperation(c20654247.matop)
	c:RegisterEffect(e0)
	-- ②：使用「青眼白龙」作仪式召唤的这张卡
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_MATERIAL_CHECK)
	e5:SetValue(c20654247.valcheck)
	e5:SetLabelObject(e0)
	c:RegisterEffect(e5)
end
-- 检查此卡是否是通过仪式召唤进行特殊召唤，并且仪式召唤时使用了「青眼白龙」作为素材的条件判断。
function c20654247.matcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_RITUAL) and e:GetLabel()==1
end
-- 若满足仪式召唤且使用了「青眼白龙」作为素材的条件，则为此卡注册一个表示已满足该条件的Flag效果。
function c20654247.matop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(20654247,RESET_EVENT+RESETS_STANDARD,0,1)
end
-- 在仪式召唤进行时，检查用于仪式召唤的素材中是否包含卡密码为89631139（「青眼白龙」）的卡，若是则在相应的效果上设置标记值1，否则设为0。
function c20654247.valcheck(e,c)
	local mg=c:GetMaterial()
	if mg:IsExists(Card.IsCode,1,nil,89631139) then
		e:GetLabelObject():SetLabel(1)
	else
		e:GetLabelObject():SetLabel(0)
	end
end
-- 检查此卡是否具有「使用『青眼白龙』作仪式召唤的这张卡」的标记以判断效果是否能够发动。
function c20654247.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(20654247)>0
end
-- ②效果的发动准备与合法性检查，确认对方场上是否存在可以变更表示形式的怪兽，并注册变更表示形式的操作信息。
function c20654247.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断对方场上是否存在至少1个可以变更表示形式的怪兽，作为效果发动的可行性检查。
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil) end
	-- 获取对方场上所有可以变更表示形式的怪兽的卡片组。
	local g=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	-- 设置当前连锁的操作信息，标记该效果包含变更对方场上表示形式怪兽的效果分类。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,g:GetCount(),0,0)
end
-- ②效果的实效处理：将对方场上所有能改变表示形式的怪兽表示形式变更，并将这些变更了表示形式的怪兽的攻击力与守备力永久变成0，然后在此卡上注册本回合内向守备表示怪兽攻击时给予穿防战斗伤害的效果。
function c20654247.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 在效果处理时，重新获取对方场上所有可以变更表示形式的怪兽的卡片组。
	local tg=Duel.GetMatchingGroup(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,nil)
	local tc=tg:GetFirst()
	while tc do
		-- 将怪兽的表示形式进行变更（表侧守备变里侧守备，里侧守备变表侧攻击，表侧攻击变表侧攻击），并判断是否成功变更了表示形式。
		if Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)~=0 then
			-- 这个效果让表示形式变更的怪兽的攻击力·守备力变成0。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_SET_ATTACK_FINAL)
			e1:SetValue(0)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			-- 这个效果让表示形式变更的怪兽的攻击力·守备力变成0。
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
		-- 这个回合，这张卡向守备表示怪兽攻击的场合，给与对方为攻击力超过那个守备力的数值的战斗伤害。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(EFFECT_PIERCE)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e3)
	end
end
