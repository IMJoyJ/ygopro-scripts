--約束の地 －アヴァロン－
-- 效果：
-- ①：以包含「阿托利斯」怪兽以及「兰斯洛特」怪兽各1只的自己墓地5只「圣骑士」怪兽为对象才能发动。那些怪兽除外，场上的卡全部破坏。
function c82140600.initial_effect(c)
	-- ①：以包含「阿托利斯」怪兽以及「兰斯洛特」怪兽各1只的自己墓地5只「圣骑士」怪兽为对象才能发动。那些怪兽除外，场上的卡全部破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c82140600.target)
	e1:SetOperation(c82140600.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中属于「圣骑士」系列、是怪兽卡、可以被除外且可以作为效果对象的卡片
function c82140600.filter(c,e)
	return c:IsSetCard(0x107a) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemove() and c:IsCanBeEffectTarget(e)
end
-- 效果发动时的可行性检查：检查自己墓地中是否存在至少5只满足条件的「圣骑士」怪兽，且其中必须包含至少1只「阿托利斯」怪兽和1只「兰斯洛特」怪兽，同时场上必须存在至少1张卡
function c82140600.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 获取自己墓地中所有满足过滤条件的「圣骑士」怪兽
	local g=Duel.GetMatchingGroup(c82140600.filter,tp,LOCATION_GRAVE,0,nil,e)
	if chk==0 then return g:GetCount()>4
		and g:IsExists(Card.IsSetCard,1,nil,0xa7) and g:IsExists(Card.IsSetCard,1,nil,0xa8)
		-- 检查场上是否存在至少1张卡（用于确保有卡可以被破坏）
		and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要除外的卡（此处用于选择「阿托利斯」怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g1=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0xa7)
	g:Sub(g1)
	-- 提示玩家选择要除外的卡（此处用于选择「兰斯洛特」怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g2=g:FilterSelect(tp,Card.IsSetCard,1,1,nil,0xa8)
	g:Sub(g2)
	-- 提示玩家选择要除外的卡（此处用于选择剩余的3只「圣骑士」怪兽）
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local g3=g:Select(tp,3,3,nil)
	g1:Merge(g2)
	g1:Merge(g3)
	-- 将选定的5只怪兽设置为当前效果的对象
	Duel.SetTargetCard(g1)
	-- 获取场上的所有卡片（用于后续的破坏处理）
	local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 设置连锁操作信息，表示此效果包含将自己墓地的5张卡除外的操作
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g1,5,tp,LOCATION_GRAVE)
	-- 设置连锁操作信息，表示此效果包含破坏场上所有卡的操作
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,dg,dg:GetCount(),0,0)
end
-- 效果处理：将作为对象的5只怪兽除外，若成功除外5只，则将场上的卡全部破坏
function c82140600.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被设为效果对象的卡片组
	local tg=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local g=tg:Filter(Card.IsRelateToEffect,nil,e)
	-- 检查作为对象的卡片是否仍有5张，并将其表侧表示除外，若成功除外则继续执行破坏处理
	if g:GetCount()==5 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)>0 then
		-- 获取当前场上的所有卡片
		local dg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		-- 因效果破坏场上的所有卡片
		Duel.Destroy(dg,REASON_EFFECT)
	end
end
