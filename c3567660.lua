--リンク・バック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以额外怪兽区域1只自己的连接怪兽为对象才能发动。那只自己怪兽的位置向作为那所连接区的自己的主要怪兽区域移动。那之后，可以把那只怪兽的连接标记数量的卡从自己卡组上面送去墓地。
function c3567660.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以额外怪兽区域1只自己的连接怪兽为对象才能发动。那只自己怪兽的位置向作为那所连接区的自己的主要怪兽区域移动。那之后，可以把那只怪兽的连接标记数量的卡从自己卡组上面送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,3567660+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c3567660.seqtg)
	e1:SetOperation(c3567660.seqop)
	c:RegisterEffect(e1)
end
-- 定义可选择对象怪兽的条件：必须是表侧表示、连接怪兽、位于额外怪兽区域（序号>=5），并且该怪兽的连接箭头指向的自己的主要怪兽区域存在空格。
function c3567660.filter(c,tp)
	if not (c:IsFaceup() and c:IsType(TYPE_LINK) and c:GetSequence()>=5) then return false end
	local zone=bit.band(c:GetLinkedZone(),0x1f)
	-- 检查该连接怪兽所连接的主要怪兽区域中是否有可用空格作为移动目的地。
	return Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0
end
-- 发动效果的发动阶段处理：负责判定是否存在满足条件的取对象目标，并提示玩家选择1只符合条件的连接怪兽作为效果对象。
function c3567660.seqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c3567660.filter(chkc,tp) end
	-- 效果发动确认（chk==0）时，检查自己额外怪兽区域是否存在1只表侧表示连接怪兽且其连接区域有空位，以满足发动条件。
	if chk==0 then return Duel.IsExistingTarget(c3567660.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
	-- 向操作玩家显示选择提示消息，内容为请选择要移动位置的卡。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(3567660,1))  --"请选择要移动位置的卡"
	-- 让玩家从符合条件的怪兽中选择1只作为效果对象，并将其登记为当前连锁的取对象目标。
	Duel.SelectTarget(tp,c3567660.filter,tp,LOCATION_MZONE,0,1,1,nil,tp)
end
-- 效果处理阶段：取得对象怪兽，确认其仍与效果关联且在自己场上；若其连接区域有空位，则让玩家选择移动到的格子并移动，之后可选追加从卡组顶送墓。
function c3567660.seqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果处理时要操作的那1张对象卡，即发动时选择的连接怪兽。
	local tc=Duel.GetFirstTarget()
	if not (tc:IsRelateToEffect(e) and tc:IsControler(tp)) then return end
	local zone=bit.band(tc:GetLinkedZone(tp),0x1f)
	-- 判断该连接怪兽所连接的主要怪兽区域中是否仍有可用格子，只有存在空格时才能执行移动操作。
	if Duel.GetLocationCount(tp,LOCATION_MZONE,PLAYER_NONE,0,zone)>0 then
		local flag=bit.bxor(zone,0xff)
		-- 显示“请选择要移动到的位置”的提示信息，引导玩家选择移动目标区域。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)  --"请选择要移动到的位置"
		-- 让玩家从可用主要怪兽区域空格中选择1个格子作为移动目的地，返回该格子的位置标记。
		local s=Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,flag)
		local nseq=0
		if s==1 then nseq=0
		elseif s==2 then nseq=1
		elseif s==4 then nseq=2
		elseif s==8 then nseq=3
		else nseq=4 end
		-- 将对象连接怪兽移动到玩家选定的主要怪兽区域格子，即改变其场上所在的区域位置。
		Duel.MoveSequence(tc,nseq)
		local ct=tc:GetLink()
		-- 确认玩家是否选择追加处理：先检查能否把卡组顶端相当于连接标记数量的卡送去墓地，如果可以则询问玩家是否发动该追加送墓。
		if Duel.IsPlayerCanDiscardDeck(tp,ct) and Duel.SelectYesNo(tp,aux.Stringid(3567660,2)) then  --"是否从卡组把卡送去墓地？"
			-- 中断当前效果，使之后执行的送墓处理与之前的移动处理被分到不同时点，避免造成错时点。
			Duel.BreakEffect()
			-- 将玩家卡组顶端ct张卡（即该连接怪兽的连接标记数量）以效果原因送去墓地。
			Duel.DiscardDeck(tp,ct,REASON_EFFECT)
		end
	end
end
