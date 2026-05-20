--機械じかけのマジックミラー
-- 效果：
-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「欧贝利斯克之巨神兵」守备表示特殊召唤。这个效果在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
function c85758066.initial_effect(c)
	-- 注册本卡记述了「欧贝利斯克之巨神兵」的卡片密码
	aux.AddCodeList(c,10000000)
	-- ①：对方怪兽的攻击宣言时，以对方墓地1张魔法卡为对象才能发动。那张卡在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c85758066.condition)
	e1:SetTarget(c85758066.target)
	e1:SetOperation(c85758066.activate)
	c:RegisterEffect(e1)
	-- ②：把墓地的这张卡除外，从手卡以及自己场上盖放的卡之中把1张「死者苏生」送去墓地才能发动。从自己墓地选1只「欧贝利斯克之巨神兵」守备表示特殊召唤。这个效果在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCost(c85758066.spcost)
	e2:SetTarget(c85758066.sptg)
	e2:SetOperation(c85758066.spop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件判定函数
function c85758066.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合
	return tp~=Duel.GetTurnPlayer()
end
-- 效果①的对象过滤函数（对方墓地的魔法卡）
function c85758066.filter(c,tp,ft)
	-- 过滤条件：是魔法卡、可以盖放，且是场地魔法或者魔陷区有空位
	return c:IsType(TYPE_SPELL) and c:IsSSetable(true) and (c:IsType(TYPE_FIELD) or Duel.GetLocationCount(tp,LOCATION_SZONE)>ft)
end
-- 效果①的发动准备与目标选择函数
function c85758066.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local ft=0
	if e:GetHandler():IsLocation(LOCATION_HAND) then ft=1 end
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(1-tp) and c85758066.filter(chkc,tp,ft) end
	-- 判定自己场上是否有足够的魔陷区空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>ft
		-- 判定对方墓地是否存在满足条件的魔法卡
		and Duel.IsExistingTarget(c85758066.filter,tp,0,LOCATION_GRAVE,1,nil,tp,ft) end
	-- 提示玩家选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 选择对方墓地1张魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c85758066.filter,tp,0,LOCATION_GRAVE,1,1,nil,tp,ft)
	-- 设置效果处理信息：涉及卡片离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果①的效果处理函数
function c85758066.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片在自己场上盖放
		Duel.SSet(tp,tc)
	end
end
-- 效果②的Cost过滤函数（手牌或自己场上盖放的「死者苏生」）
function c85758066.costfilter(c)
	return c:IsCode(83764718) and c:IsAbleToGraveAsCost()
		and (c:IsLocation(LOCATION_HAND) or (c:IsLocation(LOCATION_SZONE) and c:IsFacedown()))
end
-- 效果②的发动代价处理函数
function c85758066.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 判定手牌或自己场上盖放的卡之中是否存在「死者苏生」
		and Duel.IsExistingMatchingCard(c85758066.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil) end
	-- 将墓地的这张卡除外作为发动代价
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 选择手牌或自己场上盖放的1张「死者苏生」
	local g=Duel.SelectMatchingCard(tp,c85758066.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,1,nil)
	-- 将选择的「死者苏生」送去墓地作为发动代价
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果②的特殊召唤对象过滤函数（自己墓地的「欧贝利斯克之巨神兵」）
function c85758066.spfilter(c,e,tp)
	return c:IsCode(10000000) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
-- 效果②的发动准备与目标判定函数
function c85758066.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判定自己场上是否有可用的怪兽区域空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判定自己墓地是否存在可以特殊召唤的「欧贝利斯克之巨神兵」
		and Duel.IsExistingMatchingCard(c85758066.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置效果处理信息：从墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- 效果②的效果处理函数
function c85758066.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 判定怪兽区域是否已满，若满则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只「欧贝利斯克之巨神兵」
	local tc=Duel.SelectMatchingCard(tp,c85758066.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	-- 将选择的怪兽以守备表示特殊召唤，并判定是否特殊召唤成功
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)>0
		-- 判定当前是否为对方回合
		and Duel.GetTurnPlayer()==1-tp then
		-- 这个效果在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTargetRange(0,LOCATION_MZONE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e1:SetValue(c85758066.atklimit)
		tc:RegisterEffect(e1)
		-- 这个效果在对方回合发动的场合，这个回合只要这个效果特殊召唤的怪兽在自己场上存在，可以攻击的对方怪兽必须向那只怪兽作出攻击。
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_MUST_ATTACK)
		e2:SetRange(LOCATION_MZONE)
		e2:SetTargetRange(0,LOCATION_MZONE)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e2)
	end
end
-- 限制攻击目标过滤函数（对方怪兽不能选择除此卡以外的怪兽作为攻击对象）
function c85758066.atklimit(e,c)
	return c~=e:GetHandler()
end
