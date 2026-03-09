--与奪の首飾り
-- 效果：
-- 自己场上这张卡的装备怪兽被战斗破坏，这张卡送去墓地时，选择下面1个效果发动。
-- ●从卡组抽1张卡。
-- ●对方随机丢弃1张手卡去墓地。
function c48576971.initial_effect(c)
	-- 创建一个发动时点效果，用于装备怪兽
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_CONTINUOUS_TARGET)
	e1:SetTarget(c48576971.target)
	e1:SetOperation(c48576971.operation)
	c:RegisterEffect(e1)
	-- 设置装备对象限制，只能装备给自己的怪兽
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_EQUIP_LIMIT)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	-- 创建一个诱发必发效果，当此卡被送去墓地时发动
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(48576971,0))  --"选择效果发动"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_TO_GRAVE)
	e3:SetCondition(c48576971.effcon)
	e3:SetTarget(c48576971.efftg)
	e3:SetOperation(c48576971.effop)
	c:RegisterEffect(e3)
end
-- 选择目标怪兽进行装备
function c48576971.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsFaceup() end
	-- 判断是否满足选择目标的条件
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择场上一只表侧表示的怪兽作为装备对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置效果处理信息，准备将此卡装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 执行装备操作，将此卡装备给目标怪兽
function c48576971.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 执行装备动作，将此卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
	end
end
-- 判断是否满足发动效果的条件：装备怪兽因战斗破坏而失去装备对象
function c48576971.effcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetPreviousEquipTarget()
	return c:IsReason(REASON_LOST_TARGET) and ec:IsReason(REASON_BATTLE) and ec:IsPreviousControler(tp)
end
-- 选择发动效果，从以下两个效果中选择一个：①从卡组抽1张卡；②对方随机丢弃1张手卡去墓地
function c48576971.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local opt=0
	-- 判断自己是否可以抽卡
	local b1=Duel.IsPlayerCanDraw(tp,1)
	-- 判断对方手牌数量是否大于0
	local b2=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	if b1 and b2 then
		-- 让玩家在两个效果中选择一个进行发动
		opt=Duel.SelectOption(tp,aux.Stringid(48576971,1),aux.Stringid(48576971,2))  --"从卡组抽1张卡/对方随机丢弃1张手卡去墓地"
	elseif b1 then
		-- 让玩家选择从卡组抽1张卡的效果
		opt=Duel.SelectOption(tp,aux.Stringid(48576971,1))  --"从卡组抽1张卡"
	elseif b2 then
		-- 让玩家选择对方随机丢弃1张手卡去墓地的效果
		opt=Duel.SelectOption(tp,aux.Stringid(48576971,2))+1  --"对方随机丢弃1张手卡去墓地"
	else opt=2 end
	e:SetLabel(opt)
	if opt==0 then
		e:SetCategory(CATEGORY_DRAW)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 设置效果的目标玩家为发动者本人
		Duel.SetTargetPlayer(tp)
		-- 设置效果的目标参数为1
		Duel.SetTargetParam(1)
		-- 设置效果处理信息，准备进行抽卡操作
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	elseif opt==1 then
		e:SetCategory(CATEGORY_HANDES)
		e:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		-- 设置效果的目标玩家为对方
		Duel.SetTargetPlayer(1-tp)
		-- 设置效果的目标参数为1
		Duel.SetTargetParam(1)
		-- 设置效果处理信息，准备进行丢弃手牌操作
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,1-tp,1)
	else
		e:SetCategory(0)
		e:SetProperty(0)
	end
end
-- 根据选择的效果类型执行对应的操作：①抽卡；②对方丢弃手牌
function c48576971.effop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 获取连锁中设定的目标玩家和目标参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 执行抽卡操作
		Duel.Draw(p,d,REASON_EFFECT)
	elseif e:GetLabel()==1 then
		-- 获取连锁中设定的目标玩家和目标参数
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		-- 从目标玩家的手牌中随机选择指定数量的卡
		local g=Duel.GetFieldGroup(p,LOCATION_HAND,0):RandomSelect(p,d)
		-- 将选中的手牌送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
	end
end
