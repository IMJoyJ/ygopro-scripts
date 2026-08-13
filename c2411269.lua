--竜絶蘭
-- 效果：
-- 衍生物以外的怪兽2只以上
-- 这个卡名的效果1回合只能使用1次。
-- ①：这张卡连接召唤成功的场合才能发动。双方墓地的怪兽的种族和那数量对应的以下效果适用。
-- ●龙族：给与对方那个数量×100伤害。
-- ●恐龙族：这张卡的攻击力上升那个数量×200。
-- ●海龙族：对方场上的全部怪兽的攻击力下降那个数量×300。
-- ●幻龙族：自己回复那个数量×400基本分。
function c2411269.initial_effect(c)
	c:EnableReviveLimit()
	-- 为这张卡添加连接召唤手续：使用衍生物以外的怪兽2只作为连接素材（对应召唤条件‘衍生物以外的怪兽2只以上’）。
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2)
	-- 对应效果原文：‘这个卡名的效果1回合只能使用1次。①：这张卡连接召唤成功的场合才能发动。双方墓地的怪兽的种族和那数量对应的以下效果适用。●龙族：给与对方那个数量×100伤害。●恐龙族：这张卡的攻击力上升那个数量×200。●海龙族：对方场上的全部怪兽的攻击力下降那个数量×300。●幻龙族：自己回复那个数量×400基本分。’
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(2411269,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_RECOVER+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,2411269)
	e1:SetCondition(c2411269.condition)
	e1:SetTarget(c2411269.target)
	e1:SetOperation(c2411269.operation)
	c:RegisterEffect(e1)
end
-- 效果发动条件判断：确认这张卡是以连接召唤的方式特殊召唤成功。
function c2411269.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果发动阶段的合法性判定与操作信息设置：获取双方墓地中的龙族/恐龙族/海龙族/幻龙族怪兽；若墓地没有这些种族的怪兽则不能发动；若墓地只有海龙族怪兽且对方场上没有表侧表示怪兽，则因海龙族效果无法适用而不能发动；通过后设置将造成的龙族伤害和幻龙族回复的操作信息。
function c2411269.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取双方墓地中所有种族为龙族、恐龙族、海龙族或幻龙族的怪兽集合，用于后续按种族计数。
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	-- 检查发动条件：墓地存在至少1只符合条件种族中的怪兽，并且若墓地中的怪兽全是海龙族，则对方场上必须存在表侧表示怪兽，否则无法适用海龙族效果，不能发动。
	if chk==0 then return #g>0 and (g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)<#g or Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)) end
	-- 设置操作信息：预告将给与对方‘墓地龙族怪兽数×100’的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:FilterCount(Card.IsRace,nil,RACE_DRAGON)*100)
	-- 设置操作信息：预告将让自己回复‘墓地幻龙族怪兽数×400’的基本分。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:FilterCount(Card.IsRace,nil,RACE_WYRM)*400)
end
-- 效果处理函数：重新获取双方墓地四种族怪兽并计数，然后按顺序处理：龙族→给对方伤害；恐龙族→这张卡攻击力上升；海龙族→对方全场怪兽攻击力下降；幻龙族→自己回复LP；若之前已有其他种族的适用，则先调用BreakEffect使该次处理与其他处理分开。
function c2411269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取双方墓地中龙族、恐龙族、海龙族、幻龙族的怪兽集合。
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	if #g==0 then return end
	local c=e:GetHandler()
	local ct1=g:FilterCount(Card.IsRace,nil,RACE_DRAGON)
	local ct2=g:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)
	local ct3=g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)
	local ct4=g:FilterCount(Card.IsRace,nil,RACE_WYRM)
	if ct1>0 then
		-- 龙族效果：给对方造成‘墓地龙族怪兽数量×100’的伤害。
		Duel.Damage(1-tp,ct1*100,REASON_EFFECT)
	end
	if ct2>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 伤害处理完成后调用Duel.BreakEffect()，使后续的恐龙族攻击力上升效果作为独立处理，避免错过时点。
		if ct1>0 then Duel.BreakEffect() end
		-- ●恐龙族：这张卡的攻击力上升那个数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct2*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 获取对方场上的全部表侧表示怪兽，用于海龙族效果的攻击力下降对象。
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if ct3>0 and #og>0 then
		-- 若此前已处理过龙族伤害或恐龙族攻击力上升，则调用Duel.BreakEffect()中断，使海龙族效果成为独立处理。
		if ct1>0 or ct2>0 then Duel.BreakEffect() end
		-- 遍历对方场上的每只表侧表示怪兽。
		for tc in aux.Next(og) do
			-- ●海龙族：对方场上的全部怪兽的攻击力下降那个数量×300。
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_UPDATE_ATTACK)
			e2:SetValue(ct3*-300)
			e2:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e2)
		end
	end
	if ct4>0 then
		-- 若此前已处理过龙族伤害、恐龙族攻击力上升或海龙族攻击力下降，则调用Duel.BreakEffect()中断，使幻龙族回复效果成为独立处理。
		if ct1>0 or ct2>0 or ct3>0 then Duel.BreakEffect() end
		-- 幻龙族效果：自己回复‘墓地幻龙族怪兽数量×400’基本分。
		Duel.Recover(tp,ct4*400,REASON_EFFECT)
	end
end
