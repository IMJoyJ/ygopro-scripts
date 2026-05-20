--D-HERO ダッシュガイ
-- 效果：
-- ①：1回合1次，把自己场上1只怪兽解放才能发动。这张卡的攻击力直到回合结束时上升1000。
-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
-- ③：只在这张卡在墓地存在才有1次，自己在自己抽卡阶段抽卡时，那卡是怪兽的场合，把那1只怪兽给双方确认才能发动。这张卡在墓地存在的场合，那只确认的怪兽特殊召唤。
function c81866673.initial_effect(c)
	-- ①：1回合1次，把自己场上1只怪兽解放才能发动。这张卡的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81866673,0))  --"攻击上升"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(c81866673.atkcost)
	e1:SetOperation(c81866673.atkop)
	c:RegisterEffect(e1)
	-- ②：这张卡攻击的场合，战斗阶段结束时变成守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c81866673.poscon)
	e2:SetOperation(c81866673.posop)
	c:RegisterEffect(e2)
	-- ③：只在这张卡在墓地存在才有1次，自己在自己抽卡阶段抽卡时，那卡是怪兽的场合，把那1只怪兽给双方确认才能发动。这张卡在墓地存在的场合，那只确认的怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(81866673,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1)
	e3:SetCode(EVENT_DRAW)
	e3:SetCondition(c81866673.spcon)
	e3:SetTarget(c81866673.sptg)
	e3:SetOperation(c81866673.spop)
	c:RegisterEffect(e3)
end
-- 效果①的代价处理函数：检查并解放自己场上1只怪兽。
function c81866673.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否存在除这张卡以外的、可解放的怪兽。
	if chk==0 then return Duel.CheckReleaseGroup(tp,nil,1,e:GetHandler()) end
	-- 让玩家选择自己场上除这张卡以外的1只怪兽。
	local g=Duel.SelectReleaseGroup(tp,nil,1,1,e:GetHandler())
	-- 将选择的怪兽解放作为发动代价。
	Duel.Release(g,REASON_COST)
end
-- 效果①的效果处理函数：使这张卡的攻击力直到回合结束时上升1000。
function c81866673.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 这张卡的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	c:RegisterEffect(e1)
end
-- 效果②的条件检查函数：检查这张卡在本回合是否进行过攻击。
function c81866673.poscon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetAttackedCount()>0
end
-- 效果②的效果处理函数：在战斗阶段结束时，若这张卡是攻击表示则变成守备表示。
function c81866673.posop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsAttackPos() then
		-- 将这张卡转为表侧守备表示。
		Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	end
end
-- 效果③的条件检查函数：检查是否在自己的抽卡阶段由自己抽卡。
function c81866673.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断抽卡玩家是否为自己、当前是否为自己的回合且处于抽卡阶段。
	return ep==tp and Duel.GetTurnPlayer()==tp and Duel.GetCurrentPhase()==PHASE_DRAW
end
-- 过滤函数：检查卡片是否在手卡且可以特殊召唤。
function c81866673.spfilter(c,e,tp)
	return c:IsLocation(LOCATION_HAND) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果③的靶向/发动准备函数：检查是否有空怪兽位及抽到的卡是否包含可特召的怪兽。
function c81866673.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动时，检查自己场上是否有可用的怪兽区域。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and eg:IsExists(c81866673.spfilter,1,nil,e,tp) end
	if eg:GetCount()==1 then
		-- 将抽到的那1张卡给对方玩家确认。
		Duel.ConfirmCards(1-tp,eg)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 将抽到的卡设为效果处理的对象。
		Duel.SetTargetCard(eg)
		-- 设置特殊召唤该卡的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,eg,1,0,0)
	else
		-- 提示玩家选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local g=eg:FilterSelect(tp,c81866673.spfilter,1,1,nil,e,tp)
		-- 将选择的怪兽给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
		-- 洗切自己的手卡。
		Duel.ShuffleHand(tp)
		-- 将选择确认的怪兽设为效果处理的对象。
		Duel.SetTargetCard(g)
		-- 设置特殊召唤该怪兽的操作信息。
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	end
end
-- 效果③的效果处理函数：将确认的怪兽特殊召唤。
function c81866673.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	-- 获取之前确认并设为对象的怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将该怪兽以表侧表示特殊召唤到自己场上。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
