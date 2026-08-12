--魔女の聖夜行
local s,id,o=GetID()
-- 创建场地魔法卡的通用发动效果，使卡能够被正常发动
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 此卡的起动效果，可以检索并加入手牌一张魔女族怪兽，同时自己须丢弃1张手牌
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_HANDES)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- 场地区效果，仅在自己的回合时生效，用于触发其他效果
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(id)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(1,0)
	e3:SetCondition(s.effcon)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选魔女族怪兽且能加入手牌的卡片
function s.thfilter(c)
	return c:IsSetCard(0x128) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 效果的发动条件判断，检查卡组中是否存在满足条件的卡片
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在至少1张魔女族怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置连锁信息，表示将从卡组检索1张卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	-- 设置连锁信息，表示自己须丢弃1张手牌
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
-- 效果的处理函数，执行检索、加入手牌和丢弃手牌的操作
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的1张魔女族怪兽从卡组加入手牌
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	-- 判断是否成功将卡加入手牌并确认其位置在手牌中
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)~=0 and g:GetFirst():IsLocation(LOCATION_HAND) then
		-- 向对方确认自己加入手牌的卡片
		Duel.ConfirmCards(1-tp,g)
		-- 中断当前效果处理，防止连锁错时
		Duel.BreakEffect()
		-- 提示玩家选择要丢弃的手牌
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
		-- 选择满足条件的1张可丢弃的手牌
		local dg=Duel.SelectMatchingCard(tp,Card.IsDiscardable,tp,LOCATION_HAND,0,1,1,nil,REASON_EFFECT)
		-- 将自己的手牌洗切
		Duel.ShuffleHand(tp)
		-- 将选中的手牌送入墓地
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	end
end
-- 判断场地区效果是否生效，仅在自己的回合时触发
function s.effcon(e)
	-- 判断当前回合玩家是否为该卡的持有者
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
