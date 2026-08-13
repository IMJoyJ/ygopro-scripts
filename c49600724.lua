--異次元への隙間
-- 效果：
-- 宣言1个属性，选择双方墓地存在的宣言的属性的怪兽合计2只发动。选择的怪兽从游戏中除外。
function c49600724.initial_effect(c)
	-- 宣言1个属性，选择双方墓地存在的宣言的属性的怪兽合计2只发动。选择的怪兽从游戏中除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(c49600724.target)
	e1:SetOperation(c49600724.activate)
	c:RegisterEffect(e1)
end
-- 筛选可作为效果对象且能被除外的墓地怪兽。
function c49600724.filter(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeEffectTarget(e) and c:IsAbleToRemove()
end
-- 检查集合g中是否存在与怪兽c属性相同的另一只怪兽，以保证可选两只同属性怪兽。
function c49600724.filter1(c,g)
	return g:IsExists(Card.IsAttribute,1,c,c:GetAttribute())
end
-- 效果发动时的目标处理：先验证合法性，再从双方墓地选出同属性怪兽候选，计算可宣言属性，让玩家宣言属性并选择2只该属性怪兽，然后设置为效果对象并登记除外操作信息。
function c49600724.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and c49600724.filter(chkc,e) end
	if chk==0 then
		-- 在发动合法性判定时，获取双方墓地中满足除外条件的怪兽集合，用于检查是否存在至少一对同属性怪兽。
		local g=Duel.GetMatchingGroup(c49600724.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
		return g:IsExists(c49600724.filter1,1,nil,g)
	end
	-- 在效果发动选择时，再次获取双方墓地中满足除外条件的怪兽集合，作为后续筛选和选对象的候选组。
	local g=Duel.GetMatchingGroup(c49600724.filter,tp,LOCATION_GRAVE,LOCATION_GRAVE,nil,e)
	local rg=g:Filter(c49600724.filter1,nil,g)
	local tc=rg:GetFirst()
	local att=0
	while tc do
		att=bit.bor(att,tc:GetAttribute())
		tc=rg:GetNext()
	end
	-- 提示玩家接下来需要宣言属性（显示属性选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTRIBUTE)  --"请选择要宣言的属性"
	-- 让玩家从可选属性中宣言1个属性，并返回该属性值。
	local ac=Duel.AnnounceAttribute(tp,1,att)
	-- 提示玩家接下来需要选择要除外的卡（显示卡牌选择消息）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local sg=rg:FilterSelect(tp,Card.IsAttribute,2,2,nil,ac)
	-- 将选择的两只怪兽设为该连锁效果的对象卡。
	Duel.SetTargetCard(sg)
	-- 登记除外操作信息：效果处理时将sg中的2张卡从双方墓地表侧除外。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,2,PLAYER_ALL,LOCATION_GRAVE)
end
-- 效果处理：取得连锁对象，筛选出仍与该效果相关的卡，然后进行除外。
function c49600724.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁处理中的对象卡组（即发动时选择的两只怪兽）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 将筛选后的对象卡以表侧表示除外，作为效果处理结果。
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
