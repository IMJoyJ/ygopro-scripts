--幸運の鉄斧
-- 效果：
-- ①：装备怪兽的攻击力上升500。
-- ②：场上表侧表示存在的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
function c34664411.initial_effect(c)
	-- ①：装备怪兽的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c34664411.target)
	e1:SetOperation(c34664411.operation)
	c:RegisterEffect(e1)
	-- 装备怪兽的攻击力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(500)
	c:RegisterEffect(e2)
	-- 装备怪兽
	local e3=Effect.CreateEffect(c)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_EQUIP_LIMIT)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ②：场上表侧表示存在的这张卡被对方的效果破坏送去墓地的场合发动。自己从卡组抽1张。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(34664411,0))  --"抽卡"
	e4:SetCategory(CATEGORY_DRAW)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCondition(c34664411.drcon)
	e4:SetTarget(c34664411.drtg)
	e4:SetOperation(c34664411.drop)
	c:RegisterEffect(e4)
end
-- 发动时的取对象处理：选择场上1只表侧表示怪兽作为装备对象，并设置装备操作信息。
function c34664411.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 发动条件判定：仅在场上存在至少1只表侧表示怪兽时才能发动。
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 弹出“请选择要装备的卡”的选择提示框。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择1只表侧表示怪兽作为装备对象，并登记为这张卡的效果对象。
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 将本次行为登记为“装备”类操作，供其他卡检测或连锁。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 发动处理：若这张卡和对象怪兽仍与效果关联且对象表侧表示，则将这张卡装备给该怪兽。
function c34664411.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if e:GetHandler():IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡作为装备卡装备到对象怪兽上。
		Duel.Equip(tp,e:GetHandler(),tc)
	end
end
-- ②的发动条件：这张卡之前在自己场上表侧表示，被对方的效果破坏并送去墓地。
function c34664411.drcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return bit.band(r,0x41)==0x41 and rp==1-tp and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
-- ②的目标设定：指定抽卡玩家为自己、抽卡数量为1，并登记抽卡操作信息。
function c34664411.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将本次效果的“对象玩家”设为这张卡的控制者（自己）。
	Duel.SetTargetPlayer(tp)
	-- 将本次效果的“对象参数”设为1，表示抽卡张数。
	Duel.SetTargetParam(1)
	-- 设置处理信息为抽1张卡，供时点与连锁相关检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- ②的发动处理：取出链上保存的抽卡玩家与张数，执行抽卡。
function c34664411.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出抽卡玩家和抽卡张数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 该玩家以效果原因抽1张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
