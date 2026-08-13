--カード・アドバンス
-- 效果：
-- ①：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。这个回合自己在通常召唤外加上只有1次可以把1只怪兽上级召唤。
function c52112003.initial_effect(c)
	-- ①：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。这个回合自己在通常召唤外加上只有1次可以把1只怪兽上级召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52112003.target)
	e1:SetOperation(c52112003.activate)
	c:RegisterEffect(e1)
end
-- 发动条件判定：自卡组有卡、自己可通常召唤且有额外召唤次数、本回合未使用过本卡效果时才可发动。
function c52112003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有卡（至少1张），作为发动条件之一。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- 检查自己可以进行通常召唤且拥有通常召唤外的追加召唤次数（即额外召唤许可）。
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查本回合是否已经使用过同名效果（通过flag 52112003判断），没有才可发动（一回合一次）。
		and Duel.GetFlagEffect(tp,52112003)==0 end
end
-- 效果处理：先确认卡组顶最多5张并按喜欢顺序放回；若本回合尚未用过追加召唤效果，则赋予本回合1次追加上级召唤（含里侧盖放）的机会。
function c52112003.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 取5和卡组数量中的较小值，确定最多可确认的卡数。
	local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct>0 then
		local t={}
		for i=1,ct do
			t[i]=i
		end
		local ac=1
		if ct>1 then
			-- 提示玩家选择要确认的卡的数量，显示“请选择要确认的卡的数量”。
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52112003,1))  --"请选择要确认的卡的数量"
			-- 让玩家宣言一个数字（1到ct），作为实际确认的卡数。
			ac=Duel.AnnounceNumber(tp,table.unpack(t))
		end
		-- 让玩家对卡组最上方ac张卡进行排序，按喜欢顺序放回卡组上面。
		Duel.SortDecktop(tp,tp,ac)
	end
	-- 检查本回合是否已经使用过本次追加召唤效果，若已使用则不再重复赋予（防止重复处理）。
	if Duel.GetFlagEffect(tp,52112003)~=0 then return end
	-- 这个回合自己在通常召唤外加上只有1次可以把1只怪兽上级召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(52112003,0))  --"使用「卡片上移」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 限定此次追加的通常召唤只能用于手牌中等级5以上的怪兽（即上级召唤）。
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将追加通常召唤次数效果注册给玩家，使本回合可以额外进行1次通常召唤。
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 追加盖放（里侧守备表示通常召唤）次数效果注册给玩家，使本回合也可以用里侧守备表示进行上级召唤。
	Duel.RegisterEffect(e2,tp)
	-- 给玩家注册回合标记，防止本回合再次使用本卡追加召唤的效果。
	Duel.RegisterFlagEffect(tp,52112003,RESET_PHASE+PHASE_END,0,1)
end
