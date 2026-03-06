--ドロー・ディスチャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的效果让对方抽卡时才能发动。对方抽到的那些卡全部确认。那之中有怪兽卡的场合，给与对方那个攻击力合计数值的伤害，确认的卡全部除外。
function c26557451.initial_effect(c)
	-- 效果原文内容：这个卡名的卡在1回合只能发动1张。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCountLimit(1,26557451+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c26557451.condition)
	e1:SetTarget(c26557451.target)
	e1:SetOperation(c26557451.activate)
	c:RegisterEffect(e1)
end
-- 效果作用：判断是否为对方的效果导致的抽卡
function c26557451.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and r&REASON_EFFECT~=0 and rp==1-tp
end
-- 效果作用：设置效果处理时需要确认的卡组并设置除外操作信息
function c26557451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果作用：检查玩家是否可以除外卡片
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	-- 效果作用：将目标卡组设置为当前连锁的对象
	Duel.SetTargetCard(g)
	-- 效果作用：设置操作信息为除外效果，目标玩家为对方，目标区域为手牌
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 效果原文内容：①：对方的效果让对方抽卡时才能发动。对方抽到的那些卡全部确认。那之中有怪兽卡的场合，给与对方那个攻击力合计数值的伤害，确认的卡全部除外。
function c26557451.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 效果作用：获取当前连锁的目标卡组并筛选出与效果相关的卡
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 效果作用：确认玩家手牌中的卡
		Duel.ConfirmCards(tp,g)
		local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		if #sg>0 then
			local atk=0
			local tc=sg:GetFirst()
			while tc do
				atk=atk+math.max(tc:GetAttack(),0)
				tc=sg:GetNext()
			end
			-- 效果作用：若攻击力总和大于0则对对方造成伤害
			if atk>0 and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
				-- 效果作用：将确认的卡全部除外
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
		-- 效果作用：将对方手牌洗切
		Duel.ShuffleHand(1-tp)
	end
end
