--地中界シャンバラ
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1只「地中族」怪兽加入手卡。
-- ②：1回合1次，自己主要阶段才能发动。选自己1只里侧守备表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。
-- ③：1回合1次，对方怪兽的攻击宣言时才能发动。选自己1只里侧守备表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。那之后，可以把那次攻击无效。
function c5697558.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1只「地中族」怪兽加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,5697558+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(c5697558.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己主要阶段才能发动。选自己1只里侧守备表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(5697558,1))  --"改变表示形式"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(c5697558.postg)
	e2:SetOperation(c5697558.posop)
	c:RegisterEffect(e2)
	-- ③：1回合1次，对方怪兽的攻击宣言时才能发动。选自己1只里侧守备表示的「地中族」怪兽变成表侧攻击表示或者表侧守备表示。那之后，可以把那次攻击无效。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_POSITION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_ATTACK_ANNOUNCE)
	e3:SetRange(LOCATION_FZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c5697558.condition)
	e3:SetTarget(c5697558.target)
	e3:SetOperation(c5697558.operation)
	c:RegisterEffect(e3)
end
-- 过滤卡组中可以加入手卡的「地中族」怪兽
function c5697558.thfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsSetCard(0xed) and c:IsAbleToHand()
end
-- 卡片发动时的效果处理：可以从卡组把1只「地中族」怪兽加入手卡
function c5697558.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己卡组中满足条件的「地中族」怪兽
	local g=Duel.GetMatchingGroup(c5697558.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在符合条件的怪兽，则询问玩家是否将其加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(5697558,0)) then  --"是否把「地中族」怪兽加入手卡？"
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的卡因效果加入手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 过滤自己场上里侧守备表示的「地中族」怪兽
function c5697558.filter(c)
	return c:IsSetCard(0xed) and c:IsFacedown() and c:IsDefensePos()
end
-- 效果②的靶向/发动准备：检查场上是否存在符合条件的怪兽并设置改变表示形式的操作信息
function c5697558.postg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只里侧守备表示的「地中族」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5697558.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为改变1张卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 效果②的效果处理：选择自己1只里侧守备表示的「地中族」怪兽，改变其表示形式
function c5697558.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择1只自己场上里侧守备表示的「地中族」怪兽
	local g=Duel.SelectMatchingCard(tp,c5697558.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家选择该怪兽要变成表侧攻击表示还是表侧守备表示
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		-- 改变该怪兽的表示形式为玩家选择的形式
		Duel.ChangePosition(tc,pos)
	end
end
-- 效果③的发动条件：必须在对方回合（非自己回合）
function c5697558.condition(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否不是自己（即对方回合）
	return tp~=Duel.GetTurnPlayer()
end
-- 效果③的靶向/发动准备：检查场上是否存在符合条件的怪兽并设置改变表示形式的操作信息
function c5697558.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在至少1只里侧守备表示的「地中族」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c5697558.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置操作信息为改变1张卡片的表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
-- 效果③的效果处理：选择自己1只里侧守备表示的「地中族」怪兽改变表示形式，之后可以把那次攻击无效
function c5697558.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要改变表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 让玩家选择1只自己场上里侧守备表示的「地中族」怪兽
	local g=Duel.SelectMatchingCard(tp,c5697558.filter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 让玩家选择该怪兽要变成表侧攻击表示还是表侧守备表示
		local pos=Duel.SelectPosition(tp,tc,POS_FACEUP_ATTACK+POS_FACEUP_DEFENSE)
		-- 若成功改变表示形式，则询问玩家是否将那次攻击无效
		if Duel.ChangePosition(tc,pos)~=0 and Duel.SelectYesNo(tp,aux.Stringid(5697558,2)) then  --"是否把攻击无效？"
			-- 中断当前效果，使后续的无效攻击处理不与改变表示形式同时进行
			Duel.BreakEffect()
			-- 无效此次攻击
			Duel.NegateAttack()
		end
	end
end
