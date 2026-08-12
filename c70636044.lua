--終戒超獸－ヴァルドラス
-- 效果：
-- 10星怪兽×2只以上
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：对方把效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。那之后，可以把这张卡1个超量素材取除。那个场合，再把场上1张卡破坏。
-- ②：持有超量素材的这张卡攻击的伤害步骤开始时才能发动。场上1张卡破坏。
-- ③：超量召唤的这张卡被破坏的场合才能发动。场上1张卡破坏。
local s,id,o=GetID()
-- 初始化效果：注册超量召唤手续，以及①、②、③效果
function s.initial_effect(c)
	-- 添加超量召唤手续：10星怪兽2只以上（最多99只）
	aux.AddXyzProcedure(c,nil,10,2,nil,nil,99)
	c:EnableReviveLimit()
	-- ①：对方把效果发动时，把这张卡1个超量素材取除才能发动。那个发动无效。那之后，可以把这张卡1个超量素材取除。那个场合，再把场上1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))  --"破坏场上的卡"
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.discon)
	e1:SetCost(s.discost)
	e1:SetTarget(s.distg)
	e1:SetOperation(s.disop)
	c:RegisterEffect(e1)
	-- ②：持有超量素材的这张卡攻击的伤害步骤开始时才能发动。场上1张卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏场上的卡"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon1)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
	-- ③：超量召唤的这张卡被破坏的场合才能发动。场上1张卡破坏。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"破坏场上的卡"
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetCountLimit(1,id+o*2)
	e3:SetCondition(s.descon2)
	e3:SetTarget(s.destg)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：自身未在战斗中确定被破坏，且对方发动了可以被无效的效果
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否未在战斗中确定被破坏，且该连锁的发动是否可以被无效
	return not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
		and ep==1-tp
end
-- ①效果的代价：取除自身1个超量素材
function s.discost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_COST) end
	e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_COST)
end
-- ①效果的发动准备：确认效果发动，并设置无效发动的操作信息
function s.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：在当前连锁中无效该卡或效果的发动
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ①效果的效果处理：尝试无效发动，若成功，则可选择再取除1个素材并破坏场上1张卡
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 如果成功使该连锁的发动无效
	if Duel.NegateActivation(ev) then
		-- 检查场上是否有可破坏的卡，且自身是否还能再取除1个超量素材
		if Duel.GetMatchingGroupCount(Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)>0
			and c:CheckRemoveOverlayCard(tp,1,REASON_EFFECT)
			-- 询问玩家是否选择再取除1个超量素材并破坏场上的卡
			and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否再取除超量素材并破坏场上的卡？"
			-- 中断当前效果处理，使“无效发动”与“取除素材”不视为同时处理
			Duel.BreakEffect()
			if c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)~=0 then
				-- 让玩家选择场上任意1张卡
				local g=Duel.SelectMatchingCard(tp,Card.IsOnField,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
				if #g>0 then
					-- 中断当前效果处理，使“取除素材”与“破坏卡片”不视为同时处理
					Duel.BreakEffect()
					-- 手动为选中的卡片显示被选为对象的动画效果
					Duel.HintSelection(g)
					-- 以效果原因破坏选中的卡片
					Duel.Destroy(g,REASON_EFFECT)
				end
			end
		end
	end
end
-- ②效果的发动条件：自身持有超量素材，且自身是攻击怪兽
function s.descon1(e)
	local c=e:GetHandler()
	-- 检查自身超量素材数量是否大于0，且当前攻击的怪兽是否为自身
	return c:GetOverlayCount()>0 and Duel.GetAttacker()==c
end
-- ②和③效果的发动准备：确认场上有卡存在，并设置破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取场上所有的卡片组
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD)
	if chk==0 then return #g>0 end
	-- 设置操作信息：破坏场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②和③效果的效果处理：让玩家选择场上1张卡并破坏
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 在客户端显示提示信息：“请选择要破坏的卡”
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 获取场上所有的卡，并让玩家选择其中的1张
	local g=Duel.GetFieldGroup(tp,LOCATION_ONFIELD,LOCATION_ONFIELD):Select(tp,1,1,nil)
	if #g>0 then
		-- 手动为选中的卡片显示被选为对象的动画效果
		Duel.HintSelection(g)
		-- 以效果原因破坏选中的卡片
		Duel.Destroy(g,REASON_EFFECT)
	end
end
-- ③效果的发动条件：此卡之前存在于怪兽区域，且是通过超量召唤方式特殊召唤的
function s.descon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
