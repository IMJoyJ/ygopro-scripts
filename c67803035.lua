--破械転生
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：作为这张卡的发动时的效果处理，可以从卡组把1张「破械转生」以外的「破械」魔法卡或「双王之械」加入手卡。
-- ②：1回合1次，以「破械转生」以外的自己墓地最多3张「破械」卡为对象才能发动。那些卡回到卡组。那之后，可以把最多有回去数量的自己场上的其他卡破坏。
local s,id,o=GetID()
-- 初始化卡片效果：注册「双王之械」的卡名记载信息，并注册两个效果——e1为魔法卡发动时的检索效果（每回合只能发动1张同名卡），e2为魔法陷阱区域的取对象起动效果（回收墓地「破械」卡并可选破坏场上卡）
function s.initial_effect(c)
	-- 在这张卡上登记记载了卡名「双王之械」（卡号27412542）的信息
	aux.AddCodeList(c,27412542)
	-- 这个卡名的卡在1回合只能发动1张。①：作为这张卡的发动时的效果处理，可以从卡组把1张「破械转生」以外的「破械」魔法卡或「双王之械」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以「破械转生」以外的自己墓地最多3张「破械」卡为对象才能发动。那些卡回到卡组。那之后，可以把最多有回去数量的自己场上的其他卡破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_TODECK+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	c:RegisterEffect(e2)
end
-- 检索过滤器：满足条件的卡需不是「破械转生」自身，且为「双王之械」或「破械」魔法卡，并能加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and (c:IsCode(27412542) or c:IsSetCard(0x130) and c:IsType(TYPE_SPELL)) and c:IsAbleToHand()
end
-- 发动时的效果处理：从卡组检索满足条件的卡，由玩家确认是否加入手卡，是则选择1张加入手卡并向对方展示
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- 从自己的卡组中检索出所有满足条件的卡组成卡片组
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在满足条件的卡，则询问玩家是否将其加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then  --"是否加入手卡？"
		-- 向玩家提示选择要加入手卡的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 把选择的卡以效果的原因加入持有者的手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的卡
		Duel.ConfirmCards(1-tp,sg)
	end
end
-- 回收对象过滤器：满足条件的卡需不是「破械转生」自身，且为「破械」卡并能回到卡组
function s.tdfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x130) and c:IsAbleToDeck()
end
-- 取对象目标函数：在效果适用对象判定时确认候选卡位于自己墓地且满足过滤器并排除这张卡自身；在发动条件判定时确认自己墓地存在至少1张可取为对象的满足条件的卡，且这张卡不在连锁处理中
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.tdfilter(chkc) and chkc~=e:GetHandler() end
	-- 发动条件：确认自己墓地存在至少1张可取为对象的满足条件的卡（这张卡自身除外）
	if chk==0 then return Duel.IsExistingTarget(s.tdfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler())
		and not e:GetHandler():IsStatus(STATUS_CHAINING) end
	-- 向玩家提示选择要回到卡组的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 让玩家以自己墓地1至3张满足条件的卡为对象（这张卡自身除外）
	local g=Duel.SelectTarget(tp,s.tdfilter,tp,LOCATION_GRAVE,0,1,3,e:GetHandler())
	-- 设置连锁的操作信息：声明本连锁确定要处理的是把这些作为对象的卡回到卡组（回卡组分类）
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,g:GetCount(),0,0)
end
-- 效果处理：把作为对象的卡（不受王家长眠之谷影响的）回到卡组并洗切，统计实际回去的数量；若有卡回去且自己场上存在其他卡，则询问玩家是否破坏卡，是则中断时点并选择最多与回去数量相同的自己场上其他卡破坏
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得与本连锁关联的对象卡，并过滤掉受王家长眠之谷影响的卡
	local g=Duel.GetTargetsRelateToChain():Filter(aux.NecroValleyFilter(),nil)
	-- 若对象卡存在，则把它们回到卡组并洗切，且实际有卡被送回时才继续处理
	if g:GetCount()>0 and Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)~=0 then
		-- 统计这次操作中实际回到卡组或额外卡组的卡的数量，作为可破坏数量的上限
		local ct=Duel.GetOperatedGroup():FilterCount(Card.IsLocation,nil,LOCATION_DECK+LOCATION_EXTRA)
		-- 确认有卡回去，并且自己场上存在这张卡以外的其他卡
		if ct>0 and Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,0,1,aux.ExceptThisCard(e))
			-- 询问玩家是否把自己场上的卡破坏
			and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把卡破坏？"
			-- 中断当前效果处理，使之后的破坏处理视为不同时进行（产生错时点）
			Duel.BreakEffect()
			-- 向玩家提示选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			-- 让玩家从自己场上选择1至最多与回去数量相同的、这张卡以外的卡
			local sg=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_ONFIELD,0,1,ct,aux.ExceptThisCard(e))
			-- 为选择的卡显示被选中的动画并记录这些卡被选择
			Duel.HintSelection(sg)
			-- 以效果的原因破坏选择的卡
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end
