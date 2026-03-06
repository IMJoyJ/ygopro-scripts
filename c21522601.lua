--ウィッチクラフトマスター・ヴェール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己的魔法师族怪兽和对方怪兽进行战斗的伤害计算时才能发动。卡名不同的手卡的魔法卡任意数量给对方观看，那只自己怪兽的攻击力·守备力直到回合结束时上升给人观看的数量×1000。
-- ②：自己·对方回合，从手卡丢弃1张魔法卡才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
function c21522601.initial_effect(c)
	-- ①：自己的魔法师族怪兽和对方怪兽进行战斗的伤害计算时才能发动。卡名不同的手卡的魔法卡任意数量给对方观看，那只自己怪兽的攻击力·守备力直到回合结束时上升给人观看的数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21522601,0))  --"提升攻击"
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,21522601)
	e1:SetCondition(c21522601.atkcon)
	e1:SetTarget(c21522601.atktg)
	e1:SetOperation(c21522601.atkop)
	c:RegisterEffect(e1)
	-- ②：自己·对方回合，从手卡丢弃1张魔法卡才能发动。对方场上的全部表侧表示怪兽的效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21522601,1))  --"无效效果"
	e2:SetCategory(CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,21522602)
	e2:SetCost(c21522601.discost)
	e2:SetTarget(c21522601.distg)
	e2:SetOperation(c21522601.disop)
	c:RegisterEffect(e2)
end
-- 判断是否满足①效果的发动条件：攻击怪兽或被攻击怪兽是魔法师族
function c21522601.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否存在攻击目标
	return Duel.GetAttackTarget()
		-- 判断攻击怪兽是否为魔法师族
		and (Duel.GetAttacker():IsControler(tp) and Duel.GetAttacker():IsRace(RACE_SPELLCASTER)
			-- 判断被攻击怪兽是否为魔法师族
			or Duel.GetAttackTarget():IsControler(tp) and Duel.GetAttackTarget():IsRace(RACE_SPELLCASTER))
end
-- 过滤手牌中未公开的魔法卡
function c21522601.cfilter(c)
	return c:IsType(TYPE_SPELL) and not c:IsPublic()
end
-- ①效果的发动时点判定：确认手牌中存在未公开的魔法卡
function c21522601.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足①效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21522601.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
-- ①效果的处理：选择并确认手牌中的魔法卡，提升攻击和守备力
function c21522601.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前攻击怪兽
	local tc=Duel.GetAttacker()
	-- 若攻击怪兽不是自己，则获取被攻击怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 获取手牌中所有未公开的魔法卡
	local g=Duel.GetMatchingGroup(c21522601.cfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择要确认给对方的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
	-- 从符合条件的魔法卡中选择若干张卡名不同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,#g)
	if not sg then return end
	-- 向对方确认所选的魔法卡
	Duel.ConfirmCards(1-tp,sg)
	-- 将手牌洗切
	Duel.ShuffleHand(tp)
	-- 为攻击怪兽增加攻击力
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(#sg*1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	tc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	tc:RegisterEffect(e2)
end
-- 过滤丢弃或送入墓地的魔法卡
function c21522601.costfilter(c,tp)
	if c:IsLocation(LOCATION_HAND) then return c:IsType(TYPE_SPELL) and c:IsDiscardable() end
	return c:IsFaceup() and c:IsAbleToGraveAsCost() and c:IsHasEffect(83289866,tp)
end
-- ②效果的发动时点判定：确认手牌或场上存在可丢弃的魔法卡
function c21522601.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(c21522601.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,1,nil,tp) end
	-- 获取手牌或场上所有符合条件的魔法卡
	local g=Duel.GetMatchingGroup(c21522601.costfilter,tp,LOCATION_HAND+LOCATION_SZONE,0,nil,tp)
	-- 提示玩家选择要丢弃的魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	local tc=g:Select(tp,1,1,nil):GetFirst()
	local te=tc:IsHasEffect(83289866,tp)
	if te then
		te:UseCountLimit(tp)
		-- 为玩家注册一个标识效果，防止重复使用
		Duel.RegisterFlagEffect(tp,tc:GetCode(),RESET_PHASE+PHASE_END,0,1)
		-- 将选中的魔法卡送入墓地作为②效果的代价
		Duel.SendtoGrave(tc,REASON_COST)
	else
		-- 将选中的魔法卡送入墓地作为②效果的代价
		Duel.SendtoGrave(tc,REASON_COST+REASON_DISCARD)
	end
end
-- ②效果的发动时点判定：确认对方场上存在可无效的怪兽
function c21522601.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足②效果发动条件
	if chk==0 then return Duel.IsExistingMatchingCard(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,1,e:GetHandler()) end
	-- 获取对方场上的所有可无效怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,e:GetHandler())
	-- 设置连锁操作信息，记录要无效的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,g:GetCount(),0,0)
end
-- ②效果的处理：使对方场上所有怪兽的效果无效
function c21522601.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有可无效怪兽
	local g=Duel.GetMatchingGroup(aux.NegateMonsterFilter,tp,0,LOCATION_MZONE,nil)
	local tc=g:GetFirst()
	while tc do
		-- 使与该怪兽相关的连锁无效
		Duel.NegateRelatedChain(tc,RESET_TURN_SET)
		-- 使怪兽效果无效
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		-- 使怪兽效果无效化
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		e2:SetValue(RESET_TURN_SET)
		tc:RegisterEffect(e2)
		tc=g:GetNext()
	end
end
