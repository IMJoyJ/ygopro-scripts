--イリュージョン・マジック
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：把自己场上1只魔法师族怪兽解放才能发动。从自己的卡组·墓地选最多2只「黑魔术师」加入手卡。
function c73616671.initial_effect(c)
	-- 注册卡片记有「黑魔术师」卡名的信息
	aux.AddCodeList(c,46986414)
	-- 这个卡名的卡在1回合只能发动1张。①：把自己场上1只魔法师族怪兽解放才能发动。从自己的卡组·墓地选最多2只「黑魔术师」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,73616671+EFFECT_COUNT_CODE_OATH)
	e1:SetCost(c73616671.cost)
	e1:SetTarget(c73616671.target)
	e1:SetOperation(c73616671.activate)
	c:RegisterEffect(e1)
end
-- 发动代价（Cost）处理函数：解放自己场上1只魔法师族怪兽
function c73616671.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在可解放的魔法师族怪兽
	if chk==0 then return Duel.CheckReleaseGroup(tp,Card.IsRace,1,nil,RACE_SPELLCASTER) end
	-- 选择自己场上1只魔法师族怪兽
	local g=Duel.SelectReleaseGroup(tp,Card.IsRace,1,1,nil,RACE_SPELLCASTER)
	-- 将选择的怪兽解放
	Duel.Release(g,REASON_COST)
end
-- 过滤条件：卡名为「黑魔术师」且能加入手卡
function c73616671.filter(c)
	return c:IsCode(46986414) and c:IsAbleToHand()
end
-- 发动效果的目标（Target）处理函数：检查并设置检索/回收信息
function c73616671.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己的卡组或墓地是否存在至少1张「黑魔术师」
	if chk==0 then return Duel.IsExistingMatchingCard(c73616671.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 设置操作信息为：从卡组或墓地将卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 效果处理（Operation）函数：从卡组或墓地选最多2只「黑魔术师」加入手卡
function c73616671.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组或墓地选择1到2张不受「王家长眠之谷」影响的「黑魔术师」
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c73616671.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,2,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
