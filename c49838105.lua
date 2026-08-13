--森羅の滝滑り
-- 效果：
-- 每次对方怪兽直接攻击宣言，可以把这张卡的效果发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。此外，只要这张卡在场上存在，自己的抽卡阶段时作为进行通常抽卡的代替，自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡加入手卡。
function c49838105.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- 每次对方怪兽直接攻击宣言，可以把这张卡的效果发动。自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡回到卡组最下面。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(49838105,0))  --"翻开卡组"
	e2:SetCategory(CATEGORY_DECKDES)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(c49838105.condition)
	e2:SetTarget(c49838105.target)
	e2:SetOperation(c49838105.operation)
	c:RegisterEffect(e2)
	-- 此外，只要这张卡在场上存在，自己的抽卡阶段时作为进行通常抽卡的代替，自己卡组最上面的卡翻开。翻开的卡是植物族怪兽的场合，那只怪兽送去墓地。不是的场合，那张卡加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(49838105,1))  --"抽卡代替"
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PREDRAW)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCondition(c49838105.cfcon)
	e3:SetTarget(c49838105.cftg)
	e3:SetOperation(c49838105.cfop)
	c:RegisterEffect(e3)
end
-- 攻击宣言的怪兽为对方怪兽且攻击目标为空，即对方怪兽直接攻击宣言时条件成立。
function c49838105.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判定攻击怪兽是对方控制且攻击目标为nil（直接攻击），两者同时满足。
	return Duel.GetAttacker():IsControler(1-tp) and Duel.GetAttackTarget()==nil
end
-- 效果发动时点检查：自己卡组是否有至少1张卡可以送去墓地，作为可发动条件。
function c49838105.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 效果发动时chk==0确认自己能否将卡组顶端1张卡送去墓地，能则允许发动。
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
end
-- 效果处理：翻开自己卡组最上面的1张卡，若是植物族怪兽则送去墓地，否则放回卡组最下面。
function c49838105.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 再次确认自己可以把卡组顶端1张卡送去墓地，否则不执行处理。
	if not Duel.IsPlayerCanDiscardDeck(tp,1) then return end
	-- 将卡组最上方1张卡向双方公开确认。
	Duel.ConfirmDecktop(tp,1)
	-- 取得卡组最上方1张卡作为对象组g。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	if tc:IsRace(RACE_PLANT) then
		-- 禁用本次操作后的自动洗牌检查，因为从卡组顶端取卡后位置明确，无需洗牌。
		Duel.DisableShuffleCheck()
		-- 将翻开的植物族怪兽以效果原因并附带翻开原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	else
		-- 将不是植物族的翻开的卡移动到卡组最下面，即回到卡组最下面。
		Duel.MoveSequence(tc,SEQ_DECKBOTTOM)
	end
end
-- 抽卡代替效果的触发条件：当前回合玩家是自己，即自己的抽卡阶段。
function c49838105.cfcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断效果持有者是否是当前回合玩家，只有自己的抽卡阶段才触发。
	return tp==Duel.GetTurnPlayer()
end
-- 抽卡代替效果的发动目标：确认自己可以进行通常抽卡，并放弃本次通常抽卡权利。
function c49838105.cftg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认自己具备常规抽卡条件（常规抽卡次数可用、卡组有卡且不受不能抽卡限制），才能发动代替抽卡效果。
	if chk==0 then return aux.IsPlayerCanNormalDraw(tp) end
	-- 放弃本回合的通常抽卡权利，使后续以效果代替抽卡。
	aux.GiveUpNormalDraw(e,tp)
end
-- 抽卡代替效果处理：翻开卡组最上方1张卡，若是植物族怪兽则送去墓地，若不是则加入手牌。
function c49838105.cfop(e,tp,eg,ep,ev,re,r,rp)
	-- 自己卡组没有卡时无法翻开，直接终止处理。
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)==0 then return end
	-- 翻开卡组最上方1张卡，双方确认。
	Duel.ConfirmDecktop(tp,1)
	-- 获取卡组最上方1张卡所在的组g。
	local g=Duel.GetDecktopGroup(tp,1)
	local tc=g:GetFirst()
	-- 关闭自动洗牌检查，因为取卡位置固定，后续操作不会导致卡组随机化。
	Duel.DisableShuffleCheck()
	if tc:IsRace(RACE_PLANT) then
		-- 是植物族怪兽的场合，将其以效果原因和翻开原因送去墓地。
		Duel.SendtoGrave(tc,REASON_EFFECT+REASON_REVEAL)
	else
		-- 不是植物族的场合，将那张卡加入持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		-- 由于将卡组顶端的卡加入手牌，需要洗切手牌，使卡牌信息不泄露。
		Duel.ShuffleHand(tp)
	end
end
