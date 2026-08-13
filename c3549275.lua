--ダイス・ポット
-- 效果：
-- 反转：双方各自投掷1个骰子。投掷出来的数目比另一方低的玩家，受到（另一方投掷出的数目×500）的基本分的伤害。如果输给投掷出数目6的场合，输的玩家受到的是6000分的伤害。平局的场合再掷1次。
function c3549275.initial_effect(c)
	-- 反转：双方各自投掷1个骰子。投掷出来的数目比另一方低的玩家，受到（另一方投掷出的数目×500）的基本分的伤害。如果输给投掷出数目6的场合，输的玩家受到的是6000分的伤害。平局的场合再掷1次。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DICE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetTarget(c3549275.target)
	e1:SetOperation(c3549275.operation)
	c:RegisterEffect(e1)
end
-- 反转效果发动时的目标判定函数：确认效果可以正常发动（无特殊条件），并向系统登记本效果涉及掷骰子。
function c3549275.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记操作信息：该效果属于骰子效果，由双方玩家各进行1次掷骰子。
	Duel.SetOperationInfo(0,CATEGORY_DICE,nil,0,PLAYER_ALL,1)
end
-- 反转效果处理函数：反复投掷双方骰子直到点数不同，再根据骰子点数对输方造成对应伤害。
function c3549275.operation(e,tp,eg,ep,ev,re,r,rp)
	local d1=0
	local d2=0
	while d1==d2 do
		-- 让当前玩家tp与对方各投掷1次骰子，返回两个点数d1（tp）和d2（对方）；若点数相同则循环重投，直到分出胜负。
		d1,d2=Duel.TossDice(tp,1,1)
	end
	if d1<d2 then
		if d2==6 then
			-- 当对方点数d2为6且tp点数较低时，给予tp玩家6000点效果伤害。
			Duel.Damage(tp,6000,REASON_EFFECT)
		elseif d2>=2 and d2<=5 then
			-- 当对方点数d2为2～5且tp点数较低时，给予tp玩家（对方点数×500）点效果伤害。
			Duel.Damage(tp,d2*500,REASON_EFFECT)
		end
	else
		if d1==6 then
			-- 当tp点数d1为6且对方点数较低时，给予对方玩家6000点效果伤害。
			Duel.Damage(1-tp,6000,REASON_EFFECT)
		elseif d1>=2 and d1<=5 then
			-- 当tp点数d1为2～5且对方点数较低时，给予对方玩家（tp点数×500）点效果伤害。
			Duel.Damage(1-tp,d1*500,REASON_EFFECT)
		end
	end
end
