--セブン・ソード・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，这张卡被装备卡装备时，给与对方基本分800分伤害。此外，1回合1次，可以把这张卡装备的1张装备卡送去墓地。这张卡装备的装备卡送去墓地时，可以选择对方场上表侧表示存在的1只怪兽破坏。
function c43366227.initial_effect(c)
	-- 为七剑战士添加同调召唤手续：调整＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，这张卡被装备卡装备时，给与对方基本分800分伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(43366227,0))  --"伤害"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCountLimit(1)
	e1:SetCode(EVENT_EQUIP)
	e1:SetTarget(c43366227.damtg)
	e1:SetOperation(c43366227.damop)
	c:RegisterEffect(e1)
	-- 此外，1回合1次，可以把这张卡装备的1张装备卡送去墓地。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43366227,1))  --"装备送墓"
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c43366227.tgtg)
	e2:SetOperation(c43366227.tgop)
	c:RegisterEffect(e2)
	-- 这张卡装备的装备卡送去墓地时，可以选择对方场上表侧表示存在的1只怪兽破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43366227,2))  --"破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(c43366227.descon)
	e3:SetTarget(c43366227.destg)
	e3:SetOperation(c43366227.desop)
	c:RegisterEffect(e3)
end
-- 第一效果的发动判定函数：确认此卡不在连锁处理中，将伤害对象设定为对方玩家并设定伤害值800，同时登记伤害操作信息。
function c43366227.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 将当前连锁的对象玩家设定为对方玩家，使伤害由对方承受。
	Duel.SetTargetPlayer(1-tp)
	-- 设定当前连锁的对象参数为800，作为造成的伤害数值。
	Duel.SetTargetParam(800)
	-- 登记本次连锁的操作信息：将造成伤害效果，目标为对方玩家、数值800。
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 第一效果的实际处理：从连锁信息中取出之前设定的目标玩家和伤害数值，给予对方玩家800点效果伤害。
function c43366227.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出对象玩家和对象参数，分别赋值给p和d。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 以效果原因（REASON_EFFECT）对玩家p造成d点伤害。
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 第二效果的发动条件与对象选择：确认此卡装备有装备卡，选择其中1张装备卡作为对象，并登记送入墓地的操作信息。
function c43366227.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetEquipTarget()==e:GetHandler() end
	if chk==0 then return e:GetHandler():GetEquipCount()~=0 end
	-- 显示选择提示，要求选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():Select(tp,1,1,nil)
	-- 将选择的装备卡设为当前连锁的对象卡，与效果建立关联。
	Duel.SetTargetCard(g)
	-- 登记操作信息：将选择的对象卡（1张）送入墓地。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 第二效果的处理：将选中的装备卡在确认仍与效果关联后送入墓地。
function c43366227.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡（即选中的装备卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将装备卡送入墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤函数：判断卡片是否为原本装备在此卡上、由我方持有并已进入墓地的装备卡。
function c43366227.cfilter(c,ec,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
-- 第三效果的发动条件：检测到有原本装备在此卡上的装备卡被送入墓地。
function c43366227.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43366227.cfilter,1,nil,e:GetHandler(),tp)
end
-- 破坏对象的选择条件：怪兽需要处于表侧表示。
function c43366227.desfilter(c)
	return c:IsFaceup()
end
-- 第三效果的发动目标处理：确认对方场上有表侧表示怪兽，选择其中1只作为破坏对象，并登记破坏操作信息。
function c43366227.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43366227.desfilter(chkc) end
	-- 发动条件检查：确认对方场上存在至少1只表侧表示且能成为对象的怪兽。
	if chk==0 then return Duel.IsExistingTarget(c43366227.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 在对方场上选择1只表侧表示怪兽作为对象，并登记为当前连锁的取对象目标。
	local g=Duel.SelectTarget(tp,c43366227.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 登记操作信息：将选择的对象卡（1只怪兽）破坏。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 第三效果的实际处理：确认对象卡仍与此效果关联且仍表侧表示后，将其破坏。
function c43366227.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的第一个对象卡（即选择的怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 以效果原因将对象怪兽破坏。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
