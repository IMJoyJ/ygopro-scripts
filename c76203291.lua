--光鱗のトビウオ
-- 效果：
-- 把自己场上存在的这张卡以外的1只鱼族怪兽解放发动。场上1张卡破坏。
function c76203291.initial_effect(c)
	-- 把自己场上存在的这张卡以外的1只鱼族怪兽解放发动。场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(76203291,0))  --"破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(c76203291.cost)
	e1:SetTarget(c76203291.target)
	e1:SetOperation(c76203291.operation)
	c:RegisterEffect(e1)
end
-- 发动代价处理：检查并解放自己场上这张卡以外的1只鱼族怪兽
function c76203291.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动检测时，检查自己场上是否存在除这张卡以外、可解放的鱼族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,e:GetHandler(),RACE_FISH) end
	-- 玩家选择自己场上除这张卡以外的1只可解放的鱼族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,e:GetHandler(),RACE_FISH)
	-- 解放选中的怪兽作为发动代价
	Duel.Release(g,REASON_COST)
end
-- 效果目标处理：选择场上1张卡作为破坏对象
function c76203291.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	-- 在发动检测时，检查场上是否存在可以作为效果对象的卡
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家选择场上1张卡作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置操作信息，表示该效果的处理为破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果运行处理：破坏选中的卡
function c76203291.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取发动时选择的效果对象
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		-- 因效果破坏该目标卡片
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
