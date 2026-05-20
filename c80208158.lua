--異次元エスパー・スター・ロビン
-- 效果：
-- 只要这张卡在场上表侧表示存在，对方不能把其他的自己怪兽作为卡的效果的对象，也不能作为攻击对象。此外，这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从墓地表侧守备表示特殊召唤。这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。「异次元超能人·星斗罗宾」在场上只能有1只表侧表示存在。
function c80208158.initial_effect(c)
	c:SetUniqueOnField(1,1,80208158)
	-- 只要这张卡在场上表侧表示存在，对方不能把其他的自己怪兽作为攻击对象。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c80208158.atlimit)
	c:RegisterEffect(e1)
	-- 只要这张卡在场上表侧表示存在，对方不能把其他的自己怪兽作为卡的效果的对象
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(c80208158.tglimit)
	-- 设置不能成为对方卡的效果的对象（过滤对方玩家发动的效果）
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- 此外，这张卡在墓地存在的场合，对方怪兽的直接攻击宣言时才能发动。这张卡从墓地表侧守备表示特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(80208158,0))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c80208158.spcon)
	e3:SetTarget(c80208158.sptg)
	e3:SetOperation(c80208158.spop)
	c:RegisterEffect(e3)
end
-- 过滤函数：限制攻击目标，不能选择除自身以外的怪兽作为攻击对象
function c80208158.atlimit(e,c)
	return c~=e:GetHandler()
end
-- 过滤函数：限制效果对象，不能选择除自身以外的怪兽作为效果对象
function c80208158.tglimit(e,c)
	return c~=e:GetHandler()
end
-- 特殊召唤效果的发动条件：对方怪兽直接攻击宣言时
function c80208158.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽的控制者是否为对方，且攻击对象为空（即直接攻击）
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 特殊召唤效果的发动准备（检查怪兽区域空位及自身是否能以表侧守备表示特殊召唤）
function c80208158.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查我方场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE) end
	-- 设置特殊召唤的操作信息（特殊召唤自身）
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理逻辑（特殊召唤自身，并注册离场时除外的效果）
function c80208158.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍与效果相关，则将其表侧守备表示特殊召唤，若成功则执行后续处理
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0 then
		-- 这个效果特殊召唤的这张卡从场上离开的场合从游戏中除外。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_LEAVE_FIELD_REDIRECT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_REDIRECT)
		e1:SetValue(LOCATION_REMOVED)
		c:RegisterEffect(e1,true)
	end
end
