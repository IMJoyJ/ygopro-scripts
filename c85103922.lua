--アーティファクト－モラルタ
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
-- ③：对方回合，这张卡特殊召唤成功的场合才能发动。选对方场上1张表侧表示的卡破坏。
function c85103922.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：魔法与陷阱区域盖放的这张卡在对方回合被破坏送去墓地的场合发动。这张卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(85103922,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c85103922.spcon)
	e2:SetTarget(c85103922.sptg)
	e2:SetOperation(c85103922.spop)
	c:RegisterEffect(e2)
	-- ③：对方回合，这张卡特殊召唤成功的场合才能发动。选对方场上1张表侧表示的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(85103922,1))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCondition(c85103922.descon)
	e3:SetTarget(c85103922.destg)
	e3:SetOperation(c85103922.desop)
	c:RegisterEffect(e3)
end
-- 判断特殊召唤效果的发动条件：自身在魔法与陷阱区域盖放，且在对方回合被破坏并送去墓地
function c85103922.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_SZONE) and c:IsPreviousPosition(POS_FACEDOWN)
		and c:IsPreviousControler(tp)
		-- 判断送去墓地的原因是否为破坏，且当前回合玩家不是自己（即对方回合）
		and c:IsReason(REASON_DESTROY) and Duel.GetTurnPlayer()~=tp
end
-- 特殊召唤效果的发动准备（检测与设置操作信息）
function c85103922.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁的操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的执行：若自身仍存在于原本位置，则将其特殊召唤
function c85103922.spop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) then
		-- 将自身以表侧表示特殊召唤到自己的场上
		Duel.SpecialSummon(e:GetHandler(),0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判断破坏效果的发动条件：当前是对方回合
function c85103922.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 过滤条件：筛选表侧表示的卡
function c85103922.filter(c)
	return c:IsFaceup()
end
-- 破坏效果的发动准备：检查对方场上是否存在表侧表示的卡，并设置破坏的操作信息
function c85103922.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时点检查对方场上是否存在至少1张表侧表示的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c85103922.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有表侧表示的卡片
	local g=Duel.GetMatchingGroup(c85103922.filter,tp,0,LOCATION_ONFIELD,nil)
	-- 设置连锁的操作信息：破坏对方场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的执行：选择对方场上1张表侧表示的卡破坏
function c85103922.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息：请选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上1张表侧表示的卡
	local g=Duel.SelectMatchingCard(tp,c85103922.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 为被选择的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 因效果破坏所选的卡
		Duel.Destroy(g,REASON_EFFECT)
	end
end
