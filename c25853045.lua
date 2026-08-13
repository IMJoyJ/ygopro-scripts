--FA－ブラック・レイ・ランサー
-- 效果：
-- 水属性4星怪兽×3
-- 这张卡也能在自己场上的没有超量素材的3阶水属性超量怪兽上面重叠来超量召唤。
-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
-- ②：这张卡战斗破坏对方怪兽时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的超量素材全部取除。
function c25853045.initial_effect(c)
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_WATER),4,3,c25853045.ovfilter,aux.Stringid(25853045,0))  --"是否在没有超量素材的水属性·3阶超量怪兽上面重叠超量召唤？"
	c:EnableReviveLimit()
	-- ①：这张卡的攻击力上升这张卡的超量素材数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c25853045.atkval)
	c:RegisterEffect(e1)
	-- ③：场上的这张卡被战斗·效果破坏的场合，可以作为代替把这张卡的超量素材全部取除。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_DESTROY_REPLACE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c25853045.reptg)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏对方怪兽时，以对方场上1张魔法·陷阱卡为对象才能发动。那张对方的卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(25853045,2))  --"魔陷破坏"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置效果发动条件：这张卡与对方怪兽进行了战斗并战斗破坏对方怪兽时（检测本卡是否与本次战斗有关且对手是对方怪兽）。
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c25853045.destg)
	e3:SetOperation(c25853045.desop)
	c:RegisterEffect(e3)
end
-- 额外超量召唤手续的叠放对象过滤函数：判定场上表侧表示的3阶、水属性且没有超量素材的超量怪兽，可在其上面重叠进行超量召唤。
function c25853045.ovfilter(c)
	return c:IsFaceup() and c:IsRank(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:GetOverlayCount()==0
end
-- 攻击力上升值计算：返回这张卡的超量素材数量×200。
function c25853045.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 代替破坏效果的判定：若这张卡因战斗或效果被破坏且不是由于代替破坏而破坏，并且可以取除至少1个超量素材，则允许代替破坏。
function c25853045.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果（把这张卡的超量素材全部取除）。
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetOverlayGroup()
		-- 将这张卡的超量素材全部送去墓地（实现“取除全部素材”作为代替破坏的代价）。
		Duel.SendtoGrave(g,REASON_EFFECT)
		return true
	else return false end
end
-- 过滤函数：判定卡片是魔法卡或陷阱卡。
function c25853045.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果目标处理：以对方场上1张魔法·陷阱卡为对象；检查存在可行对象后，提示并选择目标，并设置破坏的操作信息。
function c25853045.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c25853045.filter(chkc) end
	-- 发动条件判定：检查对方场上是否存在至少1张魔法·陷阱卡可以作为效果对象。
	if chk==0 then return Duel.IsExistingTarget(c25853045.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 发送选择提示信息，显示‘请选择要破坏的卡’。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为对象，并将其设为当前连锁的对象。
	local g=Duel.SelectTarget(tp,c25853045.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息：将选中的1张卡登记为本次效果的破坏对象。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理操作：取得对象卡；若该卡仍与效果关联且仍在对方场上，则将其破坏。
function c25853045.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果的对象卡（当前连锁的第一个目标）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以效果破坏该对象卡。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
