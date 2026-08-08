--ドールハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 初始化卡片效果：注册破坏己方怪兽抽2张并可变更对方怪兽表示形式的效果，以及墓地怪兽特召时自身回收手牌的效果
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 发动准备与条件检查：判断自己是否能抽2张卡且场上存在可选择的目标怪兽
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 发动条件检查：自己是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 发动条件检查：自己怪兽区是否存在至少1只怪兽可作为效果对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择自己场上1只怪兽作为效果对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置抽卡的目标玩家为自己
	Duel.SetTargetPlayer(tp)
	-- 设置抽卡的目标参数为2张
	Duel.SetTargetParam(2)
	-- 设置连锁操作信息：破坏选中的1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁操作信息：玩家抽2张卡
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 效果处理：破坏对象怪兽，成功后抽2张卡，之后可选对方场上1只怪兽变更表示形式
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设置的抽卡玩家与抽卡张数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取连锁中仍关联的对象怪兽
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 将对象怪兽破坏，并确认成功破坏
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 让目标玩家抽2张卡，并确认成功抽卡
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 检查对方场上是否存在可以变更表示形式的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否变更对方怪兽的表示形式
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
		-- 提示玩家选择要变更表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 从对方场上选择1只可以变更表示形式的怪兽
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 中断当前效果处理（使后续变更表示形式与前面的处理不视为同时发生）
			Duel.BreakEffect()
			-- 高亮显示选择的对方怪兽
			Duel.HintSelection(cg)
			-- 将选中的对方怪兽变更表示形式（攻击表示变表侧守备，守备表示变表侧攻击）
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 特召触发过滤条件：从自己墓地特殊召唤的怪兽
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 回收效果发动条件：存在从自己墓地特殊召唤怪兽
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 回收效果发动准备：检查自身能否加入手牌并设置加入手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁操作信息：将此卡1张加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 回收效果处理：将墓地的此卡加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否仍与连锁相关且不受王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡加入手牌
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
