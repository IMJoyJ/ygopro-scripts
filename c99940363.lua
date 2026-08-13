--帝王の凍気
-- 效果：
-- ①：自己场上有攻击力2400以上而守备力1000的怪兽存在的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
-- ②：从自己墓地把这张卡和1张「帝王」魔法·陷阱卡除外，以场上盖放的1张卡为对象才能发动。那张卡破坏。
function c99940363.initial_effect(c)
	-- ①：自己场上有攻击力2400以上而守备力1000的怪兽存在的场合，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99940363,0))  --"盖放的卡破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c99940363.condition)
	e1:SetTarget(c99940363.target)
	e1:SetOperation(c99940363.operation)
	c:RegisterEffect(e1)
	-- ②：从自己墓地把这张卡和1张「帝王」魔法·陷阱卡除外，以场上盖放的1张卡为对象才能发动。那张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(99940363,1))  --"把这张卡和1张「帝王」魔法·陷阱卡除外"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCost(c99940363.cost)
	e2:SetTarget(c99940363.target)
	e2:SetOperation(c99940363.operation)
	c:RegisterEffect(e2)
end
-- 过滤函数：判断怪兽是否为表侧表示，且攻击力在2400以上、守备力为1000。
function c99940363.mfilter(c)
	return c:IsFaceup() and c:IsAttackAbove(2400) and c:IsDefense(1000)
end
-- 效果①的发动条件函数：检查自己场上是否存在满足攻击力2400以上且守备力1000的表侧表示怪兽。
function c99940363.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 检查己方主要怪兽区是否存在至少1只满足mfilter条件的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(c99940363.mfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：判断是否为里侧表示（即盖放的卡）。
function c99940363.filter(c)
	return c:IsFacedown()
end
-- 效果①②共用的取对象发动处理：验证对象合法性、选择场上1张里侧表示卡作为对象，并设置破坏的操作信息。
function c99940363.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and c99940363.filter(chkc) and chkc~=e:GetHandler() end
	-- 发动合法性检查：确认场上是否存在至少1张符合条件的里侧表示卡（不是本卡）可以作为对象。
	if chk==0 then return Duel.IsExistingTarget(c99940363.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	-- 向玩家显示选择提示，要求选择要破坏的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从双方场上选择1张里侧表示卡（本卡除外）作为效果对象。
	local g=Duel.SelectTarget(tp,c99940363.filter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler())
	-- 设置本次连锁将执行破坏1张卡的操作信息，对象为g，供其他卡的效果检测使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理函数：取得对象卡，若其仍与该效果关联，则将其破坏。
function c99940363.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 取得发动时选择的那1张对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将对象卡以效果破坏并送入墓地。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- 过滤函数：判断墓地中的卡是否为「帝王」魔法·陷阱卡，并且可以作为除外的代价。
function c99940363.cfilter(c)
	return c:IsSetCard(0xbe) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- 效果②的代价检查：确认本卡本身可从墓地除外，且墓地存在1张满足条件的「帝王」魔法·陷阱卡（不包含本卡）。
function c99940363.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 继续代价检查：确认墓地存在至少1张除自身以外的「帝王」魔法·陷阱卡可作为除外代价。
		and Duel.IsExistingMatchingCard(c99940363.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 向玩家显示选择提示，要求选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从墓地选择1张「帝王」魔法·陷阱卡（不包含自身）作为代价。
	local g=Duel.SelectMatchingCard(tp,c99940363.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选择的卡和这张卡自身以正面表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
