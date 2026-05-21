--宝玉の先導者
-- 效果：
-- ←5 【灵摆】 5→
-- ①：只要这张卡在灵摆区域存在，自己场上的「究极宝玉神」怪兽以及「宝玉兽」卡不会成为对方的效果的对象。
-- 【怪兽效果】
-- ①：把这张卡解放才能发动。「究极宝玉神」怪兽、「宝玉兽」怪兽、「宝玉」魔法·陷阱卡之内任意1张从卡组加入手卡。
function c87475570.initial_effect(c)
	-- 为卡片添加灵摆怪兽属性（注册灵摆召唤和灵摆卡的发动）
	aux.EnablePendulumAttribute(c)
	-- ①：只要这张卡在灵摆区域存在，自己场上的「究极宝玉神」怪兽以及「宝玉兽」卡不会成为对方的效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetTarget(c87475570.tgtg)
	-- 设置不会成为对方卡的效果的对象
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	-- ①：把这张卡解放才能发动。「究极宝玉神」怪兽、「宝玉兽」怪兽、「宝玉」魔法·陷阱卡之内任意1张从卡组加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(87475570,0))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c87475570.cost)
	e3:SetTarget(c87475570.target)
	e3:SetOperation(c87475570.operation)
	c:RegisterEffect(e3)
end
-- 过滤自己场上的「宝玉兽」卡以及怪兽区域的「究极宝玉神」怪兽
function c87475570.tgtg(e,c)
	return c:IsSetCard(0x1034) or (c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x2034))
end
-- 效果发动的代价：检查并解放自身
function c87475570.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsReleasable() end
	-- 解放自身作为发动代价
	Duel.Release(e:GetHandler(),REASON_COST)
end
-- 过滤卡组中可加入手牌的「宝玉兽」怪兽、「究极宝玉神」怪兽或「宝玉」魔法·陷阱卡
function c87475570.filter(c)
	return ((c:IsSetCard(0x1034,0x2034) and c:IsType(TYPE_MONSTER))
		or (c:IsSetCard(0x34) and c:IsType(TYPE_SPELL+TYPE_TRAP))) and c:IsAbleToHand()
end
-- 效果发动的目标：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function c87475570.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张满足过滤条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(c87475570.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组中的1张卡加入手牌的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果处理：从卡组选择1张满足条件的卡加入手牌并给对方确认
function c87475570.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c87475570.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
