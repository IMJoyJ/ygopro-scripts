--星因士 プロキオン
-- 效果：
-- 「星因士 南河三」的效果1回合只能使用1次。
-- ①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。手卡1只「星骑士」怪兽送去墓地，自己从卡组抽1张。
function c99668578.initial_effect(c)
	-- 「星因士 南河三」的效果1回合只能使用1次。①：这张卡召唤·反转召唤·特殊召唤成功的场合才能发动。手卡1只「星骑士」怪兽送去墓地，自己从卡组抽1张。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(99668578,0))  --"送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,99668578)
	e1:SetTarget(c99668578.target)
	e1:SetOperation(c99668578.operation)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
	c99668578.star_knight_summon_effect=e3
end
-- 定义filter过滤函数：筛选手卡中的「星骑士」系列怪兽卡（setname 0x9c）且为怪兽卡，用于后续丢弃。
function c99668578.filter(c)
	return c:IsSetCard(0x9c) and c:IsType(TYPE_MONSTER)
end
-- 效果发动时的target函数：检查是否满足发动条件——自己可以抽1张卡，且手牌中存在至少1只可丢弃的「星骑士」怪兽；条件满足才可发动。
function c99668578.target(e,tp,eg,ep,ev,re,r,rp,chk,_,exc)
	-- 在发动条件检查中，首先确认自己能否通过效果抽1张卡（若不能抽卡则不能发动）。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1)
		-- 进一步检查手牌中是否存在至少1只符合filter条件的「星骑士」怪兽（排除exc指定的卡），作为发动条件之一。
		and Duel.IsExistingMatchingCard(c99668578.filter,tp,LOCATION_HAND,0,1,exc) end
	-- 设置操作信息：本效果处理时会把1张手牌送去墓地（不取对象，目标为自己，位置为手牌），用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：本效果处理时会让自己从卡组抽1张卡，用于连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 效果处理时的operation函数：从手卡丢弃1只「星骑士」怪兽；若丢弃成功，则自己从卡组抽1张卡。
function c99668578.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 让玩家从手卡选择并丢弃1只「星骑士」怪兽（以效果原因送去墓地）；若返回值非0说明丢弃成功，继续后续抽卡。
	if Duel.DiscardHand(tp,c99668578.filter,1,1,REASON_EFFECT)~=0 then
		-- 自己从卡组抽1张卡（以效果原因），对应效果文本中“自己从卡组抽1张”。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
