--幻獣の角
-- 效果：
-- 发动后这张卡变成攻击力上升800的装备卡，给自己场上存在的1只兽族·兽战士族怪兽装备。装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
function c21350571.initial_effect(c)
	-- 发动后这张卡变成攻击力上升800的装备卡，给自己场上存在的1只兽族·兽战士族怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	-- 设置效果可在伤害步骤且伤害计算前发动。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c21350571.cost)
	e1:SetTarget(c21350571.target)
	e1:SetOperation(c21350571.operation)
	c:RegisterEffect(e1)
end
-- 发动时附加‘连锁结束前留在场上’的誓约保护，并注册连锁被无效时防止此卡被送去墓地的辅助效果。
function c21350571.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前连锁的ID，用于标记本连锁。
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 发动后这张卡变成攻击力上升800的装备卡。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 发动后这张卡变成攻击力上升800的装备卡，给自己场上存在的1只兽族·兽战士族怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c21350571.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 将连锁被无效时保护此卡的辅助效果注册到当前玩家。
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时，若此卡仍与连锁相关，则使其不因规则被送去墓地。
function c21350571.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁ID，判断是否为本卡发动的连锁。
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 筛选条件：表侧表示的兽族或兽战士族怪兽。
function c21350571.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 检查装备对象合法性以及场上是否存在符合条件的装备对象。
function c21350571.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c21350571.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在1只符合条件的兽族/兽战士族表侧怪兽可作为装备对象。
		and Duel.IsExistingTarget(c21350571.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家选择1只符合条件的表侧兽族/兽战士族怪兽作为装备对象。
	Duel.SelectTarget(tp,c21350571.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 登记操作信息：将此卡作为装备卡使用的装备效果。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：装备给对象，并赋予攻击力上升、抽卡诱发效果和装备限制；对象不合法时此卡送去墓地。
function c21350571.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取装备对象卡片。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将此卡装备到对象怪兽上。
		Duel.Equip(tp,c,tc)
		-- 装备怪兽战斗破坏对方怪兽送去墓地时，从自己卡组抽1张卡。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
		e1:SetCategory(CATEGORY_DRAW)
		e1:SetDescription(aux.Stringid(21350571,0))  --"抽卡"
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EVENT_BATTLE_DESTROYED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetCondition(c21350571.drcon)
		e1:SetTarget(c21350571.drtg)
		e1:SetOperation(c21350571.drop)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力上升800。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(800)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		-- 给自己场上存在的1只兽族·兽战士族怪兽装备。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_EQUIP_LIMIT)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetValue(c21350571.eqlimit)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 装备限制：允许装备给当前装备怪兽，以及自己场上表侧表示的兽族/兽战士族怪兽。
function c21350571.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
-- 筛选被装备怪兽战斗破坏并送去墓地的对方怪兽。
function c21350571.drfilter(c,rc)
	return c:IsLocation(LOCATION_GRAVE) and c:IsReason(REASON_BATTLE) and c:GetReasonCard()==rc
end
-- 装备怪兽战斗破坏对方怪兽并将其送去墓地时，满足抽卡触发条件。
function c21350571.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c21350571.drfilter,1,nil,e:GetHandler():GetEquipTarget())
end
-- 抽卡效果的条件和目标设定：指定自己为玩家、抽1张卡。
function c21350571.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡对象玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡张数为1。
	Duel.SetTargetParam(1)
	-- 登记抽卡操作信息：从自己卡组抽1张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理：按设定的玩家和张数执行抽卡。
function c21350571.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取设定的抽卡玩家和抽卡数量。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让指定玩家以效果原因抽指定数量的卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
