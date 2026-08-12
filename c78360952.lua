--白昼のスナイパー
-- 效果：
-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
-- ②：盖放的这张卡被破坏送去墓地的场合，下个回合的准备阶段才能发动。这张卡特殊召唤。那之后，和这张卡相同纵列的对方的卡全部破坏。
function c78360952.initial_effect(c)
	-- ①：这张卡可以当作魔法卡使用从手卡到魔法与陷阱区域盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_MONSTER_SSET)
	e1:SetValue(TYPE_SPELL)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被破坏送去墓地的场合
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetOperation(c78360952.regop)
	c:RegisterEffect(e2)
	-- 下个回合的准备阶段才能发动。这张卡特殊召唤。那之后，和这张卡相同纵列的对方的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(78360952,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCondition(c78360952.spcon)
	e3:SetTarget(c78360952.sptg)
	e3:SetOperation(c78360952.spop)
	c:RegisterEffect(e3)
end
-- 在盖放的自身被破坏送去墓地时，为自身注册一个Flag标记，用于在下个回合准备阶段检测发动条件
function c78360952.regop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEDOWN) and c:IsReason(REASON_DESTROY) then
		c:RegisterFlagEffect(78360952,RESET_EVENT+RESETS_STANDARD,1,0)
	end
end
-- 特殊召唤效果的发动条件函数，判断是否在被破坏送墓的下个回合的准备阶段
function c78360952.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合数是否为该卡送墓回合的下一回合，且该卡具有被破坏送墓的Flag标记
	return Duel.GetTurnCount()==c:GetTurnID()+1 and c:GetFlagEffect(78360952)>0
end
-- 特殊召唤效果的发动检测函数，确认怪兽区域有空位且自身可以特殊召唤
function c78360952.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，确认当前玩家的主要怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息，声明此效果包含将自身特殊召唤的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，将自身特殊召唤，并破坏相同纵列的对方卡片
function c78360952.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若自身仍与效果相关，则将自身以表侧表示特殊召唤，并判断是否特殊召唤成功
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local cg=c:GetColumnGroup():Filter(Card.IsControler,nil,1-tp)
		if #cg==0 then return end
		-- 中断当前效果处理，使特殊召唤与后续的破坏不视为同时处理
		Duel.BreakEffect()
		-- 通过效果破坏与这张卡相同纵列的对方的所有卡
		Duel.Destroy(cg,REASON_EFFECT)
	end
end
