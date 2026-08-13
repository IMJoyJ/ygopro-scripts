--エアー・トルピード
-- 效果：
-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。
-- ①：以自己场上1只水属性超量怪兽为对象才能发动。那只怪兽1个超量素材取除，给与对方为自己手卡数量×400伤害。那只怪兽的攻击力直到回合结束时上升这个效果给与的伤害的数值。
-- ②：从自己墓地把这张卡和1只水属性超量怪兽除外才能发动。自己从卡组抽2张。
function c45943123.initial_effect(c)
	-- 这个卡名的①②的效果1回合只能有1次使用其中任意1个。①：以自己场上1只水属性超量怪兽为对象才能发动。那只怪兽1个超量素材取除，给与对方为自己手卡数量×400伤害。那只怪兽的攻击力直到回合结束时上升这个效果给与的伤害的数值。
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
	-- ②：从自己墓地把这张卡和1只水属性超量怪兽除外才能发动。自己从卡组抽2张。
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
-- ①效果选择对象时的过滤条件：怪兽必须表侧表示、水属性、超量，并且可以取除1个超量素材作为代价。
function c45943123.cfilter(c,tp)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
end
-- ①效果发动的目标处理：判断是否从手牌发动以从手牌计数中减去这张卡自身，确认场上有符合条件的水属性超量怪兽且手牌数大于0，然后选择对象并登记伤害信息。
function c45943123.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local b=e:IsHasType(EFFECT_TYPE_ACTIVATE) and e:GetHandler():IsLocation(LOCATION_HAND)
	-- 获取自己当前手牌数量，用于计算伤害。
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
	if b then ct=ct-1 end
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c45943123.cfilter(chkc,tp) end
	if chk==0 then
		-- 发动条件检查：场上存在至少1只符合条件的水属性超量怪兽，且自己手牌数大于0。
		return Duel.IsExistingTarget(c45943123.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) and ct>0
	end
	-- 给玩家发出选择效果对象的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择自己场上1只水属性超量怪兽作为效果对象，并将其登记为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c45943123.cfilter,tp,LOCATION_MZONE,0,1,1,nil,tp)
	-- 登记伤害操作信息：对方将受到手牌数×400的伤害。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*400)
end
-- ①效果处理：对象怪兽仍与效果关联且成功取除1个超量素材时，按当前手牌数给予对方伤害，并将对象怪兽攻击力上升实际造成的伤害值直到回合结束。
function c45943123.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:RemoveOverlayCard(tp,1,1,REASON_EFFECT) then
		-- 效果处理时重新计算自己手牌数量。
		local ct=Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)
		if ct>0 then
			-- 给予对方自己手牌数×400的伤害，并返回实际造成的伤害值，用于后续攻击力上升。
			local atk=Duel.Damage(1-tp,ct*400,REASON_EFFECT)
			if tc:IsFaceup() then
				-- 那只怪兽的攻击力直到回合结束时上升这个效果给与的伤害的数值。
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
-- 判断一张卡是否为水属性超量怪兽，并且可以被除外作为代价。
function c45943123.drfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsType(TYPE_XYZ) and c:IsAbleToRemoveAsCost()
end
-- ②效果发动代价判定：这张卡自身可以从墓地除外，并且墓地存在其他符合条件的水属性超量怪兽。
function c45943123.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		-- 并且墓地中存在满足drfilter条件的水属性超量怪兽（不包括这张卡自身）。
		and Duel.IsExistingMatchingCard(c45943123.drfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 给玩家发出选择要除外的卡片的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择墓地中1只水属性超量怪兽作为除外代价（之后会把这张卡也加入除外组）。
	local g=Duel.SelectMatchingCard(tp,c45943123.drfilter,tp,LOCATION_GRAVE,0,1,1,c)
	g:AddCard(c)
	-- 将选择的怪兽和这张卡以表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标处理：确认自己可以抽2张卡，设置目标玩家为自己、抽卡数为2，并登记抽卡操作信息。
function c45943123.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检查：自己能否抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	-- 将本次效果的目标玩家设置为自己。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的参数设置为2（抽卡数量）。
	Duel.SetTargetParam(2)
	-- 登记抽卡操作信息：目标玩家为自己，抽2张。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ②效果处理：从连锁信息中取出目标玩家和抽卡数，执行抽卡。
function c45943123.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁记录的目标玩家和抽卡参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家以效果原因抽对应数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
