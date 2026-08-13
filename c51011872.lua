--トリックスター・ブラッディマリー
-- 效果：
-- 「淘气仙星」怪兽2只
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，每次这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤，自己回复200基本分。
-- ②：从手卡丢弃1张「淘气仙星」卡才能发动。双方玩家各自从卡组抽1张。这个效果的发动时自己基本分比对方多2000以上的场合，这个效果让自己抽出的数量变成2张。
function c51011872.initial_effect(c)
	-- 为这张卡添加连接召唤手续：需要且仅需要2只卡名带有「淘气仙星」字段的怪兽作为连接素材，对应召唤条件「淘气仙星」怪兽2只。
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
	-- 这个卡名的②的效果1回合只能使用1次。②：从手卡丢弃1张「淘气仙星」卡才能发动。双方玩家各自从卡组抽1张。这个效果的发动时自己基本分比对方多2000以上的场合，这个效果让自己抽出的数量变成2张。
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
-- 召唤/特殊召唤成功的怪兽判定过滤器：若该怪兽现在位于怪兽区域，则要求其为表侧表示且持有「淘气仙星」字段，并处于这张卡的连接区；若已不在怪兽区域，则要求其移动前为表侧表示且持有「淘气仙星」字段，且移动前所在位置位于这张卡的连接区（用连接区bit位检查）。用于确认是否满足“这张卡所连接区有「淘气仙星」怪兽召唤·特殊召唤”。
function c51011872.cfilter(c,ec)
	if c:IsLocation(LOCATION_MZONE) then
		return c:IsSetCard(0xfb) and c:IsFaceup() and ec:GetLinkedGroup():IsContains(c)
	else
		return c:IsPreviousSetCard(0xfb) and c:IsPreviousPosition(POS_FACEUP)
			and bit.extract(ec:GetLinkedZone(c:GetPreviousControler()),c:GetPreviousSequence())~=0
	end
end
-- ①效果的触发条件：在召唤·特殊召唤成功事件中，存在至少1只满足cfilter条件的「淘气仙星」怪兽（即被召唤/特殊召唤到这张卡的连接区），才发动回复效果。
function c51011872.reccon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c51011872.cfilter,1,nil,e:GetHandler())
end
-- ①效果的操作：先展示这张卡的卡图提示，然后让这张卡的控制者回复200基本分。
function c51011872.recop(e,tp,eg,ep,ev,re,r,rp)
	-- 向双方玩家展示这张卡的卡图动画，提示这里正在处理这张卡的①回复效果（不入连锁的回复）。
	Duel.Hint(HINT_CARD,0,51011872)
	-- 让这张卡的控制者回复200基本分，回复原因记为效果。
	Duel.Recover(tp,200,REASON_EFFECT)
end
-- ②效果的代价筛选函数：手卡中可以被丢弃且持有「淘气仙星」字段的卡，即作为丢弃代价的「淘气仙星」卡。
function c51011872.costfilter(c)
	return c:IsDiscardable() and c:IsSetCard(0xfb)
end
-- ②效果的代价处理：先在发动前检查手卡是否存在1张满足costfilter的「淘气仙星」卡；若存在，则从手卡丢弃1张符合条件的卡作为发动代价（原因包含代价和丢弃）。
function c51011872.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价检查阶段（chk==0）判断手卡中是否存在至少1张可丢弃的「淘气仙星」卡，作为能否发动②效果的前提。
	if chk==0 then return Duel.IsExistingMatchingCard(c51011872.costfilter,tp,LOCATION_HAND,0,1,nil) end
	-- 实际执行代价：从手卡中选择并丢弃1张「淘气仙星」卡，丢弃原因同时标记为代价和丢弃。
	Duel.DiscardHand(tp,c51011872.costfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- ②效果的发动条件/目标设定：默认自己抽1张，若自己LP比对方多2000以上则改为2张；在合法检查阶段确认双方都能抽对应数量的卡，并把本次自己应抽的张数存入e:SetLabel，同时设置操作信息。
function c51011872.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=1
	-- 若自己的LP不低于对方LP+2000，则本次自己抽卡数量设为2张，否则为1张。
	if Duel.GetLP(tp)>=Duel.GetLP(1-tp)+2000 then ct=2 end
	-- 检查自己是否能够效果抽ct张卡（ct为1或2），不能则②效果无法发动。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,ct)
		-- 检查对方是否能够效果抽1张卡，确保双方都能抽卡时才满足发动条件。
		and Duel.IsPlayerCanDraw(1-tp,1) end
	e:SetLabel(ct)
	-- 设置当前连锁的操作信息为抽卡效果，目标玩家为双方，预计抽卡数量为1，用于诱发相关效果的判定（如「星尘龙」等）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,PLAYER_ALL,1)
end
-- ②效果处理：实际执行双方抽卡，先让自己抽取e:GetLabel()张（1或2），再让对方抽取1张，均为效果抽卡。
function c51011872.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 让自己抽出预先设定数量的卡（1或2张），抽卡原因为效果。
	Duel.Draw(tp,e:GetLabel(),REASON_EFFECT)
	-- 让对方抽1张卡，抽卡原因为效果。
	Duel.Draw(1-tp,1,REASON_EFFECT)
end
