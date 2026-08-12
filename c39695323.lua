--ゴゴゴジャイアント
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只「隆隆隆」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，这张卡变成守备表示。
-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
function c39695323.initial_effect(c)
	-- ①：这张卡召唤成功时，以自己墓地1只「隆隆隆」怪兽为对象才能发动。那只怪兽守备表示特殊召唤。那之后，这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(39695323,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c39695323.sptg)
	e1:SetOperation(c39695323.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c39695323.poscon)
	e2:SetOperation(c39695323.posop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地「隆隆隆」怪兽，用于特殊召唤
function c39695323.filter(c,e,tp)
	return c:IsSetCard(0x59) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 设置效果目标为满足条件的墓地怪兽
function c39695323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39695323.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：存在满足条件的墓地怪兽
	if chk==0 then return Duel.IsExistingTarget(c39695323.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 判断是否满足发动条件：场上存在空位
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c39695323.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息，确定特殊召唤的卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 处理效果的发动，将目标怪兽特殊召唤并改变自身表示形式
function c39695323.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	-- 判断目标怪兽是否有效且成功特殊召唤
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 中断当前效果处理，防止连锁错时
		Duel.BreakEffect()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将自身变为守备表示
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
-- 判断该怪兽是否在战斗阶段中攻击过
function c39695323.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 当战斗阶段结束时，若自身处于攻击表示则变为守备表示
function c39695323.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将自身变为守备表示
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
