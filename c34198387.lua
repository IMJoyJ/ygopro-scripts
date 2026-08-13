--ニャータリング
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：场地魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。双方的场地区域有表侧表示卡存在的场合，再在这个回合让这张卡不会被战斗·效果破坏。
-- ②：只要这张卡在怪兽区域存在，自己回合内，对方的场地区域的表侧表示的卡的效果无效化，对方回合内，自己的场地区域的表侧表示的卡的效果无效化。
function c34198387.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：场地魔法卡发动的场合才能发动。这张卡从手卡特殊召唤。双方的场地区域有表侧表示卡存在的场合，再在这个回合让这张卡不会被战斗·效果破坏。
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
	-- ②：只要这张卡在怪兽区域存在，自己回合内，对方的场地区域的表侧表示的卡的效果无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_FZONE)
	e2:SetCondition(c34198387.con1)
	e2:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，对方回合内，自己的场地区域的表侧表示的卡的效果无效化。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_FZONE,0)
	e3:SetCondition(c34198387.con2)
	e3:SetCode(EFFECT_DISABLE)
	c:RegisterEffect(e3)
end
-- 判定触发条件：本次连锁中发动的效果是否为场地魔法卡的卡的发动（EFFECT_TYPE_ACTIVATE且为TYPE_FIELD），即“场地魔法卡发动的场合”的判定。
function c34198387.spcon(e,tp,eg,ep,ev,re,r,rp)
	return re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_FIELD)
end
-- 效果发动合法性检查：自己的主要怪兽区有空位，且这张卡可以特殊召唤。
function c34198387.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的主要怪兽区域是否存在空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，告知系统此效果将特殊召唤这张卡1张，用于连锁应对和效果检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联，则将其特殊召唤；若特殊召唤成功且双方场地区域表侧表示卡合计为2张，则中断当前效果另行附加本回合内不会被战斗·效果破坏的效果。
function c34198387.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认此卡仍与发动时的效果有关联，且成功特殊召唤（返回特殊召唤成功数量）。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0
		-- 双方场地区域的表侧表示卡数量合计为2张，即双方场地区都存在表侧表示卡。
		and Duel.GetFieldGroupCount(tp,LOCATION_FZONE,LOCATION_FZONE)==2 then
			-- 中断当前效果处理，使后续赋予抗性视为另开处理，避免因同批处理而错过时点。
			Duel.BreakEffect()
			-- 再在这个回合让这张卡不会被战斗·效果破坏。
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
-- ②效果“自己回合内”的条件：当前回合玩家是此卡的控制者时，无效对方场地区表侧卡的效果。
function c34198387.con1(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前回合玩家是否等于此卡的控制者。
	return Duel.GetTurnPlayer()==tp
end
-- ②效果“对方回合内”的条件：当前回合玩家是此卡控制者的对手时，无效自己场地区表侧卡的效果。
function c34198387.con2(e)
	local tp=e:GetHandlerPlayer()
	-- 判断当前回合玩家是否等于此卡控制者的对手。
	return Duel.GetTurnPlayer()==1-tp
end
