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
	-- 添加连接召唤手续，要求使用非衍生物的怪兽作为连接素材，最少2个
	aux.AddLinkProcedure(c,aux.NOT(aux.FilterBoolFunction(Card.IsLinkType,TYPE_TOKEN)),2)
	-- ①：这张卡连接召唤成功的场合才能发动。
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
-- 判断此卡是否为连接召唤成功
function c2411269.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 检索双方墓地的龙族、恐龙族、海龙族、幻龙族怪兽，若存在且满足条件则可以发动
function c2411269.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检索双方墓地的龙族、恐龙族、海龙族、幻龙族怪兽组成卡片组
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	-- 检查是否满足发动条件：墓地存在种族怪兽且海龙族数量少于总种族数或对方场上存在表侧表示怪兽
	if chk==0 then return #g>0 and (g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)<#g or Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)) end
	-- 设置伤害效果信息，对对方造成龙族数量×100的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,g:FilterCount(Card.IsRace,nil,RACE_DRAGON)*100)
	-- 设置回复效果信息，对自己回复幻龙族数量×400的基本分
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,g:FilterCount(Card.IsRace,nil,RACE_WYRM)*400)
end
-- 处理效果的执行逻辑，根据墓地种族怪兽数量分别执行对应效果
function c2411269.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次检索双方墓地的龙族、恐龙族、海龙族、幻龙族怪兽组成卡片组
	local g=Duel.GetMatchingGroup(Card.IsRace,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,RACE_DRAGON+RACE_DINOSAUR+RACE_SEASERPENT+RACE_WYRM)
	if #g==0 then return end
	local c=e:GetHandler()
	local ct1=g:FilterCount(Card.IsRace,nil,RACE_DRAGON)
	local ct2=g:FilterCount(Card.IsRace,nil,RACE_DINOSAUR)
	local ct3=g:FilterCount(Card.IsRace,nil,RACE_SEASERPENT)
	local ct4=g:FilterCount(Card.IsRace,nil,RACE_WYRM)
	if ct1>0 then
		-- 对对方造成龙族数量×100的伤害
		Duel.Damage(1-tp,ct1*100,REASON_EFFECT)
	end
	if ct2>0 and c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 若已执行龙族效果则中断当前效果处理流程
		if ct1>0 then Duel.BreakEffect() end
		-- ●恐龙族：这张卡的攻击力上升那个数量×200。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(ct2*200)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
	-- 检索对方场上所有表侧表示怪兽组成卡片组
	local og=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
	if ct3>0 and #og>0 then
		-- 若已执行龙族或恐龙族效果则中断当前效果处理流程
		if ct1>0 or ct2>0 then Duel.BreakEffect() end
		-- 遍历对方场上的所有表侧表示怪兽
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
		-- 若已执行龙族或恐龙族或海龙族效果则中断当前效果处理流程
		if ct1>0 or ct2>0 or ct3>0 then Duel.BreakEffect() end
		-- 对自己回复幻龙族数量×400的基本分
		Duel.Recover(tp,ct4*400,REASON_EFFECT)
	end
end
