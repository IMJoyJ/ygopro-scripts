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
-- 检查玩家是否可以将卡组顶端1张卡送去墓地
function c36046926.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果检查阶段未通过，则返回
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理函数，执行翻开卡组顶部1~2张卡的操作，并处理植物族怪兽的处理
function c36046926.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 如果玩家无法将卡组顶端1张卡送去墓地，则返回
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 获取玩家卡组中卡的数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if ct==0 then return end
	local ac=1
	if ct>1 then
		-- 提示玩家选择要翻开的卡数量
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(36046926,1))  --"请选择要翻开的数量"
		-- 让玩家宣言要翻开的卡数量（1或2）
		ac=Duel.AnnounceNumber(tp,1,2)
	end
	-- 确认玩家卡组最上方指定数量的卡
	Duel.ConfirmDecktop(tp,ac)
	-- 获取玩家卡组最上方指定数量的卡组成的Group
	local g=Duel.GetDecktopGroup(tp,ac)
	local sg=g:Filter(Card.IsRace,nil,RACE_PLANT)
	if sg:GetCount()>0 then
		-- 禁用后续操作的洗卡检测
		Duel.DisableShuffleCheck()
		-- 将满足条件的植物族怪兽以效果和翻开原因送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
	end
	ac=ac-sg:GetCount()
	if ac>0 then
		-- 让玩家对卡组最上方指定数量的卡进行排序
		Duel.SortDecktop(tp,tp,ac)
		for i=1,ac do
			-- 获取卡组最上方1张卡
			local mg=Duel.GetDecktopGroup(tp,1)
			-- 将指定卡移动到卡组最底部
			Duel.MoveSequence(mg:GetFirst(),SEQ_DECKBOTTOM)
		end
	end
end
-- 判断此卡是否由卡组被翻开送去墓地
function c36046926.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_DECK) and c:IsReason(REASON_REVEAL)
end
-- 设置破坏效果的目标选择函数
function c36046926.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) end
	-- 检查场上是否存在可以成为破坏对象的怪兽
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁操作信息，指定要破坏的怪兽数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果，将目标怪兽破坏
function c36046926.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的破坏对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
