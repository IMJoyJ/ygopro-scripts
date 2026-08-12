--コアキメイル・マキシマム
-- 效果：
-- 这张卡不能通常召唤。从自己手卡把1张「核成兽的钢核」从游戏中除外的场合可以特殊召唤。这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」或1只名字带有「核成」的怪兽送去墓地。或者都不进行让这张卡破坏。1回合1次，自己的主要阶段时可以选择对方场上存在的1张卡破坏。
function c65026212.initial_effect(c)
	-- 注册该卡片关联的卡片密码（36623431为「核成兽的钢核」）
	aux.AddCodeList(c,36623431)
	c:EnableReviveLimit()
	-- 这张卡的控制者在每次自己的结束阶段从手卡把1张「核成兽的钢核」或1只名字带有「核成」的怪兽送去墓地。或者都不进行让这张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c65026212.mtcon)
	e1:SetOperation(c65026212.mtop)
	c:RegisterEffect(e1)
	-- 这张卡不能通常召唤。从自己手卡把1张「核成兽的钢核」从游戏中除外的场合可以特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(c65026212.spcon)
	e2:SetTarget(c65026212.sptg)
	e2:SetOperation(c65026212.spop)
	c:RegisterEffect(e2)
	-- 1回合1次，自己的主要阶段时可以选择对方场上存在的1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65026212,3))  --"破坏"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetTarget(c65026212.destg)
	e3:SetOperation(c65026212.desop)
	c:RegisterEffect(e3)
end
-- 维持效果（结束阶段处理）的条件函数：必须是自己的回合
function c65026212.mtcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查当前回合玩家是否为该卡的控制者
	return Duel.GetTurnPlayer()==tp
end
-- 过滤函数：手卡中可送去墓地的「核成兽的钢核」
function c65026212.cfilter1(c)
	return c:IsCode(36623431) and c:IsAbleToGraveAsCost()
end
-- 过滤函数：手卡中可送去墓地的「核成」怪兽
function c65026212.cfilter2(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0x1d) and c:IsAbleToGraveAsCost()
end
-- 维持效果（结束阶段处理）的操作函数：选择将手卡的「核成兽的钢核」或「核成」怪兽送去墓地，或者将自身破坏
function c65026212.mtop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 选中该卡并显示被选为对象的动画效果（提示玩家该卡正在进行维持效果处理）
	Duel.HintSelection(Group.FromCards(c))
	-- 获取自己手卡中所有满足条件的「核成兽的钢核」
	local g1=Duel.GetMatchingGroup(c65026212.cfilter1,tp,LOCATION_HAND,0,nil)
	-- 获取自己手卡中所有满足条件的「核成」怪兽
	local g2=Duel.GetMatchingGroup(c65026212.cfilter2,tp,LOCATION_HAND,0,nil)
	local select=2
	if g1:GetCount()>0 and g2:GetCount()>0 then
		-- 玩家手卡同时存在「核成兽的钢核」和「核成」怪兽时，提供三个选项：送墓钢核、送墓怪兽、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(65026212,0),aux.Stringid(65026212,1),aux.Stringid(65026212,2))  --"选择一张「核成兽的钢核」送去墓地/选择一张名字带有「核成」的怪兽送去墓地/破坏「核成巨龙」"
	elseif g1:GetCount()>0 then
		-- 玩家手卡仅有「核成兽的钢核」时，提供两个选项：送墓钢核、破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(65026212,0),aux.Stringid(65026212,2))  --"选择一张「核成兽的钢核」送去墓地/破坏「核成巨龙」"
		if select==1 then select=2 end
	elseif g2:GetCount()>0 then
		-- 玩家手卡仅有「核成」怪兽时，提供两个选项：送墓怪兽、破坏自身，并对返回值进行偏移处理
		select=Duel.SelectOption(tp,aux.Stringid(65026212,1),aux.Stringid(65026212,2))+1  --"选择一张名字带有「核成」的怪兽送去墓地/破坏「核成巨龙」"
	else
		-- 玩家手卡没有可送墓的卡时，强制选择破坏自身
		select=Duel.SelectOption(tp,aux.Stringid(65026212,2))  --"破坏「核成巨龙」"
		select=2
	end
	if select==0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g1:Select(tp,1,1,nil)
		-- 将选择的「核成兽的钢核」作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	elseif select==1 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local g=g2:Select(tp,1,1,nil)
		-- 将选择的「核成」怪兽作为维持代价送去墓地
		Duel.SendtoGrave(g,REASON_COST)
	else
		-- 因未支付维持代价而破坏自身
		Duel.Destroy(c,REASON_COST)
	end
end
-- 过滤函数：手卡中可用于特殊召唤代价而除外的「核成兽的钢核」
function c65026212.spfilter(c)
	return c:IsCode(36623431) and c:IsAbleToRemoveAsCost()
end
-- 特殊召唤规则的条件函数：检查怪兽区域是否有空位，且手卡中是否存在可除外的「核成兽的钢核」
function c65026212.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡中是否存在至少1张可除外的「核成兽的钢核」
		and Duel.IsExistingMatchingCard(c65026212.spfilter,tp,LOCATION_HAND,0,1,nil)
end
-- 特殊召唤规则的目标选择函数：让玩家选择手卡中1张「核成兽的钢核」并记录
function c65026212.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己手卡中所有可除外的「核成兽的钢核」
	local g=Duel.GetMatchingGroup(c65026212.spfilter,tp,LOCATION_HAND,0,nil)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的操作函数：将选中的「核成兽的钢核」除外，完成特殊召唤
function c65026212.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将作为特殊召唤代价的卡片表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_SPSUMMON)
end
-- 破坏效果的选择目标函数：选择对方场上的1张卡为对象
function c65026212.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 效果发动时的合法性检查：对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上存在的1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的操作函数：将选中的对象卡破坏
function c65026212.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将选中的卡破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
