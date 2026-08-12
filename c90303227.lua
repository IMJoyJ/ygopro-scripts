--K9－EX “Werewolf”
-- 效果：
-- 9星怪兽×2
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
-- ②：对方把效果发动时，可以把这张卡1个超量素材取除，发动回合的以下效果发动。
-- ●自己回合：对方的场上以及墓地的卡各最多1张除外。
-- ●对方回合：把对方手卡确认，选那之内的1张直到结束阶段表侧除外。
local s,id,o=GetID()
-- 初始化卡片效果，注册XYZ召唤手续、追加攻击次数的永续效果以及对方发动效果时取除素材除外卡片的诱发即时效果
function s.initial_effect(c)
	-- 添加XYZ召唤手续：9星怪兽2只
	aux.AddXyzProcedure(c,nil,9,2)
	c:EnableReviveLimit()
	-- ①：持有超量素材的这张卡在同1次的战斗阶段中可以作出最多有那个数量的攻击。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetCondition(s.racon)
	e1:SetValue(s.raval)
	c:RegisterEffect(e1)
	-- ②：对方把效果发动时，可以把这张卡1个超量素材取除，发动回合的以下效果发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.rmcon)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
end
-- 追加攻击效果的启用条件：这张卡持有超量素材（由于追加攻击次数为素材数-1，故需素材数大于1）
function s.racon(e)
	return e:GetHandler():GetOverlayCount()>1
end
-- 计算追加攻击的次数：超量素材数量减1
function s.raval(e,c)
	return e:GetHandler():GetOverlayCount()-1
end
-- 除外效果的发动条件：对方把效果发动时
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 除外效果的发动代价：取除这张卡的1个超量素材
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- 除外效果的发动准备：根据当前回合玩家进行可行性检查并设置对应的除外操作信息
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 判断当前是否为自己回合
		if Duel.GetTurnPlayer()==tp then
			-- 检查对方场上或墓地是否存在可以除外的卡
			return Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD+LOCATION_GRAVE,1,nil)
		else
			-- 检查对方手牌数量是否不为0
			return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)~=0
				-- 并且对方手牌中存在可以除外的卡
				and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_HAND,1,nil)
		end
	end
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 设置操作信息：从对方的场上或墓地除外卡片
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_ONFIELD+LOCATION_GRAVE)
	else
		-- 设置操作信息：从对方手牌除外卡片
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
	end
end
-- 限制选择的卡片组中，来自场上的卡和来自墓地的卡各最多1张
function s.gcheck(g)
	return g:FilterCount(Card.IsLocation,nil,LOCATION_ONFIELD)<=1
		and g:FilterCount(Card.IsLocation,nil,LOCATION_GRAVE)<=1
end
-- 除外效果的处理：根据当前回合玩家执行对应的除外操作（自己回合除外场上/墓地各最多1张，对方回合确认手牌并暂时除外1张）
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为自己回合
	if Duel.GetTurnPlayer()==tp then
		-- 获取对方场上可以除外的卡片组
		local g1=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_ONFIELD,nil)
		-- 获取对方墓地可以除外且不受王家之谷影响的卡片组
		local g2=Duel.GetMatchingGroup(aux.NecroValleyFilter(Card.IsAbleToRemove),tp,0,LOCATION_GRAVE,nil)
		g1:Merge(g2)
		if g1:GetCount()==0 then return end
		-- 设置额外的卡片选择检查函数，限制场上和墓地各最多选1张
		aux.GCheckAdditional=s.gcheck
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 让玩家从合并后的卡片组中选择1到2张卡（受gcheck限制，场上和墓地各最多1张）
		local sg=g1:SelectSubGroup(tp,aux.TRUE,false,1,2)
		-- 重置额外的卡片选择检查函数
		aux.GCheckAdditional=nil
		-- 给选中的卡片显示被选择的动画效果
		Duel.HintSelection(sg)
		-- 将选中的卡片表侧表示除外
		Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
	else
		-- 获取对方的全部手牌
		local g0=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
		-- 让自己确认对方的全部手牌
		Duel.ConfirmCards(tp,g0)
		-- 获取对方手牌中可以除外的卡片组
		local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
		if g:GetCount()>0 then
			-- 提示玩家选择要除外的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local sg=g:Select(tp,1,1,nil)
			local tc=sg:GetFirst()
			-- 将选中的手牌表侧表示除外
			Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
			-- ●对方回合：把对方手卡确认，选那之内的1张直到结束阶段表侧除外。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE+PHASE_END)
			e1:SetCountLimit(1)
			e1:SetReset(RESET_PHASE+PHASE_END)
			e1:SetLabelObject(tc)
			e1:SetCondition(s.retcon)
			e1:SetOperation(s.retop)
			-- 注册在回合结束时将除外卡片加回手牌的延迟效果
			Duel.RegisterEffect(e1,tp)
		end
		-- 洗切对方的手牌
		Duel.ShuffleHand(1-tp)
	end
end
-- 检查被除外的卡片是否仍带有标记，若无则重置效果，若有则允许在结束阶段返回手牌
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(id)==0 then
		e:Reset()
		return false
	else
		return true
	end
end
-- 结束阶段将暂时除外的卡片送回对方手牌
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将暂时除外的卡片送回对方手牌
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
