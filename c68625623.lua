--破械冥官カムラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：以自己场上最多3张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。那之后，破坏的卡的原本种类的以下效果各能适用。
-- ●怪兽：自己抽1张。
-- ●魔法：场上1只怪兽的表示形式变更。
-- ●陷阱：场上1张其他卡破坏。
-- ②：场上的这张卡被效果破坏的场合才能发动。场上的怪兽全部破坏。
local s,id,o=GetID()
-- 注册两个效果：e1为手卡起动效果（取对象破坏、特殊召唤、抽卡、变更表示形式），e2为被效果破坏时触发的诱发选发破坏效果
function s.initial_effect(c)
	-- ①：以自己场上最多3张卡为对象才能发动。那些卡破坏，这张卡从手卡特殊召唤。那之后，破坏的卡的原本种类的以下效果各能适用。●怪兽：自己抽1张。●魔法：场上1只怪兽的表示形式变更。●陷阱：场上1张其他卡破坏。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
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
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
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
-- 过滤函数：检查该卡是否可以成为效果的对象
function s.desfilter1(c,e)
	return c:IsCanBeEffectTarget(e)
end
-- 过滤函数：检查该卡是否为表侧表示的魔法·陷阱卡
function s.desfilter2(c)
	return c:IsFaceup() and c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 子组选择条件：检查这组卡破坏离开后自己场上是否还有可用的怪兽区域
function s.fselect(g,tp)
	-- 返回这组卡离开后自己场上可用的怪兽区数量是否大于0
	return Duel.GetMZoneCount(tp,g)>0
end
-- ①效果的目标函数：检查能否选择1-3张卡且这张卡可特殊召唤，然后让玩家选择要破坏的卡，设置对象和破坏、特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 对象选择校验：该卡须在自己场上且其离开后还有可用的怪兽区域
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and Duel.GetMZoneCount(tp,chkc)>0 end
	-- 取得自己场上所有可以成为效果对象的卡
	local g=Duel.GetMatchingGroup(s.desfilter1,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return g:CheckSubGroup(s.fselect,1,3,tp) and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向玩家提示选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	local sg=g:SelectSubGroup(tp,s.fselect,false,1,3,tp)
	-- 将选择的卡组设置为连锁对象
	Duel.SetTargetCard(sg)
	-- 设置破坏的操作信息：破坏选中的卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	-- 设置特殊召唤的操作信息：特殊召唤这张卡本身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- ①效果的处理函数：破坏对象卡，特殊召唤这张卡，然后根据破坏的卡的原本种类依次询问并处理抽卡、变更表示形式、破坏其他卡的效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与连锁相关的目标卡，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 以效果原因破坏这些目标卡，若破坏数量不为0则继续处理
	if Duel.Destroy(g,REASON_EFFECT)~=0 then
		-- 取得刚才实际被破坏的卡组
		local og=Duel.GetOperatedGroup()
		local c=e:GetHandler()
		-- 若这张卡仍与连锁相关，则将这张卡以表侧表示特殊召唤到自己场上
		if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
			if og:IsExists(Card.IsType,1,nil,TYPE_MONSTER)
				-- 检查自己是否可以抽1张卡
				and Duel.IsPlayerCanDraw(tp,1)
				-- 询问玩家是否抽卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否抽卡？"
				-- 中断当前效果处理，使之后的处理视为不同时进行
				Duel.BreakEffect()
				-- 自己以效果原因抽1张卡
				Duel.Draw(tp,1,REASON_EFFECT)
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_SPELL)
				-- 检查双方场上是否存在可以变更表示形式的怪兽
				and Duel.IsExistingMatchingCard(Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
				-- 询问玩家是否变更表示形式
				and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then  --"是否改变表示形式？"
				-- 中断当前效果处理，使之后的处理视为不同时进行
				Duel.BreakEffect()
				-- 向玩家提示选择要变更表示形式的怪兽
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
				-- 让玩家从双方场上选择1只可以变更表示形式的怪兽
				local cg=Duel.SelectMatchingCard(tp,Card.IsCanChangePosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
				if cg:GetCount()>0 then
					-- 将选择的怪兽变更表示形式（攻击表示变守备表示，守备表示变攻击表示）
					Duel.ChangePosition(cg:GetFirst(),POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
				end
			end
			if og:IsExists(Card.IsType,1,nil,TYPE_TRAP)
				-- 检查双方场上是否存在这张卡以外的其他卡
				and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c)
				-- 询问玩家是否破坏其他卡
				and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then  --"是否破坏？"
				-- 中断当前效果处理，使之后的处理视为不同时进行
				Duel.BreakEffect()
				-- 向玩家提示选择要破坏的卡
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
				-- 让玩家从双方场上选择这张卡以外的1张卡
				local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,c)
				-- 显示该卡被选中的动画并记录其为处理对象
				Duel.HintSelection(g)
				-- 以效果原因破坏选中的那张卡
				Duel.Destroy(g,REASON_EFFECT)
			end
		end
	end
end
-- ②效果的发动条件：这张卡之前位于场上且是被效果破坏的
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_ONFIELD) and bit.band(r,REASON_EFFECT)~=0
end
-- ②效果的目标函数：检查场上是否存在怪兽，并将场上全部怪兽设为破坏的操作信息
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查双方场上是否存在至少1只怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 取得双方场上的全部怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 设置破坏的操作信息：破坏场上全部怪兽
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- ②效果的处理函数：取得并破坏场上全部怪兽
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得双方场上的全部怪兽
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	-- 以效果原因破坏场上全部怪兽
	Duel.Destroy(sg,REASON_EFFECT)
end
