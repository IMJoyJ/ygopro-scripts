--森羅の水先 リーフ
-- 效果：
-- 这张卡召唤成功时，可以从自己卡组上面把最多2张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择场上1只怪兽破坏。
function c36046926.initial_effect(c)
	-- 这张卡召唤成功时，可以从自己卡组上面把最多2张卡翻开。翻开的卡之中有植物族怪兽的场合，那些怪兽全部送去墓地。剩下的卡用喜欢的顺序回到卡组最下面。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(36046926,0))  --"确认卡组"
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c36046926.target)
	e1:SetOperation(c36046926.operation)
	c:RegisterEffect(e1)
	-- 此外，卡组的这张卡被卡的效果翻开送去墓地的场合，可以选择场上1只怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(36046926,2))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCondition(c36046926.descon)
	e2:SetTarget(c36046926.destg)
	e2:SetOperation(c36046926.desop)
	c:RegisterEffect(e2)
end
-- 第一个诱发效果的发动条件判定函数：在效果发动时检查玩家是否至少能将卡组顶端1张卡送去墓地，即卡组中有卡可翻开。
function c36046926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在效果发动合法性判定（chk==0）时，检查玩家tp是否可以把卡组顶端1张卡送去墓地，以此作为“可以翻开最多2张卡”的发动条件。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 第一个效果的处理函数：从自己卡组上面翻开1~2张卡，确认后将其中植物族怪兽全部送去墓地，剩余卡由玩家决定顺序放回卡组最下面。
function c36046926.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理开始时再次检查是否仍至少能从卡组顶送去墓地1张卡，若不能则直接终止处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取自己卡组当前的卡片总数，用于判断可翻开的数量上限。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 向玩家发送选择提示消息，提示内容为“请选择要翻开的数量”，用于后续宣言数字时的界面显示。
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36046926,1))  --"请选择要翻开的数量"
		-- 让玩家在1和2之间宣言一个数字，决定实际翻开的卡牌数量，并赋值给变量ac。
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 确认并展示自己卡组最上方ac张卡，即执行“翻开”动作。
	Duel.ConfirmDecktop(tp,ac)
	-- 获取卡组最上方ac张卡作为一个卡片组g，用于后续筛选和操作。
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 禁用本次后续操作的自动洗牌检查，因为处理中涉及从卡组顶取出卡和将卡放回卡组底，需要保持卡组顺序不被自动洗乱。
		Duel.DisableShuffleCheck()
		-- 将刚才翻开的卡片中所有植物族怪兽以效果原因并附带“翻开”标记（REASON_REVEAL）送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对卡组最上方剩余的ac张卡进行排序，以决定这些卡放回卡组最下面的顺序。
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 获取当前卡组最上方的一张卡，准备将其移动到卡组最下面。
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将这张卡移动到卡组最下面，循环执行即可按玩家排序顺序把所有剩余卡放回卡组底部。
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 第二个效果的发动条件判定函数：确认此卡在发动前所在位置为卡组，且是被卡的效果以“翻开”方式送去墓地，对应“卡组的这张卡被卡的效果翻开送去墓地的场合”。
function c36046926.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 第二个效果的目标选择函数：选择场上1只怪兽作为破坏对象，并设置对应的破坏操作信息。
function c36046926.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 发动条件检查：确认场上双方怪兽区域是否存在至少1只可以被选择为对象的怪兽（所有怪兽均满足）。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送选择提示消息，提示“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方怪兽区域选择1只怪兽作为效果对象，并使其与当前连锁建立关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次处理包含破坏效果，对象为g中的1张卡，供效果处理时及系统检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 第二个效果的处理函数：将效果对象怪兽以效果原因破坏。
function c36046926.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果处理时选择的第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因（REASON_EFFECT）破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
