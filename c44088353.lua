--ドールハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②的效果
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
-- 效果处理时检查是否满足条件
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查自己场上是否存在至少1只怪兽作为对象
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择1只自己场上的怪兽作为对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置连锁对象玩家为使用者
	Duel.SetTargetPlayer(tp)
	-- 设置连锁对象参数为2
	Duel.SetTargetParam(2)
	-- 设置操作信息为破坏效果
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置操作信息为抽2张卡效果
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 处理①效果的发动和后续处理
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中的目标玩家和目标参数
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 获取与连锁相关的怪兽作为目标
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 若存在目标怪兽且成功破坏
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 并且成功抽2张卡
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 并且对方场上存在可改变表示形式的怪兽
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 并且使用者选择是否改变表示形式
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
		-- 提示选择要改变表示形式的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 选择1只对方场上的怪兽作为改变表示形式的对象
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理
			Duel.BreakEffect()
			-- 手动为选中的怪兽显示被选为对象的动画效果
			Duel.HintSelection(cg)
			-- 将选中的怪兽改变表示形式为表侧守备表示、表侧攻击表示
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 用于判断墓地特殊召唤的怪兽是否满足条件
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 判断是否有怪兽从墓地特殊召唤成功
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 设置②效果的发动时点和目标
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置操作信息为回手牌效果
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 处理②效果的发动和后续处理
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查此卡是否与连锁相关且未被王家长眠之谷影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将此卡送入手卡
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
