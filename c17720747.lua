--黒薔薇の魔女
-- 效果：
-- 这张卡不能特殊召唤。
-- ①：自己场上没有其他卡存在，这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是怪兽以外的场合，那张卡送去墓地，这张卡破坏。
function c17720747.initial_effect(c)
	-- 效果原文：这张卡不能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	c:RegisterEffect(e1)
	-- 效果原文：①：自己场上没有其他卡存在，这张卡召唤成功的场合发动。自己从卡组抽1张，给双方确认。那是怪兽以外的场合，那张卡送去墓地，这张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(17720747,0))  --"抽卡"
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCondition(c17720747.condition)
	e2:SetTarget(c17720747.target)
	e2:SetOperation(c17720747.operation)
	c:RegisterEffect(e2)
end
-- 规则层面：判断场上是否只有自己这张卡（不含魔法陷阱）
function c17720747.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：场上自己怪兽数量小于等于1时满足条件
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD,0)<=1
end
-- 规则层面：设置效果处理时的抽卡操作信息
function c17720747.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 规则层面：设置抽卡效果的目标为对方玩家，数量为1
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 规则层面：执行效果的处理流程，包括抽卡、确认、判定是否为怪兽、处理墓地与破坏
function c17720747.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 规则层面：获取玩家卡组最上方的1张卡
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 规则层面：让玩家从卡组抽1张卡
	Duel.Draw(tp,1,REASON_EFFECT)
	if tc then
		-- 规则层面：给对方确认抽到的卡
		Duel.ConfirmCards(1-tp,tc)
		if not tc:IsType(TYPE_MONSTER) then
			-- 规则层面：中断当前连锁处理，使后续效果视为不同时处理
			Duel.BreakEffect()
			-- 规则层面：将确认的卡送去墓地
			Duel.SendtoGrave(tc,REASON_EFFECT)
			if e:GetHandler():IsRelateToEffect(e) then
				-- 规则层面：破坏自身
				Duel.Destroy(e:GetHandler(),REASON_EFFECT)
			end
		end
		-- 规则层面：洗切自己的手牌
		Duel.ShuffleHand(tp)
	end
end
