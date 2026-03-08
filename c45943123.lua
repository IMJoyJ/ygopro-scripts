--エアー・トルピード
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只水属性超量怪兽为对象才能发动。那只怪兽1个超量素材取除，给与对方为自己手卡数量×400伤害。那只怪兽的攻击力直到回合结束时上升这个效果给与的伤害的数值。
-- ②：从自己墓地把这张卡和1只水属性超量怪兽除外才能发动。自己从卡组抽2张。
function c45943123.initial_effect(c)
	-- ①：以自己场上1只水属性超量怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(45943123,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,45943123)
	e1:SetTarget(c45943123.target)
	e1:SetOperation(c45943123.activate)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1只水属性超量怪兽除外才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(45943123,1))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,45943123)
	e2:SetCost(c45943123.drcost)
	e2:SetTarget(c45943123.drtg)
	e2:SetOperation(c45943123.drop)
	c:RegisterEffect(e2)
end
-- 过滤函数，检查目标是否为表侧表示的水属性超量怪兽且能取除1个超量素材
function c45943123.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- 效果处理时的处理函数，用于选择对象怪兽并设置伤害值
function c45943123.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND)
	-- 获取玩家手牌数量
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if b then ct=ct-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45943123.cfilter(chkc,tp) end
	if chk==0 then
		-- 判断是否满足选择对象怪兽和手牌数量大于0的条件
		return Duel.IsExistingTarget(c45943123.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and ct>0
	end
	-- 提示玩家选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择满足条件的1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c45943123.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 设置效果处理时的伤害信息
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*400)
end
-- 效果处理函数，执行效果的伤害和攻击力提升
function c45943123.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		-- 获取玩家手牌数量
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if ct>0 then
			-- 对对方造成手牌数量×400的伤害
			local atk=Duel.Damage(1-tp,ct*400,REASON_EFFECT)
			if tc:IsFaceup() then
				-- 使对象怪兽的攻击力上升造成的伤害值
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(atk)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
		end
	end
end
-- 过滤函数，检查墓地中的水属性超量怪兽是否可以作为除外的代价
function c45943123.drfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
-- 效果发动时的费用支付函数，检查是否满足除外条件
function c45943123.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 检查玩家墓地是否存在满足条件的水属性超量怪兽
		and Duel.IsExistingMatchingCard(c45943123.drfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的1只水属性超量怪兽
	local g=Duel.SelectMatchingCard(tp,c45943123.drfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的卡除外作为费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果处理时的处理函数，设置抽卡效果的目标
function c45943123.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 设置效果处理的目标玩家为当前玩家
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理的目标参数为2
	Duel.SetTargetParam(2)
	-- 设置效果处理时的抽卡信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理函数，执行抽卡效果
function c45943123.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
