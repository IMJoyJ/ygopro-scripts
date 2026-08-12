--剛鬼ツープラトン
-- 效果：
-- ①：这张卡作为「刚鬼」连接怪兽的连接素材送去墓地的场合才能发动。那只「刚鬼」连接怪兽的攻击力直到回合结束时上升1000。
-- ②：把墓地的这张卡除外，以自己墓地1张「刚鬼」魔法卡为对象才能发动。那张卡回到卡组。这个效果在这张卡送去墓地的回合不能发动。
function c67586735.initial_effect(c)
	-- ①：这张卡作为「刚鬼」连接怪兽的连接素材送去墓地的场合才能发动。那只「刚鬼」连接怪兽的攻击力直到回合结束时上升1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(67586735,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BE_MATERIAL)
	e1:SetCondition(c67586735.atkcon)
	e1:SetTarget(c67586735.atktg)
	e1:SetOperation(c67586735.atkop)
	c:RegisterEffect(e1)
	-- 建立作为素材的卡片与因其召唤出的怪兽之间的关系，以便在效果处理时能正确获取该连接怪兽
	aux.CreateMaterialReasonCardRelation(c,e1)
	-- ②：把墓地的这张卡除外，以自己墓地1张「刚鬼」魔法卡为对象才能发动。那张卡回到卡组。这个效果在这张卡送去墓地的回合不能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(67586735,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_GRAVE)
	-- 设置发动条件：这张卡送去墓地的回合不能发动
	e2:SetCondition(aux.exccon)
	-- 设置发动代价：把墓地的这张卡除外
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c67586735.tdtg)
	e2:SetOperation(c67586735.tdop)
	c:RegisterEffect(e2)
end
-- 判定发动条件：这张卡作为连接素材送去墓地，且该连接怪兽是「刚鬼」怪兽
function c67586735.atkcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_GRAVE) and r==REASON_LINK and c:GetReasonCard():IsSetCard(0xfc)
end
-- 判定发动效果的目标：获取作为素材召唤出的连接怪兽，并将其设为效果处理的对象
function c67586735.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=e:GetHandler():GetReasonCard()
	if chk==0 then return rc:IsRelateToEffect(e) and rc:IsFaceup() end
	-- 将该连接怪兽设为当前连锁的处理对象
	Duel.SetTargetCard(rc)
end
-- 效果处理：使作为对象的连接怪兽的攻击力直到回合结束时上升1000
function c67586735.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中设为对象的连接怪兽
	local rc=Duel.GetFirstTarget()
	if rc:IsFaceup() and rc:IsRelateToChain() then
		-- 那只「刚鬼」连接怪兽的攻击力直到回合结束时上升1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		rc:RegisterEffect(e1)
	end
end
-- 过滤条件：自己墓地的「刚鬼」魔法卡且能回到卡组
function c67586735.tdfilter(c)
	return c:IsSetCard(0xfc) and c:IsType(TYPE_SPELL) and c:IsAbleToDeck()
end
-- 判定发动效果的目标：选择自己墓地1张「刚鬼」魔法卡作为对象
function c67586735.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and c67586735.tdfilter(chkc) end
	-- 判定自己墓地是否存在满足条件的「刚鬼」魔法卡
	if chk==0 then return Duel.IsExistingTarget(c67586735.tdfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要返回卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 选择自己墓地1张「刚鬼」魔法卡作为对象
	local g=Duel.SelectTarget(tp,c67586735.tdfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁的操作信息：将选中的1张卡送回卡组
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,1,0,0)
end
-- 效果处理：将作为对象的卡回到卡组并洗牌
function c67586735.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取作为对象的「刚鬼」魔法卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将作为对象的卡送回卡组并洗牌
		Duel.SendtoDeck(tc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
