--精霊獣 ラムペンタ
-- 效果：
-- 自己对「精灵兽 心企太」1回合只能有1次特殊召唤。
-- ①：1回合1次，自己主要阶段才能发动。从额外卡组把1只「灵兽」怪兽除外，和那只怪兽相同种族的1只「灵兽」怪兽从卡组送去墓地。
function c88123329.initial_effect(c)
	c:SetSPSummonOnce(88123329)
	-- ①：1回合1次，自己主要阶段才能发动。从额外卡组把1只「灵兽」怪兽除外，和那只怪兽相同种族的1只「灵兽」怪兽从卡组送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(c88123329.target)
	e1:SetOperation(c88123329.operation)
	c:RegisterEffect(e1)
end
-- 过滤卡组中满足条件的「灵兽」怪兽：属于指定种族且能送去墓地
function c88123329.tgfilter(c,rac)
	return c:IsSetCard(0xb5) and c:IsRace(rac) and c:IsAbleToGrave()
end
-- 过滤额外卡组中满足条件的「灵兽」怪兽：可以被除外，且卡组中存在与其相同种族的「灵兽」怪兽
function c88123329.rmfilter(c,tp)
	return c:IsSetCard(0xb5) and c:IsAbleToRemove()
		-- 检查卡组中是否存在至少1只与该卡相同种族且能送去墓地的「灵兽」怪兽
		and Duel.IsExistingMatchingCard(c88123329.tgfilter,tp,LOCATION_DECK,0,1,nil,c:GetRace())
end
-- 效果①的发动准备与合法性检查，检查额外卡组是否存在可除外的「灵兽」怪兽，并设置除外和送去墓地的操作信息
function c88123329.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查额外卡组中是否存在至少1只满足除外条件的「灵兽」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c88123329.rmfilter,tp,LOCATION_EXTRA,0,1,nil,tp) end
	-- 设置操作信息：从额外卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_EXTRA)
	-- 设置操作信息：从卡组将1张卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果①的效果处理：从额外卡组除外1只「灵兽」怪兽，再从卡组将1只相同种族的「灵兽」怪兽送去墓地
function c88123329.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从额外卡组选择1只满足条件的「灵兽」怪兽
	local g=Duel.SelectMatchingCard(tp,c88123329.rmfilter,tp,LOCATION_EXTRA,0,1,1,nil,tp)
	-- 若成功选择并表侧表示除外该怪兽，则继续执行后续处理
	if g:GetCount()>0 and Duel.Remove(g,POS_FACEUP,REASON_EFFECT)~=0 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从卡组选择1只与除外怪兽相同种族的「灵兽」怪兽
		local sg=Duel.SelectMatchingCard(tp,c88123329.tgfilter,tp,LOCATION_DECK,0,1,1,nil,g:GetFirst():GetRace())
		-- 将选择的卡送去墓地
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
