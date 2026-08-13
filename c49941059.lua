--奇跡のマジック・ゲート
-- 效果：
-- ①：自己场上有魔法师族怪兽2只以上存在的场合才能发动。选对方场上1只攻击表示怪兽变成守备表示。那之后，得到那只怪兽的控制权。这个效果得到控制权的怪兽不会被战斗破坏。
function c49941059.initial_effect(c)
	-- ①：自己场上有魔法师族怪兽2只以上存在的场合才能发动。选对方场上1只攻击表示怪兽变成守备表示。那之后，得到那只怪兽的控制权。这个效果得到控制权的怪兽不会被战斗破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_CONTROL+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c49941059.condition)
	e1:SetTarget(c49941059.target)
	e1:SetOperation(c49941059.operation)
	c:RegisterEffect(e1)
end
-- 筛选条件：怪兽须为表侧表示且种族为魔法师族，用于后续检查自己场上是否存在满足条件的魔法师族怪兽。
function c49941059.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
-- 发动条件判定：自己场上存在至少2只表侧表示的魔法师族怪兽时才满足①效果的发动条件。
function c49941059.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上主要怪兽区是否存在至少2只满足cfilter（表侧魔法师族）的怪兽，以此判断是否满足发动条件。
	return Duel.IsExistingMatchingCard(c49941059.cfilter,tp,LOCATION_MZONE,0,2,nil)
end
-- 目标筛选条件：对方场上攻击表示、可以被效果改变表示形式、且控制权可以被变更的怪兽才能成为本效果的对象。
function c49941059.tgfilter(c)
	return c:IsAttackPos() and c:IsCanChangePosition() and c:IsControlerCanBeChanged()
end
-- 目标处理：发动时先确认存在合法目标，并向系统登记本效果将进行的表示形式变更和控制权夺取操作；实际目标在效果处理时选择。
function c49941059.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0（效果发动时的合法性检查）时，检查对方场上是否存在至少1只满足tgfilter的怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c49941059.tgfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 登记操作信息：宣告本效果会将对方场上1只怪兽（处理时确定）变更表示形式，供时点/干扰等系统判定使用。
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,1-tp,LOCATION_MZONE)
	-- 登记操作信息：宣告本效果会取得对方场上1只怪兽（处理时确定）的控制权，供时点/干扰等系统判定使用。
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
-- 效果处理：从对方场上选择1只满足条件的攻击表示怪兽，先将其变为守备表示；变更成功后中断时点，再取得其控制权；若控制权夺取成功，则为该怪兽附加不会被战斗破坏的效果。
function c49941059.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示，告知玩家正在选择要改变控制权的怪兽（HINTMSG_CONTROL对应的提示文本）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)  --"请选择要改变控制权的怪兽"
	-- 从对方主要怪兽区选择1只满足tgfilter（攻击表示、可变更表示形式、可变更控制权）的怪兽作为处理对象。
	local g=Duel.SelectMatchingCard(tp,c49941059.tgfilter,tp,0,LOCATION_MZONE,1,1,nil)
	local c=g:GetFirst()
	-- 若存在已选怪兽，则将攻击表示变为守备表示（表侧守备或里侧守备），并判断变更操作是否成功；只有成功才继续“那之后”的处理。
	if c and Duel.ChangePosition(c,POS_FACEUP_DEFENSE,POS_FACEDOWN_DEFENSE)>0 then
		-- Duel.BreakEffect()：将后续控制权夺取处理与之前的表示形式变更处理分开，制造错时点。
		Duel.BreakEffect()
		-- 尝试将所选怪兽的控制权转移给tp；若转移成功（返回值大于0），则继续执行附加效果的后续处理。
		if Duel.GetControl(c,tp)>0 then
			-- 这个效果得到控制权的怪兽不会被战斗破坏。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
end
