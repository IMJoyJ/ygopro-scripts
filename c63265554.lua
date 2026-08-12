--パワー・ツール・ブレイバー・ドラゴン
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合才能发动。把这张卡可以装备的最多3张装备魔法卡从自己的卡组·墓地装备（同名卡最多1张）。
-- ②：自己·对方的主要阶段，把这张卡装备的自己场上1张装备魔法卡送去墓地，以场上1只效果怪兽为对象才能发动。那只怪兽的表示形式变更或那个效果直到回合结束时无效。
function c63265554.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合才能发动。把这张卡可以装备的最多3张装备魔法卡从自己的卡组·墓地装备（同名卡最多1张）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(63265554,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,63265554)
	e1:SetTarget(c63265554.eqtg)
	e1:SetOperation(c63265554.eqop)
	c:RegisterEffect(e1)
	-- ②：自己·对方的主要阶段，把这张卡装备的自己场上1张装备魔法卡送去墓地，以场上1只效果怪兽为对象才能发动。那只怪兽的表示形式变更或那个效果直到回合结束时无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(63265554,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DISABLE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1,63265555)
	e2:SetCondition(c63265554.pncon)
	e2:SetCost(c63265554.pncost)
	e2:SetTarget(c63265554.pntg)
	e2:SetOperation(c63265554.pnop)
	c:RegisterEffect(e2)
end
-- 过滤条件：可以装备给该怪兽的、且在场上唯一的非禁用的装备魔法卡
function c63265554.eqfilter(c,ec,tp)
	return c:IsType(TYPE_EQUIP) and c:CheckEquipTarget(ec) and c:CheckUniqueOnField(tp,LOCATION_SZONE) and not c:IsForbidden()
end
-- 效果①的发动准备与合法性检查（检查魔陷区空位及卡组、墓地中是否存在可装备的卡）
function c63265554.eqtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用的魔法与陷阱区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己的卡组或墓地中是否存在至少1张满足装备条件的卡
		and Duel.IsExistingMatchingCard(c63265554.eqfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e:GetHandler(),tp) end
end
-- 效果①的执行：从卡组或墓地选择最多3张卡名不同的装备魔法卡装备给这张卡
function c63265554.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上可用的魔法与陷阱区域空格数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	local c=e:GetHandler()
	if ft<=0 or c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	-- 获取卡组及墓地中所有满足装备条件且不受王家长眠之谷影响的装备魔法卡
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c63265554.eqfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,c,tp)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从可选卡片中选择1到3张（不超过可用魔陷格数）卡名互不相同的卡
	local sg=g:SelectSubGroup(tp,aux.dncheck,false,1,math.min(ft,3))
	if not sg then return end
	local tc=sg:GetFirst()
	while tc do
		-- 将选中的卡作为装备卡装备给这张卡（分步处理）
		Duel.Equip(tp,tc,c,true,true)
		tc=sg:GetNext()
	end
	-- 完成装备卡装备流程，触发相关时点
	Duel.EquipComplete()
end
-- 效果②的发动条件：自己或对方的主要阶段
function c63265554.pncon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前阶段是否为主要阶段1或主要阶段2
	return Duel.GetCurrentPhase()==PHASE_MAIN1 or Duel.GetCurrentPhase()==PHASE_MAIN2
end
-- 过滤条件：自己场上装备的、可以作为cost送去墓地的装备魔法卡
function c63265554.cfilter(c,tp)
	return c:IsType(TYPE_EQUIP) and c:IsType(TYPE_SPELL) and c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- 效果②的发动代价：将这张卡装备的1张装备魔法卡送去墓地
function c63265554.pncost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local cg=c:GetEquipGroup()
	if chk==0 then return cg:IsExists(c63265554.cfilter,1,nil,tp) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=cg:FilterSelect(tp,c63265554.cfilter,1,1,nil,tp)
	-- 将选中的装备卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 过滤条件：场上表侧表示的效果怪兽
function c63265554.pnfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
-- 效果②的发动准备：选择场上1只表侧表示的效果怪兽作为对象
function c63265554.pntg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c63265554.pnfilter(chkc) end
	-- 检查场上是否存在可以作为效果对象的效果怪兽
	if chk==0 then return Duel.IsExistingTarget(c63265554.pnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择场上1只表侧表示的效果怪兽作为效果对象
	Duel.SelectTarget(tp,c63265554.pnfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
end
-- 效果②的执行：让玩家选择将目标怪兽的表示形式变更，或者将其效果直到回合结束时无效
function c63265554.pnop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local b1=tc:IsCanChangePosition()
	-- 检查目标怪兽是否可以被无效化（表侧表示、未被无效的效果怪兽）
	local b2=aux.NegateMonsterFilter(tc)
	local op=-1
	if b1 and b2 then
		-- 让玩家选择“变更表示形式”或“效果无效化”
		op=Duel.SelectOption(tp,aux.Stringid(63265554,2),aux.Stringid(63265554,3))  --"表示形式变更/效果无效"
	elseif b1 then
		op=0
	elseif b2 then
		op=1
	end
	if op==0 then
		-- 变更目标怪兽的表示形式（表侧守备表示与表侧攻击表示互相转换）
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	elseif op==1 then
		if tc:IsCanBeDisabledByEffect(e) then
			-- 使与目标怪兽相关的连锁中已发动的效果无效化
			Duel.NegateRelatedChain(tc,RESET_TURN_SET)
			-- 那个效果直到回合结束时无效。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_DISABLE)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
			tc:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_DISABLE_EFFECT)
			e2:SetValue(RESET_TURN_SET)
			tc:RegisterEffect(e2)
		end
	end
end
