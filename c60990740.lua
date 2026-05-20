--絶対王 バック・ジャック
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方回合把墓地的这张卡除外才能发动。自己卡组最上面的卡翻开，那张卡是通常陷阱卡的场合，在自己场上盖放。不是的场合，那张卡送去墓地。这个效果盖放的卡在盖放的回合也能发动。
-- ②：这张卡被送去墓地的场合才能发动。从自己卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
function c60990740.initial_effect(c)
	-- ①：对方回合把墓地的这张卡除外才能发动。自己卡组最上面的卡翻开，那张卡是通常陷阱卡的场合，在自己场上盖放。不是的场合，那张卡送去墓地。这个效果盖放的卡在盖放的回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,60990740)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCondition(c60990740.condition)
	-- 把墓地的这张卡除外作为发动的代价
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c60990740.target)
	e1:SetOperation(c60990740.operation)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合才能发动。从自己卡组上面把3张卡确认，用喜欢的顺序回到卡组上面。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,60990741)
	e2:SetTarget(c60990740.sdtg)
	e2:SetOperation(c60990740.sdop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数
function c60990740.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合是否为对方回合
	return Duel.GetTurnPlayer()~=tp
end
-- ①效果的发动准备与合法性检测函数
function c60990740.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己是否能将卡组顶端的卡送去墓地
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1)
		-- 且检查自己的魔法与陷阱区域是否有空位
		and Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且检查自己是否可以进行盖放
		and Duel.IsPlayerCanSSet(tp) end
end
-- ①效果的效果处理（翻开卡组顶端，是陷阱卡则盖放且本回合可发动，否则送去墓地）
function c60990740.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果不能将卡组顶端的卡送去墓地，则不处理效果
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 翻开并确认自己卡组最上面的一张卡
	Duel.ConfirmDecktop(tp,1)
	-- 获取自己卡组最上面的一张卡
	local tc=Duel.GetDecktopGroup(tp,1):GetFirst()
	-- 设置接下来的操作不触发系统自动洗牌检测
	Duel.DisableShuffleCheck()
	-- 如果该卡是陷阱卡，且成功在自己场上盖放
	if tc:GetType()==TYPE_TRAP and Duel.SSet(tp,tc)~=0 then
		-- 这个效果盖放的卡在盖放的回合也能发动。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(60990740,0))  --"适用「绝对王 J革命」的效果来发动"
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_TRAP_ACT_IN_SET_TURN)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	else
		-- 如果不是陷阱卡，则将该卡作为效果和翻开原因送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	end
end
-- ②效果的发动准备与合法性检测函数
function c60990740.sdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段，检查自己卡组的卡片数量是否在3张以上
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
-- ②效果的效果处理（确认卡组顶端3张卡并排序）
function c60990740.sdop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己卡组最上方的3张卡，并用喜欢的顺序放回卡组最上方
	Duel.SortDecktop(tp,tp,3)
end
