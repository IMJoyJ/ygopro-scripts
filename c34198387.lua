--ニャータリング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：场地魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。双方的场地区域有表侧表示卡存在的场合，再在这个回合让这张卡不会被战斗·效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己回合内，对方的场地区域的表侧表示的卡的效果无效化，对方回合内，自己的场地区域的表侧表示的卡的效果无效化。
function c34198387.initial_effect(c)
	-- ①：场地魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34198387,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,34198387)
	e1:SetCondition(c34198387.spcon)
	e1:SetTarget(c34198387.sptg)
	e1:SetOperation(c34198387.spop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，自己回合内，对方的场地区域的表侧表示的卡的效果无效化，对方回合内，自己的场地区域的表侧表示的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_FZONE)
	e2:SetCondition(c34198387.con1)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己回合内，对方的场地区域的表侧表示的卡的效果无效化，对方回合内，自己的场地区域的表侧表示的卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_FZONE,0)
	e3:SetCondition(c34198387.con2)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
end
-- 判断连锁的发动是否为场地魔法卡的发动
function c34198387.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_FIELD)
end
-- 设置特殊召唤的处理目标
function c34198387.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有足够的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 处理特殊召唤效果及后续的不被破坏效果
function c34198387.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断卡片是否仍存在于场上并成功特殊召唤
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 判断双方场地区域都有表侧表示的卡存在
		and Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2 then
			-- 中断当前连锁效果的处理
			Duel.BreakEffect()
			-- 使这张卡在本回合不会被战斗破坏
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			c:RegisterEffect(e2)
	end
end
-- 判断是否为自己的回合
function c34198387.con1(e)
	local tp=e:GetHandlerPlayer()
	-- 判断是否为自己的回合
	return Duel.GetTurnPlayer()==tp
end
-- 判断是否为对方的回合
function c34198387.con2(e)
	local tp=e:GetHandlerPlayer()
	-- 判断是否为对方的回合
	return Duel.GetTurnPlayer()==1-tp
end
