--スターダスト・シャオロン
-- 效果：
-- 自己对「星尘龙」的同调召唤成功时，自己墓地存在的这张卡可以在自己场上表侧攻击表示特殊召唤。这张卡1回合只有1次不会被战斗破坏。
function c68543408.initial_effect(c)
	-- 注册卡片效果中记载了「星尘龙」的卡片密码
	aux.AddCodeList(c,44508094)
	-- 自己对「星尘龙」的同调召唤成功时，自己墓地存在的这张卡可以在自己场上表侧攻击表示特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(68543408,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(c68543408.spcon)
	e1:SetTarget(c68543408.sptg)
	e1:SetOperation(c68543408.spop)
	c:RegisterEffect(e1)
	-- 这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(c68543408.valcon)
	c:RegisterEffect(e2)
end
-- 检查特殊召唤成功的怪兽是否为自己场上的「星尘龙」且该召唤方式为同调召唤
function c68543408.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return tc:IsControler(tp) and tc:IsCode(44508094) and tc:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 特殊召唤效果的发动检测与目标处理，判断自己场上是否有空位且自身能否特殊召唤
function c68543408.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动阶段，检查当前玩家的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK) end
	-- 设置连锁处理的操作信息，表明此效果将特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行函数，若自身仍存在于墓地，则将其表侧攻击表示特殊召唤
function c68543408.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身以表侧攻击表示特殊召唤到自己的场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
-- 判断破坏原因是否为战斗破坏，用于一回合一次不会被战破的效果
function c68543408.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
