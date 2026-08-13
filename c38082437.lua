--D・テレホン
-- 效果：
-- ①：这张卡得到表示形式的以下效果。
-- ●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子。自己回复出现的数目×100基本分。那之后，可以从自己墓地选持有出现的数目以下的等级的1只「变形斗士」怪兽特殊召唤。
-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「变形斗士」卡送去墓地。剩余用喜欢的顺序回到卡组上面或下面。
function c38082437.initial_effect(c)
	-- ①：这张卡得到表示形式的以下效果。●攻击表示：1回合1次，自己主要阶段才能发动。掷1次骰子。自己回复出现的数目×100基本分。那之后，可以从自己墓地选持有出现的数目以下的等级的1只「变形斗士」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(38082437,0))
	e1:SetCategory(CATEGORY_DICE+CATEGORY_SPECIAL_SUMMON+CATEGORY_RECOVER+CATEGORY_GRAVE_SPSUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c38082437.cona)
	e1:SetTarget(c38082437.tga)
	e1:SetOperation(c38082437.opa)
	c:RegisterEffect(e1)
	-- ●守备表示：1回合1次，自己主要阶段才能发动。掷1次骰子，把出现的数目数量的卡从自己卡组上面翻开。可以从那之中选1张「变形斗士」卡送去墓地。剩余用喜欢的顺序回到卡组上面或下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(38082437,2))
	e2:SetCategory(CATEGORY_DICE+CATEGORY_TOGRAVE+CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c38082437.cond)
	e2:SetTarget(c38082437.tgd)
	e2:SetOperation(c38082437.opd)
	c:RegisterEffect(e2)
end
-- 判定此卡是否处于攻击表示，只有攻击表示时才允许发动这个效果。
function c38082437.cona(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsAttackPos()
end
-- 攻击表示效果的发动时点：允许发动，并登记掷骰子与回复基本分的操作信息，供其他效果检测本次效果包含的动作。
function c38082437.tga(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本效果包含掷骰子，设定由当前玩家投掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
	-- 登记本效果包含回复基本分，回复对象为当前玩家，具体数值在效果处理时确定。
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,0)
end
-- 定义墓地怪兽的特殊召唤条件：必须是「变形斗士」字段怪兽、可以被当前效果特殊召唤、等级不高于骰子点数。
function c38082437.spfilter(c,e,tp,dc)
	return c:IsSetCard(0x26) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:IsLevelBelow(dc)
end
-- 执行攻击表示效果：掷1次骰子，回复点数×100基本分；若回复成功、墓地有符合条件的「变形斗士」怪兽且自己有可用的主要怪兽区，则询问玩家是否从墓地特殊召唤，选择后将该怪兽表侧攻击表示特殊召唤。
function c38082437.opa(e,tp,eg,ep,ev,re,r,rp)
	-- 投掷1次骰子，将点数保存到变量dc。
	local dc=Duel.TossDice(tp,1)
	local rec=dc*100
	-- 从自己墓地筛选出满足特殊召唤条件且不受王家长眠之谷影响的「变形斗士」怪兽组，作为可特殊召唤的候选。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c38082437.spfilter),tp,LOCATION_GRAVE,0,nil,e,tp,dc)
	-- 判断实际回复是否成功、墓地是否有候选怪兽、自己场上是否还有可用怪兽区，三者均满足才继续特殊召唤处理。
	if Duel.Recover(tp,rec,REASON_EFFECT)>0 and g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否从墓地特殊召唤，只有选择‘是’才执行后续特殊召唤。
		and Duel.SelectYesNo(tp,aux.Stringid(38082437,1)) then  --"是否从墓地特殊召唤？"
		-- 中断当前效果处理，使回复与后续特殊召唤分成两段处理，以重新生成时点。
		Duel.BreakEffect()
		-- 显示‘请选择要特殊召唤的卡’的提示信息，用于引导玩家选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local tc=g:Select(tp,1,1,nil):GetFirst()
		-- 将选择的「变形斗士」怪兽以表侧攻击表示特殊召唤到自己的主要怪兽区，不检查召唤条件与苏生限制。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 判定此卡是否处于守备表示，只有守备表示时才允许发动这个效果。
function c38082437.cond(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsDefensePos()
end
-- 守备表示效果的发动时点：检查自己卡组是否有卡，并登记掷骰子的操作信息。
function c38082437.tgd(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己卡组至少有1张卡才能发动。
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>0 end
	-- 登记本效果包含掷骰子，设定由当前玩家投掷1次骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,tp,1)
end
-- 定义翻开卡中可送去墓地的筛选条件：必须是「变形斗士」字段怪兽，且不受‘不能送去墓地’效果限制。
function c38082437.tgfilter(c)
	return c:IsSetCard(0x26) and c:IsAbleToGrave()
end
-- 执行守备表示效果：掷1次骰子，从卡组顶翻开点数数量的卡；若其中有可送墓的「变形斗士」卡，则询问玩家是否选1张送去墓地；剩余卡由玩家选择放回卡组顶或卡组底，放回卡组底时按排序后的顺序逐张移到底部。
function c38082437.opd(e,tp,eg,ep,ev,re,r,rp)
	-- 若自己卡组已没有卡，则无法处理，直接终止效果。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 投掷1次骰子，将点数保存到变量dc。
	local dc=Duel.TossDice(tp,1)
	-- 公开自己卡组最上方dc张卡，供双方确认。
	Duel.ConfirmDecktop(tp,dc)
	-- 取得卡组最上方dc张卡作为一个组对象，用于后续筛选和操作。
	local dg=Duel.GetDecktopGroup(tp,dc)
	local ct=dg:GetCount()
	local g=dg:Filter(c38082437.tgfilter,nil)
	-- 若翻开的卡中有可送去墓地的「变形斗士」卡，则询问玩家是否选择1张送去墓地；选择‘是’才继续送墓处理。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(38082437,3)) then  --"是否选卡送去墓地？"
		-- 显示‘请选择要送去墓地的卡’的提示信息，用于引导玩家选择。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 关闭卡组自动洗牌检测，以免后续移动卡组顺序时系统自动洗切。
		Duel.DisableShuffleCheck()
		-- 将选择的卡以效果原因并作为翻开卡的原因送去墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_REVEAL)
		ct=ct-1
	end
	-- 让玩家选择剩余卡片的放置方式：回到卡组上面或回到卡组下面，记录选项编号。
	local op=Duel.SelectOption(tp,aux.Stringid(38082437,4),aux.Stringid(38082437,5))  --"回到卡组上面/回到卡组下面"
	-- 将剩余卡按玩家选择的顺序排列并置于卡组顶；若之后选择放回卡组下面，则保持该顺序移到底部。
	Duel.SortDecktop(tp,tp,ct)
	if op==0 then return end
	for i=1,ct do
		-- 取得当前卡组最上方的一张卡，准备移动位置。
		local tg=Duel.GetDecktopGroup(tp,1)
		-- 将该卡移动到卡组最底部，实现放回卡组下面的处理。
		Duel.MoveSequence(tg:GetFirst(),SEQ_DECKBOTTOM)
	end
end
