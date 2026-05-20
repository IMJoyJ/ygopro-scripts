--氷魔龍 ブリューナク
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到手卡。
-- ②：这张卡从墓地特殊召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到手卡。
local s,id,o=GetID()
-- 注册卡片效果，包括同调召唤手续、同调召唤成功时发动的效果，以及克隆该效果并修改为从墓地特殊召唤成功时发动的效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置同调召唤手续：调整＋调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	-- ①：这张卡同调召唤的场合，丢弃1张手卡，以场上1张卡为对象才能发动。那张卡回到手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(s.scon)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.gcon)
	c:RegisterEffect(e2)
end
-- 检查此卡是否是通过同调召唤的方式特殊召唤
function s.scon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 丢弃1张手卡作为代价的处理
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手卡中是否存在至少1张可以丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 玩家选择并丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 效果发动时的对象选择与操作信息注册处理
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsAbleToHand() end
	-- 检查场上是否存在至少1张可以回到手牌的卡作为可选对象
	if chk==0 then return Duel.IsExistingTarget(Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要返回手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 玩家选择场上1张可以回到手牌的卡作为效果的对象
	local g=Duel.SelectTarget(tp,Card.IsAbleToHand,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	-- 设置当前连锁的操作信息为“将选中的1张卡送回手牌”
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果处理时，将选中的对象卡送回手牌
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中被选为对象的卡
	local tc=Duel.GetFirstTarget()
	-- 若对象卡在效果处理时仍与该效果相关联，则将其送回持有者手牌
	if tc:IsRelateToEffect(e) then Duel.SendtoHand(tc,nil,REASON_EFFECT) end
end
-- 检查此卡特殊召唤前的位置是否为墓地（即是否从墓地特殊召唤）
function s.gcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
