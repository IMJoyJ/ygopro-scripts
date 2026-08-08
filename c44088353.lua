--ドールハンマー
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上1只怪兽为对象才能发动。那只怪兽破坏，自己抽2张。那之后，可以把对方场上1只怪兽的表示形式变更。
-- ②：这张卡在墓地存在的状态，从自己墓地有怪兽特殊召唤的场合才能发动。这张卡加入手卡。
local s,id,o=GetID()
-- 定义卡片初始效果函数，用于注册卡牌的效果。
function s.initial_effect(c)
	-- 创建第一个效果，描述为“发动”，设置效果类别为破坏、抽卡和改变表示形式，并允许指定目标。该效果是激活类型，可以在自由连锁时使用，并且限制每回合只能使用一次。将目标设置为s.target函数，操作设置为s.activate函数。
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
	-- 创建第二个效果，描述为“回收”，设置效果类别为回手牌，类型为场面效果和诱发选发效果，在怪兽特殊召唤成功时触发。该效果延迟生效，限制每回合只能使用一次，条件是s.thcon函数，目标是s.thtg函数，操作是s.thop函数。
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
-- 定义目标选择函数，用于确定要破坏的怪兽。如果检查模式为真，则返回卡片是否在怪兽区域且由当前玩家控制。如果检查模式为0，则检查玩家是否可以抽2张牌以及是否存在至少一张在怪兽区域且不受任何限制的卡。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查玩家是否可以抽2张卡
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查是否存在至少一张在怪兽区域且不受任何限制的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从怪兽区域选择1张卡片作为目标。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的目标玩家为tp（当前玩家）。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2，用于后续操作。
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息，指定破坏效果，目标卡组为g（选定的怪兽），数量为1，目标玩家为0，目标参数为0。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息，指定抽卡效果，目标玩家为tp（当前玩家），数量为2。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义激活函数，用于执行效果。获取连锁的目标玩家和参数，过滤出所有类型的怪兽，如果存在目标且成功破坏目标怪兽并抽牌，并且存在可以改变表示形式的怪兽，则提示玩家是否改变表示形式。如果玩家选择是，则提示玩家选择要改变表示形式的怪兽，然后改变所选怪兽的表示形式。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 过滤出所有类型的怪兽
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 检查目标数量是否大于0，并且成功破坏目标怪兽（原因：效果）
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 检查抽牌是否成功
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 检查是否存在至少一张可以改变表示形式的卡片。
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 提示玩家选择是否改变表示形式。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否改变表示形式？"
		-- 提示玩家选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家从怪兽区域选择1张可以改变表示形式的卡片作为目标。
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理。
			Duel.BreakEffect()
			-- 手动为选定的卡片显示动画效果。
			Duel.HintSelection(cg)
			-- 改变所选怪兽的表示形式。
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 定义一个过滤函数s.cfilter，用于检查墓地中的怪兽是否属于当前玩家且是原始怪兽类型。
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp and c:GetOriginalType()&TYPE_MONSTER~=0
end
-- 定义条件函数s.thcon，用于判断是否满足触发第二个效果的条件。如果存在至少一张符合s.cfilter条件的卡片，则返回真。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 定义目标选择函数s.thtg，用于确定要回手的卡片。如果检查模式为0，则返回处理对象是否可以加入手牌。否则，设置当前连锁的操作信息，指定回手效果，目标卡片为处理对象，数量为1，目标玩家和参数为0。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前连锁的操作信息，指定回手效果，目标卡片为处理对象，数量为1，目标玩家和参数为0。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义操作函数s.thop，用于执行第二个效果。获取处理对象，如果该对象与连锁相关且不受王家长眠之谷的影响，则将该对象送入持有者的手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否与当前连锁相关，并且不受王家长眠之谷的影响
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将卡片送入持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
