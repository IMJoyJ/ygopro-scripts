--ドールハンマー
local s,id,o=GetID()
-- 定义卡片初始效果函数，创建并注册两个效果：一个为破坏抽卡改变表示形式的效果，另一个为特殊召唤成功后的回手效果。
function s.initial_effect(c)
	-- 创建第一个效果，设置描述、类别（破坏、抽卡、改变表示形式）、属性（可取对象）、类型（激活）和代码（自由连锁），并限制每回合只能发动一次。然后设置目标选择函数和操作函数，最后将效果注册到卡片上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- 创建第二个效果，设置描述、类别（回手牌）、类型（场地+诱发选发）、代码（特殊召唤成功）、范围（墓地），并延迟生效。限制每回合只能发动一次，设置条件、目标选择和操作函数，最后将效果注册到卡片上。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
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
-- 定义目标选择函数，用于第一个效果。检查是否是确认模式，如果是则返回true如果目标位置在怪兽区域并且属于当前玩家；否则，检查是否可以抽牌以及是否存在场上的怪兽作为目标。
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) end
	-- 检查玩家是否可以抽2张卡。
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2)
		-- 检查是否存在至少一张位于对方怪兽区域的卡片作为目标。
		and Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家提示选择要破坏的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家从场上选择1只怪兽进行破坏。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置当前连锁的目标玩家为发动者的玩家。
	Duel.SetTargetPlayer(tp)
	-- 设置当前连锁的目标参数为2，用于后续抽卡数量的传递。
	Duel.SetTargetParam(2)
	-- 设置当前连锁的操作信息，指定破坏效果、目标卡组和数量。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设置当前连锁的操作信息，指定抽卡效果、玩家和数量。
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
-- 定义第一个效果的操作函数。获取连锁的目标玩家和参数，过滤出所有类型的怪兽，如果存在目标且成功破坏，并且成功抽牌，并且场上存在可以改变表示形式的怪兽，并且玩家选择是，则提示选择要改变表示形式的怪兽，并改变其表示形式。
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从当前连锁中获取目标玩家和参数。
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	-- 过滤出所有类型的怪兽卡片。
	local tg=Duel.GetTargetsRelateToChain():Filter(Card.IsType,nil,TYPE_MONSTER)
	-- 如果存在目标怪兽并且成功破坏。
	if tg:GetCount()>0 and Duel.Destroy(tg,REASON_EFFECT)>0
		-- 并且成功抽牌。
		and Duel.Draw(p,d,REASON_EFFECT)~=0
		-- 并且场上存在可以改变表示形式的怪兽。
		and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,nil)
		-- 并且玩家选择是，则执行后续操作。
		and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		-- 向玩家提示选择要改变表示形式的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
		-- 让玩家从场上选择一只可以改变表示形式的怪兽。
		local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,0,LOCATION_MZONE,1,1,nil)
		if cg:GetCount()>0 then
			-- 中断当前效果，使之后的效果处理视为不同时处理。
			Duel.BreakEffect()
			-- 手动为选定的卡片显示动画效果。
			Duel.HintSelection(cg)
			-- 改变指定怪兽的表示形式。
			Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		end
	end
end
-- 定义一个过滤函数，用于检查卡片是否在墓地并且之前的控制者是当前玩家。
function s.cfilter(c,tp)
	return c:IsSummonLocation(LOCATION_GRAVE) and c:GetPreviousControler()==tp
end
-- 定义第二个效果的条件函数。如果存在满足cfilter条件的卡片，则返回true。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
-- 定义第二个效果的目标选择函数。如果处于确认模式，则返回处理对象是否可以送入手牌；否则，设置操作信息为回手效果。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	-- 设置当前连锁的操作信息，指定回手效果、目标卡片和数量。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
-- 定义第二个效果的操作函数。获取触发的卡片，如果该卡片与连锁相关并且不受王家长眠之谷的影响，则将其送入持有者的手牌。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查卡片是否与当前连锁相关，以及是否不受王家长眠之谷的影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 将卡片送入持有者的手牌。
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
