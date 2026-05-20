--ラヴァル炎湖畔の淑女
-- 效果：
-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，把自己墓地存在的这张卡和1只名字带有「熔岩」的怪兽从游戏中除外才能发动。选择对方场上盖放的1张卡破坏。
function c8041569.initial_effect(c)
	-- 自己墓地有名字带有「熔岩」的怪兽3种类以上存在的场合，把自己墓地存在的这张卡和1只名字带有「熔岩」的怪兽从游戏中除外才能发动。选择对方场上盖放的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(8041569,0))  --"对方场上盖放的1张卡破坏"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c8041569.descon)
	e1:SetCost(c8041569.descost)
	e1:SetTarget(c8041569.destg)
	e1:SetOperation(c8041569.desop)
	c:RegisterEffect(e1)
end
-- 定义发动条件函数：检查自己墓地是否存在3种类以上的「熔岩」怪兽
function c8041569.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己墓地中所有「熔岩」怪兽，并判断其卡名种类是否在3种以上
	return Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_GRAVE,0,nil,0x39):GetClassCount(Card.GetCode)>=3
end
-- 定义过滤条件：自己墓地的「熔岩」怪兽且可以作为代价除外
function c8041569.cfilter(c)
	return c:IsSetCard(0x39) and c:IsAbleToRemoveAsCost()
end
-- 定义发动代价函数：检查自身是否能除外，且墓地是否存在除自身以外的另一只「熔岩」怪兽
function c8041569.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己墓地是否存在至少1张除自身以外的「熔岩」怪兽
		and Duel.IsExistingMatchingCard(c8041569.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家选择自己墓地中除自身以外的1张「熔岩」怪兽
	local g=Duel.SelectMatchingCard(tp,c8041569.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡片和自身作为代价表侧表示除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 定义过滤条件：处于里侧表示（盖放）的卡片
function c8041569.filter(c)
	return c:IsFacedown()
end
-- 定义效果目标函数：选择对方场上盖放的1张卡为对象，并设置破坏的操作信息
function c8041569.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c8041569.filter(chkc) end
	-- 检查对方场上是否存在至少1张盖放的卡
	if chk==0 then return Duel.IsExistingTarget(c8041569.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上盖放的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c8041569.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏该目标卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 定义效果处理函数：将作为对象的卡片破坏
function c8041569.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选择的对象卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsFacedown() and tc:IsRelateToEffect(e) then
		-- 将该卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
