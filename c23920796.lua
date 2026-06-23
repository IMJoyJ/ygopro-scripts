--ミミグル・ケルベロス
-- 效果：
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
-- ②：对方不能把自己场上的表侧表示的魔法卡作为效果的对象。
-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
-- ●从自己卡组上面把3张卡除外。那之后，自己的除外状态的1只怪兽在对方场上守备表示特殊召唤。
-- ●这张卡的控制权移给对方。
local s,id,o=GetID()
-- 注册三个效果：反转效果、特殊召唤效果和永续效果
function s.initial_effect(c)
	-- ③：这张卡在主要阶段反转的场合发动。以下效果各适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"反转效果"
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_CONTROL+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_F)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	-- 检查当前是否处于主要阶段
	e1:SetCondition(aux.MimighoulFlipCondition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	-- ①：自己主要阶段才能发动。这张卡从手卡往对方场上里侧守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：对方不能把自己场上的表侧表示的魔法卡作为效果的对象。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e3:SetTargetRange(LOCATION_ONFIELD,0)
	-- 设置目标为场上表侧表示的魔法卡
	e3:SetTarget(aux.TargetBoolFunction(aux.AND(Card.IsType,Card.IsFaceup),TYPE_SPELL))
	-- 设置该效果使目标不能成为对方效果的对象
	e3:SetValue(aux.tgoval)
	c:RegisterEffect(e3)
end
-- 设置反转效果的处理信息，包括除外、特殊召唤和改变控制权
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置将从卡组顶部除外3张卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,3,tp,LOCATION_DECK)
	-- 设置将从除外区特殊召唤1只怪兽的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_REMOVED)
	-- 设置将自身控制权移给对方的操作信息
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤的过滤函数，用于选择可特殊召唤的除外怪兽
function s.spfilter(c,e,tp)
	return c:IsFaceup() and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE,1-tp)
end
-- 执行反转效果的处理流程，包括除外卡组顶部3张卡、选择并特殊召唤除外区怪兽、交换控制权
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取玩家卡组顶部的3张卡
	local tg=Duel.GetDecktopGroup(tp,3)
	if #tg==0 then return end
	-- 禁止在除外操作后自动洗切卡组
	Duel.DisableShuffleCheck()
	-- 判断是否成功除外卡组顶部3张卡且对方场上有空位
	if Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)>0 and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		-- 判断除外区是否存在满足条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_REMOVED,0,1,nil,e,tp) then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的除外怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
		if #g>0 then
			-- 中断当前效果处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 将选中的怪兽特殊召唤到对方场上
			Duel.SpecialSummon(g:GetFirst(),0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 将自身控制权移交给对方
		Duel.GetControl(c,1-tp)
	end
end
-- 设置特殊召唤效果的处理信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断是否满足特殊召唤条件
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE,1-tp) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 end
	-- 设置特殊召唤操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 执行特殊召唤效果的处理流程
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 将自身特殊召唤到对方场上并确认其为盖放状态
		if Duel.SpecialSummon(c,0,tp,1-tp,false,false,POS_FACEDOWN_DEFENSE)>0 then Duel.ConfirmCards(tp,c) end
	end
end
