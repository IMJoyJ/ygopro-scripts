--十二獣サラブレード
-- 效果：
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡丢弃1张「十二兽」卡，自己从卡组抽1张。
-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。
-- ●这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
function c77150143.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从手卡丢弃1张「十二兽」卡，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(77150143,0))
	e1:SetCategory(CATEGORY_HANDES_SELF+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetTarget(c77150143.drtg)
	e1:SetOperation(c77150143.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：持有这张卡作为素材中的原本种族是兽战士族的超量怪兽得到以下效果。●这张卡向守备表示怪兽攻击的场合，给与攻击力超过那个守备力的数值的战斗伤害。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_XMATERIAL)
	e3:SetCode(EFFECT_PIERCE)
	e3:SetCondition(c77150143.condition)
	c:RegisterEffect(e3)
end
-- 过滤手牌中可以因效果丢弃的「十二兽」卡片
function c77150143.filter(c)
	return c:IsSetCard(0xf1) and c:IsDiscardable(REASON_EFFECT)
end
-- 效果①的发动准备与合法性检测：检查玩家是否能抽卡，以及手牌中是否存在可丢弃的「十二兽」卡
function c77150143.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家当前是否具有抽1张卡的效果许可
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 并且检查自己手牌中是否存在至少1张满足过滤条件的「十二兽」卡
		and Duel.IsExistingMatchingCard(c77150143.filter,tp,LOCATION_HAND,0,1,nil) end
	-- 设置连锁处理中的操作信息为：玩家从卡组抽1张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果①的效果处理：让玩家从手牌丢弃1张「十二兽」卡，若成功丢弃则抽1张卡
function c77150143.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家选择手牌中1张满足过滤条件的「十二兽」卡因效果丢弃，并检查是否成功丢弃
	if Duel.DiscardHand(tp,c77150143.filter,1,1,REASON_EFFECT+REASON_DISCARD,nil)~=0 then
		-- 玩家因效果从卡组抽1张卡
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
-- 检查持有此卡作为素材的超量怪兽的原本种族是否为兽战士族
function c77150143.condition(e)
	return e:GetHandler():GetOriginalRace()==RACE_BEASTWARRIOR
end
