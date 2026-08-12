--セブン・ソード・ウォリアー
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 1回合1次，这张卡被装备卡装备时，给与对方基本分800分伤害。此外，1回合1次，可以把这张卡装备的1张装备卡送去墓地。这张卡装备的装备卡送去墓地时，可以选择对方场上表侧表示存在的1只怪兽破坏。
function c43366227.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，这张卡被装备卡装备时，给与对方基本分800分伤害
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
	-- 此外，1回合1次，可以把这张卡装备的1张装备卡送去墓地
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
	-- 这张卡装备的装备卡送去墓地时，可以选择对方场上表侧表示存在的1只怪兽破坏
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
-- 判断是否处于连锁中，若不是则可以发动效果
function c43366227.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 设置连锁的目标玩家为对方
	Duel.SetTargetPlayer(1-tp)
	-- 设置连锁的目标参数为800
	Duel.SetTargetParam(800)
	-- 设置效果操作信息为对对方造成800伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
end
-- 获取连锁的目标玩家和参数并造成伤害
function c43366227.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 对目标玩家造成指定伤害
	Duel.Damage(p,d,REASON_EFFECT)
end
-- 判断是否有装备卡，若有则选择一张装备卡送去墓地
function c43366227.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:GetEquipTarget()==e:GetHandler() end
	if chk==0 then return e:GetHandler():GetEquipCount()~=0 end
	-- 提示玩家选择要送去墓地的装备卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=e:GetHandler():GetEquipGroup():Select(tp,1,1,nil)
	-- 设置选择的装备卡为连锁目标
	Duel.SetTargetCard(g)
	-- 设置效果操作信息为将装备卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
end
-- 若装备卡存在则将其送去墓地
function c43366227.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡送去墓地
		Duel.SendtoGrave(tc,REASON_EFFECT)
	end
end
-- 过滤条件：卡片在墓地且控制者为指定玩家且装备目标为指定卡
function c43366227.cfilter(c,ec,tp)
	return c:IsLocation(LOCATION_GRAVE) and c:IsControler(tp) and c:GetEquipTarget()==ec
end
-- 判断是否有装备卡离开场时被送去墓地
function c43366227.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c43366227.cfilter,1,nil,e:GetHandler(),tp)
end
-- 过滤条件：卡片为表侧表示
function c43366227.desfilter(c)
	return c:IsFaceup()
end
-- 选择对方场上表侧表示存在的1只怪兽进行破坏
function c43366227.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c43366227.desfilter(chkc) end
	-- 判断对方场上是否存在表侧表示的怪兽
	if chk==0 then return Duel.IsExistingTarget(c43366227.desfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上表侧表示存在的1只怪兽
	local g=Duel.SelectTarget(tp,c43366227.desfilter,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置效果操作信息为破坏目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 若目标怪兽存在且为表侧表示则将其破坏
function c43366227.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将目标卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
