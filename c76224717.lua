--アドバンス・ゾーン
-- 效果：
-- 1回合1次，自己对怪兽的上级召唤成功的回合的结束阶段时才能发动。这个回合自己为上级召唤而解放的怪兽数量的以下效果适用。
-- ●1只以上：选对方场上盖放的1张卡破坏。
-- ●2只以上：从卡组抽1张卡。
-- ●3只以上：选自己墓地1只怪兽加入手卡。
function c76224717.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 1回合1次，自己对怪兽的上级召唤成功的回合的结束阶段时才能发动。这个回合自己为上级召唤而解放的怪兽数量的以下效果适用。●1只以上：选对方场上盖放的1张卡破坏。●2只以上：从卡组抽1张卡。●3只以上：选自己墓地1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(76224717,0))  --"破坏对方场上1张盖卡"
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c76224717.target)
	e2:SetOperation(c76224717.operation)
	c:RegisterEffect(e2)
	if not c76224717.global_check then
		c76224717.global_check=true
		c76224717[0]=0
		c76224717[1]=0
		-- 这个回合自己为上级召唤而解放的怪兽数量
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_SUMMON_SUCCESS)
		ge1:SetOperation(c76224717.checkop)
		-- 注册全局效果：在怪兽表侧表示上级召唤成功时，记录上级召唤所解放的怪兽数量。
		Duel.RegisterEffect(ge1,0)
		-- 这个回合自己为上级召唤而解放的怪兽数量
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_MSET)
		ge2:SetOperation(c76224717.checkop)
		-- 注册全局效果：在怪兽里侧表示上级召唤（放置）成功时，记录上级召唤所解放的怪兽数量。
		Duel.RegisterEffect(ge2,0)
		-- 这个回合自己为上级召唤而解放的怪兽数量
		local ge3=Effect.CreateEffect(c)
		ge3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge3:SetCode(EVENT_PHASE_START+PHASE_DRAW)
		ge3:SetOperation(c76224717.clear)
		-- 注册全局效果：在每个回合的抽卡阶段开始时，清空双方玩家该回合上级召唤解放的怪兽数量记录。
		Duel.RegisterEffect(ge3,0)
	end
end
-- 记录上级召唤成功时，作为祭品解放的怪兽数量。
function c76224717.checkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:IsSummonType(SUMMON_TYPE_ADVANCE) then
		c76224717[ep]=c76224717[ep]+tc:GetMaterial():FilterCount(Card.IsType,nil,TYPE_MONSTER)
	end
end
-- 清空双方玩家该回合上级召唤解放的怪兽数量记录。
function c76224717.clear(e,tp,eg,ep,ev,re,r,rp)
	c76224717[0]=0
	c76224717[1]=0
end
-- 过滤条件：场上盖放的卡。
function c76224717.filter1(c)
	return c:IsFacedown()
end
-- 过滤条件：墓地的怪兽且能加入手卡。
function c76224717.filter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果发动的目标过滤与操作信息设置。
function c76224717.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足“解放1只以上且对方场上有盖放的卡”的条件。
	local b1=c76224717[tp]>0 and Duel.IsExistingMatchingCard(c76224717.filter1,tp,0,LOCATION_ONFIELD,1,nil)
	-- 检查是否满足“解放2只以上且自己可以抽卡”的条件。
	local b2=c76224717[tp]>1 and Duel.IsPlayerCanDraw(tp,1)
	-- 检查是否满足“解放3只以上且自己墓地有怪兽可以加入手卡”的条件。
	local b3=c76224717[tp]>2 and Duel.IsExistingMatchingCard(c76224717.filter2,tp,LOCATION_GRAVE,0,1,nil)
	if chk==0 then return b1 or b2 or b3 end
	if b1 then
		-- 获取对方场上所有盖放的卡。
		local g=Duel.GetMatchingGroup(c76224717.filter1,tp,0,LOCATION_ONFIELD,nil)
		-- 设置连锁信息：包含破坏效果，对象为对方场上盖放的卡。
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	end
	if b2 then
		-- 设置连锁信息：包含抽卡效果，数量为1张。
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
	if b3 then
		-- 设置连锁信息：包含将墓地卡片加入手卡的效果。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	end
end
-- 效果处理的执行函数，根据解放数量依次适用对应效果。
function c76224717.operation(e,tp,eg,ep,ev,re,r,rp)
	local act=false
	if c76224717[tp]>0 then
		-- 提示玩家选择要破坏的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 玩家选择对方场上盖放的1张卡。
		local g=Duel.SelectMatchingCard(tp,c76224717.filter1,tp,0,LOCATION_ONFIELD,1,1,nil)
		if g:GetCount()>0 then
			-- 破坏选择的卡。
			Duel.Destroy(g,REASON_EFFECT)
			act=true
		end
	end
	-- 如果解放数量在2只以上且可以抽卡，则处理抽卡效果。
	if c76224717[tp]>1 and Duel.IsPlayerCanDraw(tp,1) then
		-- 如果之前已执行过破坏效果，则中断当前效果处理，使后续抽卡不与破坏同时处理（防止错时点）。
		if act then Duel.BreakEffect() end
		-- 玩家从卡组抽1张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
		act=true
	end
	if c76224717[tp]>2 then
		-- 提示玩家选择要加入手牌的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 玩家选择自己墓地的1只怪兽。
		local g=Duel.SelectMatchingCard(tp,c76224717.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
		if g:GetCount()>0 then
			-- 如果之前已执行过其他效果，则中断当前效果处理，使后续加入手卡不与前述效果同时处理。
			if act then Duel.BreakEffect() end
			-- 将选择的怪兽加入手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
