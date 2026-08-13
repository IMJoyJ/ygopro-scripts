--森羅の影胞子 ストール
-- 效果：
-- 这张卡反转时，可以从自己卡组上面把最多5张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择场上1张魔法·陷阱卡破坏。
function c99641328.initial_effect(c)
	-- 这张卡反转时，可以从自己卡组上面把最多5张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99641328,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_FLIP)
	e1:SetTarget(c99641328.target)
	e1:SetOperation(c99641328.operation)
	c:RegisterEffect(e1)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择场上1张魔法·陷阱卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99641328,2))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c99641328.descon)
	e2:SetTarget(c99641328.destg)
	e2:SetOperation(c99641328.desop)
	c:RegisterEffect(e2)
end
-- 定义第一个效果的发动时点检测函数：在效果发动时检查是否满足翻卡组的基本条件，即自己能否将卡组顶的卡送去墓地。
function c99641328.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动条件判定：若自己不能将卡组顶1张卡送去墓地，则无法发动第一个效果。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 定义第一个效果的处理函数：先检查玩家能否从卡组顶送墓，若能则统计卡组数量并限制最多5张，构造可选数量列表供玩家选择要翻开的张数。
function c99641328.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 若玩家不能从卡组顶将卡送去墓地，则效果处理直接终止。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 取得玩家卡组当前的卡片数量，用于决定最多可以翻开多少张卡。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	if ct>5 then ct=5 end
	local t={}
	for i=1,ct do t[i]=i end
	-- 向玩家显示“请选择要翻开的数量”的提示，将选择消息写入缓存供后续选择使用。
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(99641328,1))  --"请选择要翻开的数量"
	-- 让玩家宣言一个数字（要翻开的卡数），并将宣言结果存入变量ac。
	local ac=Duel.AnnounceNumber(tp,table.unpack(t))
	-- 确认玩家卡组最上方ac张卡，展示给双方确认。
	Duel.ConfirmDecktop(tp,ac)
	-- 取得玩家卡组最上方ac张卡的集合，用于后续筛选植物族怪兽。
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 禁用下一次操作后的自动洗切卡组检测，因为随后会从卡组顶送墓或移动卡牌，避免不必要的洗牌。
		Duel.DisableShuffleCheck()
		-- 将翻开的卡中所有植物族怪兽送去墓地，送入墓地的原因为效果原因加上翻开原因（对应森罗的翻开处理）。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对自己卡组最上方剩余的ac张卡按喜欢的顺序进行排序，先选择的卡在最上面。
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 取得卡组最上方1张卡，用于逐个移动到卡组最下面。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将当前取到的卡移动到卡组最下面，从而按照排序后的顺序把剩余卡全部放回卡组底端。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 定义第二个效果的发动条件函数：判断这张卡被效果翻开并送入墓地时（之前所在位置为卡组且送入墓地的原因为翻开），满足条件才能发动。
function c99641328.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 定义破坏对象筛选函数：选择对象为场上的魔法·陷阱卡（魔法或陷阱类型）。
function c99641328.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义第二个效果的目标选择函数：确认场上存在可作为对象的魔法·陷阱卡，若满足则让玩家选择1张并登记破坏信息。
function c99641328.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c99641328.desfilter(chkc) end
	-- 目标选择阶段判定：场上是否存在1张可以被选择的魔法·陷阱卡，若不存在则不能发动第二个效果。
	if chk==0 then return Duel.IsExistingTarget(c99641328.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 向玩家显示“请选择要破坏的卡”的提示，将选择消息写入缓存。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上的魔法·陷阱卡中选择1张作为效果对象，并自动设置为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c99641328.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 登记本次连锁要破坏的对象和数量（1张）到操作信息中，供后续破坏处理使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义第二个效果的处理函数：取得效果对象，若对象仍然能适用此效果则将其破坏。
function c99641328.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取回第二个效果发动时选择的目标卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
