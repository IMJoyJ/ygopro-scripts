--シールド・ハンドラ
-- 效果：
-- ①：要让场上的怪兽破坏的魔法·陷阱·怪兽的效果发动时，以自己以及对方场上的连接怪兽各1只为对象才能把这张卡发动。作为对象的对方怪兽的效果无效，把这张卡当作装备卡使用给作为对象的自己怪兽装备。装备怪兽不会被效果破坏。
function c93655221.initial_effect(c)
	-- ①：要让场上的怪兽破坏的魔法·陷阱·怪兽的效果发动时，以自己以及对方场上的连接怪兽各1只为对象才能把这张卡发动。作为对象的对方怪兽的效果无效，把这张卡当作装备卡使用给作为对象的自己怪兽装备。装备怪兽不会被效果破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c93655221.condition)
	e1:SetCost(c93655221.cost)
	e1:SetTarget(c93655221.target)
	e1:SetOperation(c93655221.activate)
	c:RegisterEffect(e1)
end
-- 过滤场上的怪兽卡，用于检测破坏效果是否会破坏场上的怪兽
function c93655221.cfilter(c)
	return c:IsOnField() and c:IsType(TYPE_MONSTER)
end
-- 检查发动条件：对方发动了会破坏场上怪兽的怪兽效果或魔法·陷阱卡的发动
function c93655221.condition(e,tp,eg,ep,ev,re,r,rp)
	if tp==ep then return false end
	if not re:IsActiveType(TYPE_MONSTER) and not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	-- 获取当前连锁中准备处理的破坏操作的信息
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc+tg:FilterCount(c93655221.cfilter,nil)-tg:GetCount()>0
end
-- 设定发动时的Cost处理，包括让陷阱卡留在场上以及处理连锁被无效时送去墓地的辅助效果
function c93655221.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	-- 获取当前发动这张卡时的连锁ID
	local cid=Duel.GetChainInfo(0,CHAININFO_CHAIN_ID)
	-- 才能把这张卡发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_REMAIN_FIELD)
	e1:SetProperty(EFFECT_FLAG_OATH)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
	-- 以自己以及对方场上的连接怪兽各1只为对象才能把这张卡发动。作为对象的对方怪兽的效果无效，把这张卡当作装备卡使用给作为对象的自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_DISABLED)
	e2:SetOperation(c93655221.tgop)
	e2:SetLabel(cid)
	e2:SetReset(RESET_CHAIN)
	-- 注册全局效果，用于在当前连锁被无效时，将这张卡送去墓地
	Duel.RegisterEffect(e2,tp)
end
-- 连锁被无效时的处理：如果这张卡在连锁中被无效，则取消其留在场上的状态，使其正常送去墓地
function c93655221.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取被无效的连锁的连锁ID
	local cid=Duel.GetChainInfo(ev,CHAININFO_CHAIN_ID)
	if cid~=e:GetLabel() then return end
	if e:GetOwner():IsRelateToChain(ev) then
		e:GetOwner():CancelToGrave(false)
	end
end
-- 过滤自己场上表侧表示的连接怪兽，作为装备对象
function c93655221.eqfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_LINK)
end
-- 过滤对方场上可以被无效效果的连接怪兽
function c93655221.disfilter(c)
	-- 检查卡片是否为连接怪兽，且处于表侧表示、未被无效化、是效果怪兽
	return c:IsType(TYPE_LINK) and aux.NegateMonsterFilter(c)
end
-- 检查并选择自己和对方场上的连接怪兽各1只作为对象
function c93655221.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	if chk==0 then return e:IsCostChecked()
		-- 检查自己场上是否存在可以作为对象的表侧表示连接怪兽
		and Duel.IsExistingTarget(c93655221.eqfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为对象的、效果未被无效的连接怪兽
		and Duel.IsExistingTarget(c93655221.disfilter,tp,0,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择自己场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)  --"请选择自己的卡"
	-- 选择自己场上1只表侧表示的连接怪兽作为对象
	Duel.SelectTarget(tp,c93655221.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 提示玩家选择对方场上的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPPO)  --"请选择对方的卡"
	-- 选择对方场上1只效果未被无效的连接怪兽作为对象并记录
	local g=Duel.SelectTarget(tp,c93655221.disfilter,tp,0,LOCATION_MZONE,1,1,nil)
	e:SetLabelObject(g:GetFirst())
	-- 设置连锁操作信息：包含无效效果的操作，对象为选择的对方怪兽
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,g,1,0,0)
	-- 设置连锁操作信息：包含装备操作，对象为这张卡自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：无效作为对象的对方怪兽的效果，并将这张卡装备给作为对象的自己怪兽，赋予其效果破坏抗性
function c93655221.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local hc=e:GetLabelObject()
	-- 获取当前连锁中被选择为对象的所有卡片
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local tc=g:GetFirst()
	if tc==hc then tc=g:GetNext() end
	if hc:IsFaceup() and hc:IsRelateToEffect(e) and hc:IsType(TYPE_MONSTER) and hc:IsCanBeDisabledByEffect(e) and hc:IsControler(1-tp) then
		-- 无效与该对方怪兽相关的连锁
		Duel.NegateRelatedChain(hc,RESET_TURN_SET)
		-- 作为对象的对方怪兽的效果无效
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e1)
		-- 作为对象的对方怪兽的效果无效
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DISABLE_EFFECT)
		e2:SetValue(RESET_TURN_SET)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		hc:RegisterEffect(e2)
		if not c:IsLocation(LOCATION_SZONE) then return end
		if not c:IsRelateToEffect(e) or c:IsStatus(STATUS_LEAVE_CONFIRMED) then return end
		if tc:IsRelateToEffect(e) and tc:IsFaceup() then
			-- 将这张卡作为装备卡装备给作为对象的自己怪兽
			Duel.Equip(tp,c,tc)
			-- 把这张卡当作装备卡使用给作为对象的自己怪兽装备。
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetCode(EFFECT_EQUIP_LIMIT)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetValue(c93655221.eqlimit)
			e3:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e3)
			-- 装备怪兽不会被效果破坏。
			local e4=Effect.CreateEffect(c)
			e4:SetType(EFFECT_TYPE_EQUIP)
			e4:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
			e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
			e4:SetValue(1)
			e4:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e4)
		else
			c:CancelToGrave(false)
		end
	end
end
-- 装备限制：只能装备给作为对象的自己场上的连接怪兽
function c93655221.eqlimit(e,c)
	return e:GetHandler():GetEquipTarget()==c
		or c:IsControler(e:GetHandlerPlayer()) and c:IsType(TYPE_LINK)
end
