--ドラグニティ・ヴォイド
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己场上有「龙骑兵团」同调怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并除外。自己场上有10星「龙骑兵团」怪兽存在的场合，可以再让自己场上1只「龙骑兵团」怪兽的攻击力上升表侧除外中的卡数量×100。
function c51849216.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己场上有「龙骑兵团」同调怪兽存在，对方把魔法·陷阱卡发动时才能发动。那个发动无效并除外。自己场上有10星「龙骑兵团」怪兽存在的场合，可以再让自己场上1只「龙骑兵团」怪兽的攻击力上升表侧除外中的卡数量×100。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCountLimit(1,51849216+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c51849216.condition)
	-- 设置效果发动时的Target操作为aux.nbtg，用于检验并声明将对方发动的魔法·陷阱卡无效并除外的目标信息（不取对象，若对方效果在墓地发动还会追加墓地效果分类）。
	e1:SetTarget(aux.nbtg)
	e1:SetOperation(c51849216.activate)
	c:RegisterEffect(e1)
end
-- 定义过滤函数：筛选表侧表示、属于「龙骑兵团」系列且为同调怪兽的卡，用于判断自己场上是否存在符合条件的「龙骑兵团」同调怪兽。
function c51849216.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsType(TYPE_SYNCHRO)
end
-- 定义效果发动条件：对方发动魔法·陷阱卡且该发动可被无效，并且自己场上有表侧表示「龙骑兵团」同调怪兽存在时才能发动。
function c51849216.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断连锁发动的玩家是对方、被连锁的是魔法·陷阱卡的发动（EFFECT_TYPE_ACTIVATE），且当前连锁的发动可以被无效。
	return ep==1-tp and re:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.IsChainNegatable(ev)
		-- 检查自己场上是否存在表侧表示的「龙骑兵团」同调怪兽（至少1只）。
		and Duel.IsExistingMatchingCard(c51849216.filter,tp,LOCATION_MZONE,0,1,nil)
end
-- 定义过滤函数：筛选表侧表示且属于「龙骑兵团」系列的怪兽，用于后续选择攻击力上升的对象。
function c51849216.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 定义过滤函数：筛选表侧表示、属于「龙骑兵团」系列且等级为10的怪兽，用于判断是否存在10星「龙骑兵团」怪兽。
function c51849216.cfilter(c)
	return c51849216.atkfilter(c) and c:IsLevel(10)
end
-- 效果处理时：先无效对方发动的魔法·陷阱卡并将其表侧除外；若成功且自己场上有10星「龙骑兵团」怪兽、表侧除外卡数量大于0，则询问玩家是否选择1只「龙骑兵团」怪兽上升攻击力。
function c51849216.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 尝试无效对方发动的连锁，并确认对方发动的卡与该效果仍有联系（未被其他效果移动），以保证后续可以将其除外。
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re)
		-- 将被无效的对方发动的卡以表侧表示除外，并确认至少1张被除外且位于除外区，作为后续处理的前提。
		and Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)~=0 and eg:GetFirst():IsLocation(LOCATION_REMOVED) then
		-- 统计双方场外被表侧除外的卡的总数量，作为攻击力上升的数值（×100）。
		local ct=Duel.GetMatchingGroupCount(Card.IsFaceup,tp,LOCATION_REMOVED,LOCATION_REMOVED,nil)
		-- 确认自己场上存在10星「龙骑兵团」怪兽，且表侧除外卡数量大于0，才满足追加攻击力上升的条件。
		if Duel.IsExistingMatchingCard(c51849216.cfilter,tp,LOCATION_MZONE,0,1,nil) and ct>0
			-- 让玩家选择是否发动追加效果（上升攻击力），对应效果文本中的‘可以’。
			and Duel.SelectYesNo(tp,aux.Stringid(51849216,0)) then  --"是否选怪兽上升攻击力？"
			-- 中断当前效果处理，使后续的攻击力上升作为独立处理，避免错过时点。
			Duel.BreakEffect()
			-- 向玩家显示选择表侧表示怪兽的提示信息。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
			-- 让玩家从自己场上选择1张表侧表示的「龙骑兵团」怪兽，作为攻击力上升的对象。
			local g=Duel.SelectMatchingCard(tp,c51849216.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
			-- 向双方展示所选怪兽的选中动画，并记录该卡成为效果对象。
			Duel.HintSelection(g)
			local tc=g:GetFirst()
			-- 可以再让自己场上1只「龙骑兵团」怪兽的攻击力上升表侧除外中的卡数量×100。
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(ct*100)
			tc:RegisterEffect(e1)
		end
	end
end
