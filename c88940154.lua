--武神器－ハチ
-- 效果：
-- 自己的主要阶段时，自己场上有名字带有「武神」的兽战士族怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。选择对方场上1张魔法·陷阱卡破坏。「武神器-蜂」的效果1回合只能使用1次。
function c88940154.initial_effect(c)
	-- 自己的主要阶段时，自己场上有名字带有「武神」的兽战士族怪兽存在的场合，把墓地的这张卡从游戏中除外才能发动。选择对方场上1张魔法·陷阱卡破坏。「武神器-蜂」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(88940154,0))  --"魔陷破坏"
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,88940154)
	e1:SetCondition(c88940154.descon)
	-- 设置发动代价为：把墓地的这张卡除外
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c88940154.destg)
	e1:SetOperation(c88940154.desop)
	c:RegisterEffect(e1)
end
-- 过滤条件：表侧表示且名字带有「武神」的兽战士族怪兽
function c88940154.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x88) and c:IsRace(RACE_BEASTWARRIOR)
end
-- 发动条件判定：自己场上是否存在满足条件的怪兽
function c88940154.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己场上是否存在至少1只表侧表示的「武神」兽战士族怪兽
	return Duel.IsExistingMatchingCard(c88940154.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤条件：魔法或陷阱卡
function c88940154.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果发动目标选择与判定
function c88940154.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) and c88940154.filter(chkc) end
	-- 发动判定：对方场上是否存在可以作为对象的魔法·陷阱卡
	if chk==0 then return Duel.IsExistingTarget(c88940154.filter,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张魔法·陷阱卡作为效果对象
	local g=Duel.SelectTarget(tp,c88940154.filter,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置效果处理信息：破坏选中的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 效果处理：破坏选中的卡
function c88940154.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片因效果破坏
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
