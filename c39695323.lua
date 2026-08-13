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
-- 过滤条件：对象必须是「隆隆隆」系列怪兽，并且可以被当前效果以表侧守备表示特殊召唤（满足苏生限制与召唤条件）。
function c39695323.filter(c,e,tp)
	return c:IsSetCard(0x59) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 目标选择与发动合法性判定：若检查已选对象，则要求该对象在自己墓地、由自己控制且满足召唤条件；若在发动时检查，则要求墓地存在至少1只满足条件的「隆隆隆」怪兽且自己主怪兽区有空位。
function c39695323.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c39695323.filter(chkc,e,tp) end
	-- 发动条件检查：确认自己墓地是否存在至少1只满足filter条件的「隆隆隆」怪兽可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c39695323.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp)
		-- 发动条件检查：确认自己主要怪兽区域存在可用的空格，用于后续特殊召唤。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	-- 向操作玩家显示“请选择要特殊召唤的卡”的选择提示，用于选择卡牌时的界面提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 让玩家从自己墓地选择1只满足filter的「隆隆隆」怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c39695323.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 向系统登记操作信息：本次效果处理包含特殊召唤分类，对象为已选择的墓地怪兽，数量为1。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果处理：将对象怪兽特殊召唤，成功后若这张卡仍与效果关联且为表侧表示，则将其变为守备表示；通过BreakEffect使后续变守备处理独立时点。
function c39695323.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果发动时选择的第1个对象怪兽（墓地那只「隆隆隆」）。
	local tc=Duel.GetFirstTarget()
	-- 确认该对象仍与效果关联后，将其以表侧守备表示特殊召唤，且特殊召唤成功（返回值不为0）时才执行后续处理。
	if tc:IsRelateToEffect(e) and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)~=0 then
		-- 中断当前效果处理，使之后的效果（变守备）视为不同时处理，避免错过时点。
		Duel.BreakEffect()
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			-- 将这张卡（隆隆隆巨人）变为表侧守备表示。
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
-- 条件判断：此卡本回合进行过攻击（攻击次数大于0），战斗阶段结束时效果成立。
function c39695323.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 效果处理：若此卡当前是攻击表示，则将其变为表侧守备表示。
function c39695323.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡变为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
