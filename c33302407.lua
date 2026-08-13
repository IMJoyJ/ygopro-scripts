--ポイズン・チェーン
-- 效果：
-- 自己回合没有进行战斗的场合，结束阶段时可以把自己场上表侧表示存在的名字带有「链」的怪兽数量的卡从对方卡组上面送去墓地。
function c33302407.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 自己回合没有进行战斗的场合，结束阶段时可以把自己场上表侧表示存在的名字带有「链」的怪兽数量的卡从对方卡组上面送去墓地。
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
-- 发动条件判定：必须是自己回合且本回合未进行过攻击（攻击次数为0）。
function c33302407.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 返回真条件：当前回合玩家是自己，并且自己本回合的攻击次数为0。
	return tp==Duel.GetTurnPlayer() and Duel.GetActivityCount(tp,ACTIVITY_ATTACK)==0
end
-- 过滤函数：筛选出我方场上表侧表示且名字带有「链」字段的怪兽。
function c33302407.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x25)
end
-- 发动时的目标处理：统计符合条件的怪兽数量，确认对方卡组可以送墓，并设置操作信息。
function c33302407.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 统计我方场上表侧表示且名字带有「链」字段的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c33302407.filter,tp,LOCATION_MZONE,0,nil)
	-- 发动合法性检查：若为发动时点确认，则要求怪兽数量大于0且对方卡组顶端至少能送墓相应数量的卡。
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	-- 设置操作信息：效果分类为卡组送墓，预定将对方卡组顶端的ct张卡送去墓地。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,ct)
end
-- 效果处理：重新统计符合条件的怪兽数量，若大于0则从对方卡组顶端将相同数量的卡送去墓地。
function c33302407.disop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新统计我方场上表侧表示且名字带有「链」字段的怪兽数量。
	local ct=Duel.GetMatchingGroupCount(c33302407.filter,tp,LOCATION_MZONE,0,nil)
	if ct>0 then
		-- 以效果原因将对方卡组顶端ct张卡送去墓地。
		Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	end
end
