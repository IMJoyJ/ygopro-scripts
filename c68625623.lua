--破械冥官カムラ
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：以自己场上最多3张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。那之后，可以根据破坏的卡的种类适用以下效果。●怪兽：自己抽1张。●魔法：场上1只怪兽的表示形式变更。●陷阱：场上1张卡破坏。
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
	-- ②：场上的这张卡被效果破坏的场合才能发动。场上的怪兽全部破坏。
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
-- 过滤可以成为效果对象的己方场上的卡片
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 过滤表侧表示的魔法与陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 过滤选择卡片组时的合法性，保证选中的卡片离开后己方场上有空余的怪兽区域
function s.fselect(g,tp)
	-- 返回选中的卡片组从场上离开后，是否有空余的主要怪兽区域用于特殊召唤
	return Duel.GetMZoneCount(tp,g)>0
end
-- 效果①（特殊召唤并破坏、追加处理）的发动检测与对象选择
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 在连锁处理前进行对象合法性的追加判定
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and Duel.GetMZoneCount(tp,chkc)>0 end
	-- 获取自己场上所有可作为效果对象的卡片
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,3,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 提示玩家选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,3,tp)
	-- 将选择的卡片设置为该连锁的对象
	Duel.SetTargetCard(sg)
	-- 设置效果处理的操作信息为破坏选中的卡片
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 设置效果处理的操作信息为特殊召唤此卡
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①（特殊召唤并破坏、追加处理）的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中仍与效果有关联且不受王家长眠之谷影响的对象卡片
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 破坏选中的对象卡片，若成功破坏的数量不为0，则继续处理
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 获取上一步破坏操作中实际被破坏的卡片组
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 若此卡在连锁中依然关联，将其特殊召唤到己方场上，成功则继续进行追加处理
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if og:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
				-- 判定玩家此时是否可以抽卡
				and Duel.IsPlayerCanDraw(tp,1)
				-- 询问玩家是否执行抽卡效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
				-- 中断当前效果，使后续的抽卡处理不与特殊召唤同时进行
				Duel.BreakEffect()
				-- 让玩家从卡组抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_SPELL)
				-- 判定场上是否存在可以变更表示形式的怪兽
				and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 询问玩家是否执行变更表示形式效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
				-- 中断当前效果，使后续的变更表示形式处理不与前序动作同时进行
				Duel.BreakEffect()
				-- 提示玩家选择要改变表示形式的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
				-- 选择场上1只可以变更表示形式的怪兽
				local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
				if cg:GetCount()>0 then
					-- 将选择的怪兽变更表示形式
					Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
				end
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_TRAP)
				-- 判定场上是否存在除本卡以外的其他卡片
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
				-- 询问玩家是否执行破坏效果
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
				-- 中断当前效果，使后续的破坏处理不与前序动作同时进行
				Duel.BreakEffect()
				-- 提示玩家选择要破坏的卡片
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 选择场上除本卡以外的1张卡片
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
				-- 为选中的破坏目标卡片显示被选择的动画
				Duel.HintSelection(g)
				-- 将选择的卡片破坏
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
-- 效果②（破坏全场怪兽）的发动条件判定
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
-- 效果②（破坏全场怪兽）的发动检测与效果分类设置
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 在发动准备阶段检测场上是否存在怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 获取场上所有的怪兽卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置效果处理的操作信息为破坏场上所有的怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 效果②（破坏全场怪兽）的效果处理函数
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取场上所有的怪兽卡
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 破坏场上的所有怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
