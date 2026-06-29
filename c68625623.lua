--破械冥官カムラ
local s,id,o=GetID()
-- 注册卡片效果的入口函数，定义并注册此卡的效果。
function s.initial_effect(c)
	-- ①：以我方场上的卡片最多3张为对象可以发动。那些卡破坏，此卡从手牌特殊召唤。那之后，可以根据破坏的卡的原种类分别适用以下效果。●怪兽：我方从卡组抽1张。●魔法：选场上1只怪兽把表示形式变更。●陷阱：选场上其他的1张卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：场上的此卡被效果破坏的场合可以发动。场上的怪兽全部破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 定义选择破坏目标时的过滤函数，用于判断卡片是否可以成为效果的对象
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 定义过滤函数，用于判断卡片是否为场上表侧表示的魔法或陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 定义组合过滤函数，判断所选卡片被破坏后是否能空出足够的怪兽区域用于特殊召唤此卡
function s.fselect(g,tp)
	-- 判断扣除被破坏的卡后，自己场上可用的怪兽区数量是否大于0
	return Duel.GetMZoneCount(tp,g)>0
end
-- 定义特殊召唤效果的发动准备与检查函数（Target）
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 处理指向性效果（取对象）的重指向检查逻辑，判断目标是否为我方场上卡片，且其离开后能否空出怪兽区域
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and Duel.GetMZoneCount(tp,chkc)>0 end
	-- 获取我方场上所有满足可以作为效果对象的卡片组
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,3,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 给发动效果的玩家提示：选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,3,tp)
	-- 将玩家选定的要破坏的卡片组注册为当前连锁的目标（取对象）
	Duel.SetTargetCard(sg)
	-- 在连锁中设置要破坏这些卡片的操作信息，包含卡片组及数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 在连锁中设置要将此卡从手牌特殊召唤的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 定义特殊召唤效果的执行处理逻辑函数（Operation）
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取上一次破坏操作中实际被成功破坏并送入相应位置的卡片组
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 判断此卡是否仍与连锁关联，若是则尝试将其表侧表示特殊召唤到我方场上，并判断是否召唤成功
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if og:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
				-- 判断玩家是否具备从卡组抽1张牌的条件
				and Duel.IsPlayerCanDraw(tp,1)
				-- 询问玩家是否要选择适用抽卡效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断效果处理，使后续效果与之前的操作视为不同时处理
				Duel.BreakEffect()
				-- 由于适用怪兽原种类的效果，玩家从卡组抽1张牌
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_SPELL)
				-- 判断场上是否存在至少1只可以变更表示形式的怪兽
				and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 询问玩家是否要选择适用表示形式变更效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断效果处理，使后续表示形式变更操作与之前的操作视为不同时处理
				Duel.BreakEffect()
				-- 给发动效果的玩家提示：选择要改变表示形式的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
				-- 让玩家在双方场上选择1只可以变更表示形式的怪兽
				local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
				if cg:GetCount()>0 then
					-- 变更选定怪兽的表示形式（如果原为攻击表示则变为表侧守备表示，反之亦然）
					Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
				end
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_TRAP)
				-- 判断场上除了此卡以外，是否存在至少1张卡片
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
				-- 询问玩家是否要选择适用破坏场上其他卡片的效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				-- 中断效果处理，使后续破坏卡片操作与之前的操作视为不同时处理
				Duel.BreakEffect()
				-- 给发动效果的玩家提示：选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 让玩家在场上选择除此卡以外的1张要破坏的卡片
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
				-- 为选中的目标卡片显示指示对象的动画
				Duel.HintSelection(g)
				-- 将选中的目标卡片用效果破坏
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
-- 定义被效果破坏的诱发效果的发动条件判断函数
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
-- 定义被效果破坏的诱发效果的发动准备与检查函数（Target）
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有的怪兽卡组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置要把场上全部怪兽破坏的操作信息，包含卡片组和数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 定义被效果破坏的诱发效果的执行逻辑函数（Operation）
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前场上的所有怪兽卡组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 执行将场上所有怪兽全部破坏的效果
	Duel.Destroy(sg,REASON_EFFECT)
end
