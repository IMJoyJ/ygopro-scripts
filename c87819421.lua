--マスク・チャージ
-- 效果：
-- ①：以自己墓地1只「英雄」怪兽和1张「变化」速攻魔法卡为对象才能发动。那些卡加入手卡。
function c87819421.initial_effect(c)
	-- ①：以自己墓地1只「英雄」怪兽和1张「变化」速攻魔法卡为对象才能发动。那些卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetTarget(c87819421.target)
	e1:SetOperation(c87819421.activate)
	c:RegisterEffect(e1)
end
-- 过滤自己墓地中可以加入手卡的「英雄」怪兽
function c87819421.filter1(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤自己墓地中可以加入手卡的「变化」速攻魔法卡
function c87819421.filter2(c)
	return c:IsSetCard(0xa5) and c:IsType(TYPE_QUICKPLAY) and c:IsAbleToHand()
end
-- 效果发动时的对象选择与合法性检测
function c87819421.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return false end
	-- 检查自己墓地是否存在至少1只可以成为效果对象的「英雄」怪兽
	if chk==0 then return Duel.IsExistingTarget(c87819421.filter1,tp,LOCATION_GRAVE,0,1,nil)
		-- 检查自己墓地是否存在至少1张可以成为效果对象的「变化」速攻魔法卡
		and Duel.IsExistingTarget(c87819421.filter2,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1只「英雄」怪兽作为效果对象
	local g1=Duel.SelectTarget(tp,c87819421.filter1,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择自己墓地1张「变化」速攻魔法卡作为效果对象
	local g2=Duel.SelectTarget(tp,c87819421.filter2,tp,LOCATION_GRAVE,0,1,1,nil)
	g1:Merge(g2)
	-- 设置效果处理信息，表示将2张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g1,2,0,0)
end
-- 效果处理的执行函数，将选中的对象卡片加入手卡
function c87819421.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中作为效果对象的卡片组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	if sg:GetCount()>0 then
		-- 将仍符合条件的卡片加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
