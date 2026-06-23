--ポイズン・チェーン
-- 效果：
-- 自己回合没有进行战斗的场合，结束阶段时可以把自己场上表侧表示存在的名字带有「链」的怪兽数量的卡从对方卡组上面送去墓地。
function c33302407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 诱发选发效果，满足条件时可以在结束阶段发动
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(33302407,0))  --"卡组送墓"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c33302407.discon)
	e2:SetTarget(c33302407.distg)
	e2:SetOperation(c33302407.disop)
	c:RegisterEffect(e2)
end
-- 效果发动条件：自己回合且该回合未进行过战斗
function c33302407.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前回合玩家等于发动玩家且该玩家在本回合未进行过攻击
	return tp==Duel.GetTurnPlayer() and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0
end
-- 过滤函数，用于筛选场上表侧表示且卡名含「链」的怪兽
function c33302407.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x25)
end
-- 效果发动时的处理函数，用于确认是否可以发动效果并设置操作信息
function c33302407.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计场上满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c33302407.filter,tp,LOCATION_MZONE,0,nil)
	-- 检查是否满足发动条件：场上存在满足条件的怪兽且对方可以将相应数量的卡从卡组送入墓地
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	-- 设置连锁操作信息，表示将对方卡组上方的指定数量的卡送去墓地
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- 效果处理函数，执行将对方卡组上方的怪兽数量的卡送去墓地的操作
function c33302407.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 统计场上满足条件的怪兽数量
	local ct=Duel.GetMatchingGroupCount(c33302407.filter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 将对方卡组上方指定数量的卡以效果为原因送去墓地
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
