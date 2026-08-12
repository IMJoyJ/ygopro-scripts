--不死の大軍団
-- 效果：
-- 7星怪兽×2
-- 「不死的大军团」1回合1次也能在自己场上的不死族·6阶的超量怪兽上面重叠来超量召唤。这个卡名的①的效果1回合只能使用1次。
-- ①：对方主要阶段，把这张卡2个超量素材取除，以对方场上1只攻击表示怪兽或者对方墓地1只怪兽为对象才能发动（这张卡只有超量怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个）。那只怪兽作为这张卡的超量素材。
local s,id,o=GetID()
-- 初始化卡片效果：添加超量召唤手续（7星怪兽×2，并允许在自己场上的6阶不死族超量怪兽上面重叠超量召唤），设置苏生限制，并注册①效果（对方主要阶段取除超量素材、以对方怪兽为对象将其作为超量素材的诱发即时效果）。
function s.initial_effect(c)
	aux.AddXyzProcedure(c,nil,7,2,s.ovfilter,aux.Stringid(id,0),2,s.xyzop)  --"是否在6阶不死族超量怪兽上面重叠来超量召唤？"
	c:EnableReviveLimit()
	-- ①：对方主要阶段，把这张卡2个超量素材取除，以对方场上1只攻击表示怪兽或者对方墓地1只怪兽为对象才能发动（这张卡只有超量怪兽在作为超量素材的场合，取除的超量素材数量可以变成1个）。那只怪兽作为这张卡的超量素材。
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
-- 定义重叠超量召唤时目标怪兽需要满足的条件：表侧表示的6阶不死族超量怪兽。
function s.ovfilter(c)
	return c:IsFaceup() and c:IsRank(6) and c:IsRace(RACE_ZOMBIE)
end
-- 重叠超量召唤时的操作：检查本回合是否已用此方法召唤过（1回合1次），并登记回合内持续至结束阶段的誓约标识。
function s.xyzop(e,tp,chk)
	-- 检查本回合是否还没有通过重叠方式超量召唤过（对应1回合1次的限制）。
	if chk==0 then return Duel.GetFlagEffect(tp,id)==0 end
	-- 为玩家登记持续到结束阶段的誓约标识，标记本回合已使用过这种重叠超量召唤方式。
	Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,EFFECT_FLAG_OATH,1)
end
-- ①效果的代价：确定需要取除的超量素材数量（只有超量怪兽在作为素材的场合变为1个，否则2个），检查并取除相应数量的超量素材。
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=c:GetOverlayGroup()
	local minct=2
	-- 判断这张卡的超量素材中是否不存在非超量怪兽（即只有超量怪兽在作为超量素材的场合）。
	if not g:IsExists(aux.NOT(Card.IsType),1,nil,TYPE_XYZ) then
		minct=1
	end
	if chk==0 then return c:CheckRemoveOverlayCard(tp,minct,REASON_COST) end
	c:RemoveOverlayCard(tp,minct,2,REASON_COST)
end
-- 定义可选取对象的怪兽筛选条件：表侧攻击表示的怪兽或者墓地的怪兽，且可以作为超量素材。
function s.filter(c)
	return (c:IsPosition(POS_FACEUP_ATTACK) or c:IsLocation(LOCATION_GRAVE)) and c:IsType(TYPE_MONSTER) and c:IsCanOverlay()
end
-- ①效果的发动条件：对方回合且处于主要阶段。
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前不是自己的回合且处于主要阶段（对方主要阶段）。
	return Duel.GetTurnPlayer()~=tp and Duel.IsMainPhase()
end
-- ①效果的对象选择：确认对方场上·墓地存在可作为对象的怪兽，提示玩家选择作为超量素材的卡，优先从场上选择1只满足条件的怪兽，若选择了墓地的怪兽则设置离场操作信息。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and s.filter(chkc) end
	-- 检查对方场上或墓地是否存在1只可以作为效果对象的满足条件的怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil) end
	-- 向玩家发送选择提示消息，提示「请选择要作为超量素材的卡」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)  --"请选择要作为超量素材的卡"
	-- 让玩家从对方场上（优先）或墓地选择1只满足条件的怪兽作为效果对象。
	local g=aux.SelectTargetFromFieldFirst(tp,s.filter,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil)
	if g:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE) then
		-- 设置操作信息：标记将墓地的对象卡移出墓地（供王家长眠之谷等效果检测）。
		Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	end
end
-- ①效果的处理：确认这张卡和对象怪兽仍与连锁关联、对象不免疫此效果且不受王家长眠之谷影响后，先将对象怪兽原有的超量素材送去墓地，再把该怪兽作为这张卡的超量素材叠放。
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁的效果对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and tc:IsRelateToChain()
		-- 判断对象怪兽不免疫此效果、是怪兽卡、可以作为超量素材，且不受王家长眠之谷的影响。
		and not tc:IsImmuneToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsCanOverlay() and aux.NecroValleyFilter()(tc) then
		local og=tc:GetOverlayGroup()
		if og:GetCount()>0 then
			-- 将对象怪兽原有的超量素材按规则送去墓地。
			Duel.SendtoGrave(og,REASON_RULE)
		end
		-- 将对象怪兽作为这张卡的超量素材叠放。
		Duel.Overlay(c,Group.FromCards(tc))
	end
end
