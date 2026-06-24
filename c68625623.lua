--破械冥官カムラ
local s,id,o=GetID()
-- 创建两个效果，第一个为起动效果，第二个为被破坏时的诱发效果
function s.initial_effect(c)
	-- 此卡手牌时可以发动的效果，可以特殊召唤自身并破坏场上对象，同时进行抽卡和改变表示形式操作
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
	-- 此卡被破坏时发动的效果，可以破坏对方场上的所有怪兽
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
-- 过滤函数，用于判断卡片是否可以成为效果的对象
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 过滤函数，用于判断卡片是否为表侧表示的魔法或陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 选择函数，用于判断所选卡片组是否能召唤怪兽
function s.fselect(g,tp)
	-- 判断所选卡片组是否能召唤怪兽
	return Duel.GetMZoneCount(tp,g)>0
end
-- 特殊召唤效果的处理函数，用于选择破坏对象并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 判断目标区域是否有怪兽区可用
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and Duel.GetMZoneCount(tp,chkc)>0 end
	-- 获取场上可以成为效果对象的卡
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,3,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,3,tp)
	-- 设置当前连锁的目标卡为所选卡组
	Duel.SetTargetCard(sg)
	-- 设置操作信息为破坏效果，数量为所选卡组数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 设置操作信息为特殊召唤效果，数量为1
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 特殊召唤效果的处理函数，用于执行破坏、特殊召唤和后续效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取与当前连锁相关的对象卡组
	local g=Duel.GetTargetsRelateToChain()
	-- 将目标卡组进行破坏操作
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取实际被破坏的卡组
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 判断自身是否参与连锁并进行特殊召唤
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if og:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
				-- 检查玩家是否可以抽卡
				and Duel.IsPlayerCanDraw(tp,1)
				-- 询问玩家是否发动抽卡效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 让玩家抽一张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_SPELL)
				-- 检查场上是否存在可以改变表示形式的怪兽
				and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 询问玩家是否发动改变表示形式效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要改变表示形式的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
				-- 选择一个可以改变表示形式的怪兽
				local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
				if cg:GetCount()>0 then
					-- 将所选怪兽变为表侧守备表示或表侧攻击表示
					Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
				end
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_TRAP)
				-- 检查场上是否存在可破坏的卡片
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
				-- 询问玩家是否发动破坏效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				-- 中断当前效果处理，使后续效果视为错时点
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 选择一个可以被破坏的卡片
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
				-- 显示所选卡片被选为对象的动画效果
				Duel.HintSelection(g)
				-- 将所选卡片进行破坏操作
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
-- 被破坏时效果的发动条件，判断是否为效果破坏且在场上被破坏
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
-- 破坏效果的目标设定函数，用于选择对方场上的所有怪兽
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少一张怪兽卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取对方场上的所有怪兽卡组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置操作信息为破坏效果，数量为所选卡组数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 被破坏时效果的处理函数，用于破坏对方场上的所有怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取对方场上的所有怪兽卡组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 将所选怪兽进行破坏操作
	Duel.Destroy(sg,REASON_EFFECT)
end
