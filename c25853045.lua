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
	-- 检测本次战斗是否由该卡造成对方怪兽破坏
	e3:SetCondition(aux.bdocon)
	e3:SetTarget(c25853045.destg)
	e3:SetOperation(c25853045.desop)
	c:RegisterEffect(e3)
end
-- 过滤满足条件的怪兽：表侧表示、3阶、水属性、没有超量素材
function c25853045.ovfilter(c)
	return c:IsFaceup() and c:IsRank(3) and c:IsAttribute(ATTRIBUTE_WATER) and c:GetOverlayCount()==0
end
-- 计算攻击力增加值：超量素材数量×200
function c25853045.atkval(e,c)
	return c:GetOverlayCount()*200
end
-- 判断是否满足代替破坏条件：检查是否有足够超量素材可取除、破坏原因包含战斗或效果、且不是代替破坏
function c25853045.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
		and c:IsReason(REASON_BATTLE+REASON_EFFECT) and not c:IsReason(REASON_REPLACE) end
	-- 询问玩家是否发动代替破坏效果
	if Duel.SelectEffectYesNo(tp,c,96) then
		local g=c:GetOverlayGroup()
		-- 将超量素材送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
		return true
	else return false end
end
-- 过滤魔法·陷阱卡
function c25853045.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 设置选择对象的处理：选择对方场上的魔法·陷阱卡
function c25853045.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c25853045.filter(chkc) end
	-- 确认是否满足发动条件：对方场上存在魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c25853045.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上的1张魔法·陷阱卡作为对象
	local g=Duel.SelectTarget(tp,c25853045.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置连锁操作信息：破坏对象卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行破坏效果：破坏选择的魔法·陷阱卡
function c25853045.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中选择的对象卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) then
		-- 以效果原因破坏对象卡
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
