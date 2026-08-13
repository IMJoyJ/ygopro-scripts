--ドロー・ディスチャージ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：对方的效果让对方抽卡时才能发动。对方抽到的那些卡全部确认。那之中有怪兽卡的场合，给与对方那个攻击力合计数值的伤害，确认的卡全部除外。
function c26557451.initial_effect(c)
	-- 对应效果原文：“这个卡名的卡在1回合只能发动1张。①：对方的效果让对方抽卡时才能发动。对方抽到的那些卡全部确认。那之中有怪兽卡的场合，给与对方那个攻击力合计数值的伤害，确认的卡全部除外。”
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
-- 发动条件判定：仅在对方因对方的效果抽卡时（抽卡玩家是对方、抽卡原因为效果、效果控制者为对方）才能发动。
function c26557451.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and r&REASON_EFFECT~=0 and rp==1-tp
end
-- 发动时的处理：将对方抽到的卡筛选出来登记为连锁对象，并设置除外手牌的操作信息，以在效果处理时对这些卡进行确认和除外。
function c26557451.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：检查当前玩家是否能够执行除外操作，若不能除外则不能发动。
	if chk==0 then return Duel.IsPlayerCanRemove(tp) end
	local g=eg:Filter(Card.IsControler,nil,1-tp)
	-- 将对方抽到的那些卡登记为当前连锁的对象，与效果建立关联，供后续处理时确认与除外使用。
	Duel.SetTargetCard(g)
	-- 设置操作信息：宣布本效果涉及除外对方手牌中的卡，目标玩家为对方，位置为手牌，数量暂不确定。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,0,1-tp,LOCATION_HAND)
end
-- 效果处理：取出并过滤仍与本效果关联的对方抽到的卡；确认这些卡；从中筛选出怪兽并计算攻击力合计；若伤害成功则将这些卡全部除外；最后洗切对方手牌。
function c26557451.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中登记的对象卡，并筛选出仍与本效果有关联的卡（排除已离场或关联已重置的卡）。
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(Card.IsRelateToEffect,nil,e)
	if #g>0 then
		-- 由发动者确认这些卡，即展示对方抽到的卡。
		Duel.ConfirmCards(tp,g)
		local sg=g:Filter(Card.IsType,nil,TYPE_MONSTER)
		if #sg>0 then
			local atk=0
			local tc=sg:GetFirst()
			while tc do
				atk=atk+math.max(tc:GetAttack(),0)
				tc=sg:GetNext()
			end
			-- 若怪兽攻击力合计大于0，且给与对方伤害成功（实际伤害不为0，未被无效或变成回复），才执行后续的除外处理。
			if atk>0 and Duel.Damage(1-tp,atk,REASON_EFFECT)~=0 then
				-- 将确认的全部卡以表侧表示除外。
				Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
			end
		end
		-- 洗切对方手牌，因为手牌曾被公开确认，需要重新随机化。
		Duel.ShuffleHand(1-tp)
	end
end
