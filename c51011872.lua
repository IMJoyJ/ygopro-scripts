--トリックスター・ブラッディマリー
-- 效果：
-- 「淘气仙星」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，自己回复200基本分。
-- ②：从手卡丢弃1张「淘气仙星」卡才能发动。双方玩家各自从卡组抽1张。这个效果的发动时自己基本分比对方多2000以上的场合，这个效果让自己抽出的数量变成2张。
function c51011872.initial_effect(c)
	-- 添加连接召唤手续，要求使用2个以上且最多2个满足过滤条件的「淘气仙星」怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkSetCard,0xfb),2,2)
	c:EnableReviveLimit()
	-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，自己回复200基本分。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c51011872.reccon)
	e1:SetOperation(c51011872.recop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：从手卡丢弃1张「淘气仙星」卡才能发动。双方玩家各自从卡组抽1张。这个效果的发动时自己基本分比对方多2000以上的场合，这个效果让自己抽出的数量变成2张。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(51011872,0))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,51011872)
	e3:SetCost(c51011872.drcost)
	e3:SetTarget(c51011872.drtg)
	e3:SetOperation(c51011872.drop)
	c:RegisterEffect(e3)
end
-- 判断召唤或特殊召唤的怪兽是否在该卡的连接区中，用于触发①效果的条件判断
function c51011872.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xfb) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0xfb) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- 检查是否有满足条件的怪兽被召唤或特殊召唤，以决定是否触发①效果
function c51011872.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51011872.cfilter,1,nil,e:GetHandler())
end
-- 当满足条件时，使自己回复200基本分
function c51011872.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家发送提示信息，显示该卡发动的效果动画
	Duel.Hint(HINT_CARD,0,51011872)
	-- 使玩家回复200基本分
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- 定义丢弃手牌的过滤条件，必须是可丢弃且为「淘气仙星」卡
function c51011872.costfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0xfb)
end
-- 检查是否满足丢弃1张「淘气仙星」卡作为效果发动的代价
function c51011872.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断是否存在至少1张满足条件的手牌可用于丢弃
	if chk==0 then return Duel.IsExistingMatchingCard(c51011872.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 执行丢弃1张符合条件的手牌的操作
	Duel.DiscardHand(tp,c51011872.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 计算抽卡数量，若自己基本分比对方多2000以上则抽2张
function c51011872.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=1
	-- 如果自己基本分比对方多2000以上，则将抽卡数设为2
	if Duel.GetLP(tp)>=Duel.GetLP(1-tp)+2000 then ct=2 end
	-- 判断是否可以让自己和对方各抽指定数量的卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct)
		-- 判断是否可以让自己和对方各抽1张卡
		and Duel.IsPlayerCanDraw(1-tp,1) end
	e:SetLabel(ct)
	-- 设置操作信息，表示双方各抽1张卡的效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- 执行效果，使自己和对方各抽指定数量的卡
function c51011872.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 使玩家抽指定数量的卡
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
	-- 使对方抽1张卡
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
