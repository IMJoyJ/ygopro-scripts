--妖精竜 エンシェント
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 自己回合有场地魔法卡发动的场合，从卡组抽1张卡。「妖精龙 古代妖」的这个效果1回合只能使用1次。此外，1回合1次，场地魔法卡表侧表示存在的场合，可以选择场上表侧攻击表示存在的1只怪兽破坏。
function c4179255.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 自己回合有场地魔法卡发动的场合，从卡组抽1张卡。「妖精龙 古代妖」的这个效果1回合只能使用1次。
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
	-- 此外，1回合1次，场地魔法卡表侧表示存在的场合，可以选择场上表侧攻击表示存在的1只怪兽破坏。
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
-- 判断是否为自己的回合且发动的是场地魔法卡的效果
function c4179255.drcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否为自己的回合且发动的是场地魔法卡的效果
	return Duel.GetTurnPlayer()==tp and re and re:IsActiveType(TYPE_FIELD) and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
-- 设置抽卡效果的目标玩家为自己，抽卡数量为1
function c4179255.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置抽卡效果的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡效果的抽卡数量为1
	Duel.SetTargetParam(1)
	-- 设置抽卡效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
-- 执行抽卡效果
function c4179255.drop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 让目标玩家从卡组抽指定数量的卡
	Duel.Draw(p,d,REASON_EFFECT)
end
-- 判断场地区是否存在表侧表示的场地魔法卡
function c4179255.descon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断场地区是否存在表侧表示的场地魔法卡
	return Duel.IsExistingMatchingCard(Card.IsFaceup,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil)
end
-- 判断目标怪兽是否为表侧攻击表示
function c4179255.desfilter(c)
	return c:IsPosition(POS_FACEUP_ATTACK)
end
-- 设置怪兽破坏效果的目标选择和操作信息
function c4179255.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and c4179255.desfilter(chkc) end
	-- 检查场上是否存在满足条件的怪兽作为目标
	if chk==0 then return Duel.IsExistingTarget(c4179255.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择场上表侧攻击表示的1只怪兽作为破坏对象
	local g=Duel.SelectTarget(tp,c4179255.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置破坏效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 执行怪兽破坏效果
function c4179255.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsPosition(POS_FACEUP_ATTACK)
		-- 确认场地区存在表侧表示的场地魔法卡
		and Duel.IsExistingMatchingCard(nil,tp,LOCATION_FZONE,LOCATION_FZONE,1,nil) then
		-- 破坏目标怪兽
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
