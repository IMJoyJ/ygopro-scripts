--カラクリ忍者 九壱九
-- 效果：
-- 这张卡可以攻击的场合必须作出攻击。场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。这张卡战斗破坏对方怪兽送去墓地时，选择自己墓地存在的1只4星以下的名字带有「机巧」的怪兽表侧守备表示特殊召唤。
function c6276588.initial_effect(c)
	-- 这张卡可以攻击的场合必须作出攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MUST_ATTACK)
	c:RegisterEffect(e1)
	-- 场上表侧表示存在的这张卡被选择作为攻击对象时，这张卡的表示形式变更。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(6276588,0))  --"表示形式变更"
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_SINGLE)
	e3:SetCode(EVENT_BE_BATTLE_TARGET)
	e3:SetOperation(c6276588.posop)
	c:RegisterEffect(e3)
	-- 这张卡战斗破坏对方怪兽送去墓地时，选择自己墓地存在的1只4星以下的名字带有「机巧」的怪兽表侧守备表示特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(6276588,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetCode(EVENT_BATTLE_DESTROYED)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCondition(c6276588.spcon)
	e4:SetTarget(c6276588.sptg)
	e4:SetOperation(c6276588.spop)
	c:RegisterEffect(e4)
end
-- 表示形式变更效果的处理函数，若自身在场上表侧表示存在，则改变其表示形式
function c6276588.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 改变卡片的表示形式（表侧攻击表示与表侧守备表示互相转换）
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE,0,POS_FACEUP_ATTACK,0)
	end
end
-- 特殊召唤效果的发动条件：被战斗破坏送去墓地的怪兽仅有1只，且是被本卡战斗破坏
function c6276588.spcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	return eg:GetCount()==1 and tc:GetReasonCard()==e:GetHandler()
		and tc:IsLocation(LOCATION_GRAVE) and tc:IsReason(REASON_BATTLE)
end
-- 过滤条件：自己墓地中等级4以下、名字带有「机巧」且可以特殊召唤的怪兽
function c6276588.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 特殊召唤效果的靶向与发动准备，选择墓地1只符合条件的怪兽作为对象，并设置特殊召唤的操作信息
function c6276588.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c6276588.filter(chkc,e,tp) end
	if chk==0 then return true end
	-- 在客户端提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择自己墓地1只符合条件的「机巧」怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c6276588.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置当前连锁的操作信息为特殊召唤该对象怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 特殊召唤效果的处理函数，将选择的对象怪兽特殊召唤
function c6276588.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧守备表示特殊召唤到自己场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
