--The Undying Legion
-- 效果：
-- 7星怪兽×2
-- 「不死者军团」1回合1次也能在自己场上的6阶不死族超量怪兽上面重叠来超量召唤。
-- 对方主要阶段（诱发即时效果）：可以把这张卡2个超量素材取除（这张卡只有超量怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个），以对方场上1只表侧攻击表示怪兽或者对方墓地1只怪兽为对象；那只怪兽作为这张卡的超量素材。
-- 「不死者军团」的这个效果1回合只能使用1次。
local s,id,o=GetID()
-- 初始化卡片效果主函数，注册XYZ召唤手续（支持7星怪兽叠放或在6阶不死族超量怪兽上重叠超量召唤）以及对方主要阶段抢夺对方场上表侧攻击表示怪兽或墓地怪兽作为超量素材的诱发即时效果。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在6阶不死族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- 对方主要阶段（诱发即时效果）：可以把这张卡2个超量素材取除（这张卡只有超量怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个），以对方场上1只表侧攻击表示怪兽或者对方墓地1只怪兽为对象；那只怪兽作为这张卡的超量素材。「不死者军团」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"作为超量素材"
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- XYZ召唤特殊重叠的手续过滤条件：必须是场上表侧表示、6阶且是不死族的怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(6) and c:IsRace(RACE_ZOMBIE)
end
-- 超量召唤手续的操作函数：检查本回合是否已经使用过该方式进行过超量召唤，若没有则标记本回合已使用。
function s.xyzop(e,tp,chk)
	-- 检查当前回合玩家是否本回合尚未通过重叠该卡进行超量召唤。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 在全局环境中为玩家注册一回合一次的超量召唤誓约标记，回合结束时重置。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- 抢夺效果的Cost函数：计算需要移去的超量素材数量（如果素材中全部为超量怪兽，则可以变成1个，否则为2个），并取除对应数量 of 超量素材作为代价。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local minct=2
	-- 检查当前持有的超量素材集合中，是否不存在非超量怪兽的卡片（即全部超量素材均是超量怪兽）。
	if not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_XYZ) then
		minct=1
	end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,minct,REASON_COST) end
	c:RemoveOverlayCard(tp,minct,2,REASON_COST)
end
-- 抢夺对象的过滤条件：必须是表侧攻击表示怪兽或墓地中的怪兽，是怪兽卡且能够作为超量素材重叠。
function s.filter(c)
	return (c:IsPosition(POS_FACEUP_ATTACK) or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- 抢夺效果的发动条件：必须在对方的主要阶段。
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 确认当前回合玩家不是自己，并且当前是主要阶段。
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- 抢夺效果的Target函数：在对方场上或墓地选择1只满足条件的怪兽作为效果对象，若是墓地怪兽则设置送离墓地的操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 效果发动时的合法性检查：检查对方场上或墓地是否存在至少1只可成为效果对象的符合条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 提示玩家选择要作为超量素材的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 优先从对方场上（其次是墓地）选择1只满足条件的怪兽作为效果的对象。
	local g=aux.SelectTargetFromFieldFirst(tp,s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 如果选择的目标在墓地，则设置操作信息：预计将1张卡送离墓地。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- 抢夺效果的Operation函数：将选定的目标怪兽原本所持有的超量素材送去墓地，然后将目标怪兽作为超量素材重叠在这张卡下方。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中选为效果对象的卡片。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain()
		-- 确保目标怪兽不免疫此卡效果、是一张怪兽卡、可以被重叠为素材，且不受王家长眠之谷的影响。
		and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() and aux.NecroValleyFilter()(tc) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 如果被抢夺的怪兽身上有超量素材，则通过规则将这些超量素材全部送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将目标怪兽作为此卡的超量素材重叠在下方。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
