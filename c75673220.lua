--スナップドラゴン
-- 效果：
-- 这张卡被送去墓地时，对方手卡随机选择1张，直到结束阶段时表侧表示从游戏中除外。「龙口花」的效果1回合只能使用1次。
function c75673220.initial_effect(c)
	-- 这张卡被送去墓地时，对方手卡随机选择1张，直到结束阶段时表侧表示从游戏中除外。「龙口花」的效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(75673220,0))  --"手牌除外"
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCountLimit(1,75673220)
	e1:SetTarget(c75673220.target)
	e1:SetOperation(c75673220.operation)
	c:RegisterEffect(e1)
end
-- 效果发动的可行性检测与操作信息设置
function c75673220.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置当前连锁的操作信息为将对方手牌的1张卡除外
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_HAND)
end
-- 效果处理：随机除外对方1张手牌，并注册在结束阶段将其送回手牌的效果
function c75673220.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方手牌中可以被除外的卡片
	local g=Duel.GetMatchingGroup(Card.IsAbleToRemove,tp,0,LOCATION_HAND,nil)
	if g:GetCount()==0 then return end
	local rg=g:RandomSelect(tp,1)
	local tc=rg:GetFirst()
	-- 将随机选中的卡片表侧表示除外
	Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)
	tc:RegisterFlagEffect(75673220,RESET_EVENT+RESETS_STANDARD,0,1)
	-- 直到结束阶段时表侧表示从游戏中除外
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	e1:SetCountLimit(1)
	e1:SetLabelObject(tc)
	e1:SetCondition(c75673220.retcon)
	e1:SetOperation(c75673220.retop)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册在结束阶段时将除外卡片送回手牌的全局效果
	Duel.RegisterEffect(e1,tp)
end
-- 检查被除外的卡片是否仍带有标记，若无则重置此效果，若有则在结束阶段触发
function c75673220.retcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffect(75673220)==0 then
		e:Reset()
		return false
	else
		return true
	end
end
-- 在结束阶段将除外的卡片送回对方手牌
function c75673220.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将除外的卡片送回对方手牌
	Duel.SendtoHand(tc,1-tp,REASON_EFFECT)
end
