--カード・アドバンス
-- 效果：
-- ①：从自己卡组上面把最多5张卡确认，用喜欢的顺序回到卡组上面。这个回合自己在通常召唤外加上只有1次可以把1只怪兽上级召唤。
function c52112003.initial_effect(c)
	-- 注册卡片上移的发动效果，允许自由连锁时点发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c52112003.target)
	e1:SetOperation(c52112003.activate)
	c:RegisterEffect(e1)
end
-- 判断是否满足发动条件：卡组有卡、可以通常召唤、可以额外召唤、未使用过此效果
function c52112003.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否有卡
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0
		-- 检查玩家是否可以通常召唤
		and Duel.IsPlayerCanSummon(tp) and Duel.IsPlayerCanAdditionalSummon(tp)
		-- 检查玩家是否可以额外召唤
		and Duel.GetFlagEffect(tp,52112003)==0 end
end
-- 处理卡片上移的效果发动，包括确认卡组顶部的卡并排序，以及注册额外召唤和盖放次数的效果
function c52112003.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 计算最多可确认的卡数（不超过5张）
	local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct>0 then
		local t={}
		for i=1,ct do
			t[i]=i
		end
		local ac=1
		if ct>1 then
			-- 提示玩家选择要确认的卡的数量
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(52112003,1))  --"请选择要确认的卡的数量"
			-- 让玩家宣言要确认的卡数
			ac=Duel.AnnounceNumber(tp,table.unpack(t))
		end
		-- 对玩家卡组顶部的指定数量卡进行排序
		Duel.SortDecktop(tp,tp,ac)
	end
	-- 如果此效果已使用过则不重复注册
	if Duel.GetFlagEffect(tp,52112003)~=0 then return end
	-- 为玩家注册额外召唤次数的效果，使玩家在本回合可以额外召唤一次上级召唤的怪兽
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(52112003,0))  --"使用「卡片上移」的效果召唤"
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetTargetRange(LOCATION_HAND,0)
	e1:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	-- 设置效果目标为等级5以上的怪兽
	e1:SetTarget(aux.TargetBoolFunction(Card.IsLevelAbove,5))
	e1:SetValue(0x1)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将额外召唤次数效果注册给玩家
	Duel.RegisterEffect(e1,tp)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_EXTRA_SET_COUNT)
	-- 将额外盖放次数效果注册给玩家
	Duel.RegisterEffect(e2,tp)
	-- 注册标识效果，标记此回合已使用过卡片上移的效果
	Duel.RegisterFlagEffect(tp,52112003,RESET_PHASE+PHASE_END,0,1)
end
