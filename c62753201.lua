--ヴァレル・レフリジェレーション
-- 效果：
-- ①：把自己场上1只「弹丸」怪兽解放，以自己场上1只「枪管」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽得到以下效果。
-- ●1回合1次，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。这个效果在对方回合也能发动。
function c62753201.initial_effect(c)
	-- ①：把自己场上1只「弹丸」怪兽解放，以自己场上1只「枪管」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。装备怪兽得到以下效果。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(c62753201.cost)
	e1:SetTarget(c62753201.target)
	e1:SetOperation(c62753201.activate)
	c:RegisterEffect(e1)
end
-- 过滤条件：自己场上的「弹丸」怪兽
function c62753201.cfilter(c)
	return c:IsSetCard(0x102)
end
-- 发动代价：解放自己场上1只「弹丸」怪兽，并注册连锁无效时防止送墓的辅助效果
function c62753201.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在可解放的「弹丸」怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,c62753201.cfilter,1,nil) end
	-- 选择1只可解放的「弹丸」怪兽
	local rg=Duel.SelectReleaseGroup(tp,c62753201.cfilter,1,1,nil)
	-- 解放选择的怪兽作为发动代价
	Duel.Release(rg,REASON_COST)
	local c=e:GetHandler()
	-- 获取当前发动连锁的唯一标识ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 这张卡当作装备卡使用给那只怪兽装备。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- ①：把自己场上1只「弹丸」怪兽解放，以自己场上1只「枪管」连接怪兽为对象才能把这张卡发动。这张卡当作装备卡使用给那只怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c62753201.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册用于处理连锁被无效时将卡片送去墓地的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 连锁无效时的处理：如果本卡的发动被无效，则取消留在场上的状态，正常送去墓地
function c62753201.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的唯一标识ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤条件：自己场上表侧表示的「枪管」连接怪兽
function c62753201.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK) and c:IsSetCard(0x10f)
end
-- 效果的目标：检查并选择自己场上1只表侧表示的「枪管」连接怪兽作为对象
function c62753201.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c62753201.filter(chkc) end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在满足条件的「枪管」连接怪兽
		and Duel.IsExistingTarget(c62753201.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己场上1只「枪管」连接怪兽作为效果的对象
	Duel.SelectTarget(tp,c62753201.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁信息，表示该效果包含装备操作，对象是自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 装备限制：只能装备给自身控制的「枪管」连接怪兽
function c62753201.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_LINK) and c:IsSetCard(0x10f)
end
-- 效果的处理：将自身作为装备卡装备给目标怪兽，并赋予其相应的效果
function c62753201.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsLocation(LOCATION_SZONE) then return end
	if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将这张卡装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 这张卡当作装备卡使用给那只怪兽装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetValue(c62753201.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- ●1回合1次，以自己场上1只怪兽为对象才能发动。这个回合，那只怪兽不会被战斗·效果破坏。这个效果在对方回合也能发动。
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(62753201,0))  --"附加抗性（枪管冷却）"
		e2:SetType(EFFECT_TYPE_QUICK_O)
		e2:SetCode(EVENT_FREE_CHAIN)
		e2:SetRange(LOCATION_MZONE)
		e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		e2:SetCountLimit(1)
		e2:SetTarget(c62753201.indtg)
		e2:SetOperation(c62753201.indop)
		-- 装备怪兽得到以下效果。
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
		e3:SetRange(LOCATION_SZONE)
		e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e3:SetTarget(c62753201.eftg)
		e3:SetLabelObject(e2)
		c:RegisterEffect(e3)
	else
		c:CancelToGrave(false)
	end
end
-- 效果赋予的目标过滤：仅赋予给当前装备了这张卡的怪兽
function c62753201.eftg(e,c)
	return e:GetHandler():GetEquipTarget()==c
end
-- 赋予效果的启动目标：选择自己场上1只表侧表示的怪兽作为对象
function c62753201.indtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	-- 检查自己场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只表侧表示的怪兽作为对象
	Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 赋予效果的处理：使目标怪兽在本回合内获得战斗和效果破坏抗性
function c62753201.indop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 这个回合，那只怪兽不会被战斗·效果破坏。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		tc:RegisterEffect(e2)
	end
end
