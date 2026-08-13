--妖精竜 エンシェント
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己回合有场地魔法卡发动的场合，从卡组抽1张卡。「妖精龙 古代妖」的这个效果1回合只能使用1次。此外，1回合1次，场地魔法卡表侧表示存在的场合，可以选择场上表侧攻击表示存在的1只怪兽破坏。
function c4179255.initial_effect(c)
	-- 为这张卡添加同调召唤手续：使用任意1只调整 + 调整以外的怪兽1只以上作为素材，实现“调整＋调整以外的怪兽1只以上”的召唤条件。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 对应效果原文：“自己回合有场地魔法卡发动的场合，从卡组抽1张卡。「妖精龙 古代妖」的这个效果1回合只能使用1次。”
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetDescription(aux.Stringid(4179255,0))  --"抽卡"
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,4179255)
	e1:SetCondition(c4179255.drcon)
	e1:SetTarget(c4179255.drtg)
	e1:SetOperation(c4179255.drop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(4179255)
	c:RegisterEffect(e2)
	-- 对应效果原文：“此外，1回合1次，场地魔法卡表侧表示存在的场合，可以选择场上表侧攻击表示存在的1只怪兽破坏。”
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetDescription(aux.Stringid(4179255,1))  --"怪兽破坏"
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c4179255.descon)
	e3:SetTarget(c4179255.destg)
	e3:SetOperation(c4179255.desop)
	c:RegisterEffect(e3)
end
-- 抽卡效果的发动条件：判定是否在“自己回合有场地魔法卡发动”的时点，即当前回合玩家为tp，且触发连锁的效果re是场地魔法卡的发动。
function c4179255.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 条件表达式：当前回合玩家等于tp，且触发连锁的效果re存在，且re是场地魔法卡类型，且re属于卡的发动（EFFECT_TYPE_ACTIVATE），满足时抽卡效果可以发动。
	return Duel.GetTurnPlayer()==tp and re and re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 抽卡效果的发动时处理：设定本次效果的对象玩家为tp，抽卡数量为1，并设置操作信息为抽卡效果。
function c4179255.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的对象玩家设置为tp，表示由tp来抽卡。
	Duel.SetTargetPlayer(tp)
	-- 将当前连锁的对象参数设置为1，表示抽卡数量为1张。
	Duel.SetTargetParam(1)
	-- 设置操作信息：宣告为抽卡效果，对象玩家为tp，预计抽卡数量为1（因不取对象，对象卡组设为nil）。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 抽卡效果的实际处理：从目标玩家p手中抽取d张卡。
function c4179255.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁信息中取出之前设定的目标玩家p（抽卡玩家）和目标参数d（抽卡数量）。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让玩家p以效果原因抽d张卡。
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 破坏效果的发动条件：场上（双方场地区）存在表侧表示的场地魔法卡。
function c4179255.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查是否存在至少1张表侧表示的场地魔法卡（LOCATION_FZONE），存在则满足发动条件。
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 破坏对象的过滤函数：只选择表侧攻击表示（POS_FACEUP_ATTACK）的怪兽。
function c4179255.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 破坏效果的发动时处理：选择场上1只表侧攻击表示怪兽作为对象，并设置破坏的操作信息，包含合法性检查和玩家选择。
function c4179255.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4179255.desfilter(chkc) end
	-- 效果发动合法性检查：场上是否存在可作为对象的表侧攻击表示怪兽，若不存在则不能发动。
	if chk==0 then return Duel.IsExistingTarget(c4179255.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家tp显示选择提示消息“请选择要破坏的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家tp从场上选择1只满足过滤条件的怪兽，并将其登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c4179255.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：宣告为破坏效果，对象为已选择的怪兽组g，处理数量为1。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果处理：若对象怪兽仍与效果关联且仍为表侧攻击表示，并且场上仍有表侧表示的场地魔法卡，则将该怪兽破坏。
function c4179255.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本效果选择的对象卡片（第一张目标怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK)
		-- 效果处理时再次确认场上存在至少1张表侧表示的场地魔法卡，以确保满足“场地魔法卡表侧表示存在的场合”这一条件。
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		-- 以效果原因破坏对象怪兽tc。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
