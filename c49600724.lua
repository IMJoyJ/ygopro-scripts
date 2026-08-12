--異次元への隙間
-- 效果：
-- 宣言1个属性，选择双方墓地存在的宣言的属性的怪兽合计2只发动。选择的怪兽从游戏中除外。
function c49600724.initial_effect(c)
	-- 效果设置：将此卡注册为发动时点为自由时点的魔法卡，具有除外效果并可指定对象
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49600724.target)
	e1:SetOperation(c49600724.activate)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查目标卡片是否为怪兽、可成为效果对象且可被除外
function c49600724.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
-- 过滤函数：检查目标卡片属性是否在给定卡片组中存在
function c49600724.filter1(c,g)
	return g:IsExists(Card.IsAttribute,1,c,c:GetAttribute())
end
-- 效果处理：判断是否满足发动条件，若满足则选择双方墓地符合条件的怪兽并宣言属性，再选择2只怪兽进行除外
function c49600724.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c49600724.filter(chkc,e) end
	if chk==0 then
		-- 检索满足条件的墓地怪兽组
		local g=Duel.GetMatchingGroup(c49600724.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
		return g:IsExists(c49600724.filter1,1,nil,g)
	end
	-- 检索满足条件的墓地怪兽组
	local g=Duel.GetMatchingGroup(c49600724.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	local rg=g:Filter(c49600724.filter1,nil,g)
	local tc=rg:GetFirst()
	local att=0
	while tc do
		att=bit.bor(att,tc:GetAttribute())
		tc=rg:GetNext()
	end
	-- 提示玩家选择要宣言的属性
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言一个属性
	local ac=Duel.AnnounceAttribute(tp,1,att)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:FilterSelect(tp,Card.IsAttribute,2,2,nil,ac)
	-- 设置本次效果的目标卡片为所选的2只怪兽
	Duel.SetTargetCard(sg)
	-- 设置本次效果的操作信息为除外2只怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果发动：将目标卡片从游戏中除外
function c49600724.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将目标卡片以正面表示的形式从游戏中除外
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
