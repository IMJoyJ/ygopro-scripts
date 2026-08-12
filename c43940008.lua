--決闘塔アルカトラズ
-- 效果：
-- ①：自己·对方的战斗阶段开始时发动。双方各自可以从自身卡组选1只攻击力?以外的怪兽。选的怪兽给双方确认，里侧表示除外。选攻击力最高的怪兽的玩家可以从手卡把1只怪兽特殊召唤。这个效果特殊召唤的怪兽可以直接攻击。
-- ②：自己·对方的结束阶段才能发动。下次的自己回合的结束阶段有这张卡在场上存在的场合，场上的卡全部破坏。
function c43940008.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：自己·对方的战斗阶段开始时发动。双方各自可以从自身卡组选1只攻击力?以外的怪兽。选的怪兽给双方确认，里侧表示除外。选攻击力最高的怪兽的玩家可以从手卡把1只怪兽特殊召唤。这个效果特殊召唤的怪兽可以直接攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(43940008,0))
	e2:SetCategory(CATEGORY_REMOVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE_START)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetOperation(c43940008.csop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的结束阶段才能发动。下次的自己回合的结束阶段有这张卡在场上存在的场合，场上的卡全部破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(43940008,1))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetOperation(c43940008.dop)
	c:RegisterEffect(e3)
end
-- 过滤函数，用于筛选满足条件的怪兽（必须是怪兽卡、攻击力非负、可以除外）
function c43940008.csfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:GetTextAttack()>=0 and c:IsAbleToRemove(tp,POS_FACEDOWN)
end
-- 战斗阶段开始时的效果处理函数，负责选择并除外双方的怪兽，判断攻击力并决定特殊召唤的玩家
function c43940008.csop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己的卡组中选择一张满足条件的怪兽卡
	local sc1=Duel.SelectMatchingCard(tp,c43940008.csfilter,tp,LOCATION_DECK,0,0,1,nil,tp):GetFirst()
	-- 向对方提示“请选择要除外的卡”
	Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让对方从自己的卡组中选择一张满足条件的怪兽卡
	local sc2=Duel.SelectMatchingCard(1-tp,c43940008.csfilter,1-tp,LOCATION_DECK,0,0,1,nil,1-tp):GetFirst()
	if sc1 or sc2 then
		local p=0
		if (not sc2) or sc1 and sc1:GetTextAttack()>sc2:GetTextAttack() then p=tp
		elseif (not sc1) or sc1:GetTextAttack()<sc2:GetTextAttack() then p=1-tp
		else p=PLAYER_ALL end
		-- 确认玩家1的选卡结果
		if sc1 then Duel.ConfirmCards(1-tp,sc1) end
		-- 确认玩家2的选卡结果
		if sc2 then Duel.ConfirmCards(tp,sc2) end
		-- 将双方选中的怪兽以里侧表示的形式除外
		Duel.Remove(Group.FromCards(sc1,sc2),POS_FACEDOWN,REASON_EFFECT)
		-- 判断是否为当前玩家或双方都选中，且场上存在空位
		if (p==tp or p==PLAYER_ALL) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			-- 检查当前玩家手牌中是否存在可以特殊召唤的怪兽
			and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,nil,e,0,tp,false,false)
			-- 询问当前玩家是否要从手牌特殊召唤怪兽
			and Duel.SelectYesNo(tp,aux.Stringid(43940008,2)) then  --"是否从手卡特殊召唤？"
			-- 向玩家提示“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让玩家从手牌中选择一张可以特殊召唤的怪兽
			local sc=Duel.SelectMatchingCard(tp,Card.IsCanBeSpecialSummoned,tp,LOCATION_HAND,0,1,1,nil,e,0,tp,false,false):GetFirst()
			if sc then
				-- 将选中的怪兽特殊召唤到场上
				Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP)
				-- 给特殊召唤的怪兽赋予直接攻击效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_DIRECT_ATTACK)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e1)
			end
		end
		-- 判断是否为对方玩家或双方都选中，且对方场上存在空位
		if (p==1-tp or p==PLAYER_ALL) and Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
			-- 检查对方手牌中是否存在可以特殊召唤的怪兽
			and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,1-tp,LOCATION_HAND,0,1,nil,e,0,1-tp,false,false)
			-- 询问对方玩家是否要从手牌特殊召唤怪兽
			and Duel.SelectYesNo(1-tp,aux.Stringid(43940008,2)) then  --"是否从手卡特殊召唤？"
			-- 向对方提示“请选择要特殊召唤的卡”
			Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
			-- 让对方从手牌中选择一张可以特殊召唤的怪兽
			local sc=Duel.SelectMatchingCard(1-tp,Card.IsCanBeSpecialSummoned,1-tp,LOCATION_HAND,0,1,1,nil,e,0,1-tp,false,false):GetFirst()
			if sc then
				-- 将对方选中的怪兽特殊召唤到对方场上
				Duel.SpecialSummon(sc,0,1-tp,1-tp,false,false,POS_FACEUP)
				-- 给对方特殊召唤的怪兽赋予直接攻击效果
				local e2=Effect.CreateEffect(e:GetHandler())
				e2:SetType(EFFECT_TYPE_SINGLE)
				e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e2:SetCode(EFFECT_DIRECT_ATTACK)
				e2:SetReset(RESET_EVENT+RESETS_STANDARD)
				sc:RegisterEffect(e2)
			end
		end
	end
end
-- 结束阶段效果处理函数，注册一个持续到下次结束阶段的破坏效果
function c43940008.dop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 计算下次结束阶段的回合数
	local ct=Duel.GetTurnPlayer()==tp and 2 or 1
	c:RegisterFlagEffect(43940008,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,0,ct)
	-- 注册一个持续到指定回合的破坏效果
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PHASE+PHASE_END)
	-- 设置该效果的触发回合数
	e1:SetLabel(Duel.GetTurnCount()+ct)
	e1:SetCountLimit(1)
	e1:SetCondition(c43940008.descon)
	e1:SetOperation(c43940008.desop)
	-- 将该效果注册到全局环境
	Duel.RegisterEffect(e1,tp)
end
-- 判断是否到达设定的回合数且卡片仍在场上
function c43940008.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断当前回合数是否等于设定的回合数且卡片在场上
	return Duel.GetTurnCount()==e:GetLabel() and c:IsOnField() and c:IsFaceup()
		and c:GetFlagEffect(43940008)>0
end
-- 破坏效果的执行函数，将场上所有卡破坏
function c43940008.desop(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(0)
	-- 显示卡片发动的动画提示
	Duel.Hint(HINT_CARD,0,43940008)
	-- 获取场上所有卡的集合
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
	-- 将场上所有卡以效果原因破坏
	Duel.Destroy(g,REASON_EFFECT)
end
