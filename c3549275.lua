--ダイス・ポット
-- 效果：
-- 反转：双方各自投掷1个骰子。投掷出来的数目比另一方低的玩家，受到（另一方投掷出的数目×500）的基本分的伤害。如果输给投掷出数目6的场合，输的玩家受到的是6000分的伤害。平局的场合再掷1次。
function c3549275.initial_effect(c)
	-- 反转效果：双方各自投掷1个骰子。投掷出来的数目比另一方低的玩家，受到（另一方投掷出的数目×500）的基本分的伤害。如果输给投掷出数目6的场合，输的玩家受到的是6000分的伤害。平局的场合再掷1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c3549275.target)
	e1:SetOperation(c3549275.operation)
	c:RegisterEffect(e1)
end
-- 设置连锁操作信息，表明此效果涉及骰子投掷
function c3549275.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置连锁操作信息，表明此效果涉及骰子投掷
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
end
-- 执行骰子投掷并根据结果判定伤害
function c3549275.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1=0
	local d2=0
	while d1==d2 do
		-- 让双方各投掷一次骰子
		d1,d2=Duel.TossDice(tp,1,1)
	end
	if d1<d2 then
		if d2==6 then
			-- 对投掷结果较小的玩家造成6000点伤害
			Duel.Damage(tp,6000,REASON_EFFECT)
		elseif d2>=2 and d2<=5 then
			-- 对投掷结果较小的玩家造成对应点数乘以500的伤害
			Duel.Damage(tp,d2*500,REASON_EFFECT)
		end
	else
		if d1==6 then
			-- 对投掷结果较大的玩家造成6000点伤害
			Duel.Damage(1-tp,6000,REASON_EFFECT)
		elseif d1>=2 and d1<=5 then
			-- 对投掷结果较大的玩家造成对应点数乘以500的伤害
			Duel.Damage(1-tp,d1*500,REASON_EFFECT)
		end
	end
end
