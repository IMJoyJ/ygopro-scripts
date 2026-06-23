--占術姫コインノーマ
-- 效果：
-- ①：这张卡反转的场合才能发动。从手卡·卡组把1只3星以上的反转怪兽里侧守备表示特殊召唤。这个效果的发动后，直到回合结束时自己不能把「占术姬」怪兽以外的怪兽的效果发动。
function c32231618.initial_effect(c)
	-- 创建一个反转诱发效果，用于处理特殊召唤和限制发动的规则
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_MSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c32231618.sptg)
	e1:SetOperation(c32231618.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数，用于筛选满足条件的反转怪兽（3星以上，可特殊召唤）
function c32231618.spfilter(c,e,tp)
	return c:IsType(TYPE_FLIP) and c:IsLevelAbove(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
end
-- 效果的发动检查函数，判断是否满足特殊召唤的条件
function c32231618.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡或卡组中是否存在符合条件的反转怪兽
		and Duel.IsExistingMatchingCard(c32231618.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_HAND)
end
-- 效果的处理函数，执行特殊召唤和发动限制的效果
function c32231618.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检查场上是否有足够的怪兽区域
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 选择满足条件的1只怪兽作为特殊召唤目标
		local g=Duel.SelectMatchingCard(tp,c32231618.spfilter,tp,LOCATION_DECK+LOCATION_HAND,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽以里侧守备表示特殊召唤到场上
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
			-- 向对方确认特殊召唤的怪兽
			Duel.ConfirmCards(1-tp,g)
		end
	end
	-- 设置发动后直到回合结束时自己不能发动「占术姬」怪兽以外的怪兽效果
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetValue(c32231618.actlimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将限制发动效果注册到场上
	Duel.RegisterEffect(e1,tp)
end
-- 限制发动效果的判断函数，禁止发动非「占术姬」怪兽的效果
function c32231618.actlimit(e,re,rp)
	local rc=re:GetHandler()
	return re:IsActiveType(TYPE_MONSTER) and not rc:IsSetCard(0xcc)
end
