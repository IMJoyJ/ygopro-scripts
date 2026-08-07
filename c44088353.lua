--ドールハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 注册「人偶之锤」的①效果（魔法卡发动：破坏自己怪兽、抽2张、变更对方怪兽表示形式）与②效果（墓地诱发：从自己墓地特招怪兽时回收此卡），两个效果1回合各能使用1次。
function s.initial_effect(c)
	-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
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
-- 定义①效果的发动条件与取对象逻辑：检查目标是否为自己场上的怪兽、玩家是否能抽2张卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查自身玩家是否能够通过效果抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己场上是否存在至少1只可以作为对象的怪兽。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 设置提示信息，指示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让自己选择自己场上1只怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理时的目标玩家为自己。
	Duel.SetTargetPlayer(tp)
	-- 设置效果处理时的目标参数为抽2张卡。
	Duel.SetTargetParam(2)
	-- 设置连锁的操作信息为破坏选中的1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置连锁的操作信息为自己抽2张卡。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- ①效果的处理函数：破坏选中的怪兽并抽2张卡，满足条件时可选择变更对方场上1只怪兽的表示形式。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家及抽卡数量参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取仍与本连锁相关的目标怪兽组。
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 检查目标怪兽是否存在并成功将其破坏。
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 检查是否成功让目标玩家抽2张卡。
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 检查对方场上是否存在可以变更表示形式的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 询问玩家是否发动后续变更对方怪兽表示形式的效果。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
		-- 设置提示信息，指示玩家选择要变更表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家选择对方场上1只可以变更表示形式的怪兽。
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 中断效果处理，使后续变更表示形式的处理不与前面的破坏/抽卡视为同时发生。
			Duel.BreakEffect()
			-- 高亮显示被选中的怪兽。
			Duel.HintSelection(cg)
			-- 将选中的怪兽改变表示形式（攻击表示变表侧守备表示，守备表示变表侧攻击表示）。
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 过滤筛选从自己墓地特殊召唤成功的怪兽卡。
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- ②效果的发动条件：检查触发事件的怪兽组中是否存在从自己墓地特殊召唤的怪兽。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- ②效果的Target逻辑：检查自身卡片是否可以加入手卡，并设置加入手卡的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置连锁的操作信息为将墓地的这张卡加入手卡。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- ②效果的处理函数：将墓地中的这张卡加入手卡（受王家长眠之谷过滤）。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与本连锁相关且不受王家长眠之谷影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 通过效果将这张卡加入手卡。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
