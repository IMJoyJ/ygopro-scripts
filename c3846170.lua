--カラクリ兵 弐参六
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的名字带有「机巧」的怪兽表侧攻击表示特殊召唤。
function c3846170.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧攻击表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变成守备表示。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3846170,0))  --"变成守备表示"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetCondition(c3846170.poscon)
	e3:SetOperation(c3846170.posop)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏送去墓地时，可以从自己卡组把1只4星以下的名字带有「机巧」的怪兽表侧攻击表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(3846170,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetCondition(c3846170.spcon)
	e4:SetTarget(c3846170.sptg)
	e4:SetOperation(c3846170.spop)
	c:RegisterEffect(e4)
end
-- 效果作用：判断该卡是否处于攻击表示
function c3846170.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 效果作用：将该卡变为守备表示
function c3846170.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 执行改变表示形式的操作，将目标怪兽变为表侧守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 效果作用：判断该卡是否因战斗破坏而进入墓地
function c3846170.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
-- 过滤函数：筛选4星以下且属性为「机巧」的怪兽，且可以特殊召唤
function c3846170.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_ATTACK)
end
-- 设置特殊召唤的条件：确保场上存在空位并满足条件的怪兽数量
function c3846170.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的召唤位置
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(c3846170.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置连锁操作信息，表示将要特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果作用：执行特殊召唤操作
function c3846170.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否还有召唤位置
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c3846170.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的怪兽以表侧攻击表示特殊召唤到场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_ATTACK)
	end
end
