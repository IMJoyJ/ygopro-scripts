--アクセスコード・トーカー
-- 效果：
-- 效果怪兽2只以上
-- 对方不能对应这张卡的效果的发动把效果发动。
-- ①：这张卡连接召唤的场合，以那1只作为连接素材的连接怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的连接标记数量×1000。
-- ②：从自己的场上·墓地把1只连接怪兽除外才能发动。对方场上1张卡破坏。这个回合，自己不能为让「访问码语者」的效果发动而把相同属性的怪兽除外。
function c86066372.initial_effect(c)
	c:EnableReviveLimit()
	-- 添加连接召唤手续，需要2只以上的效果怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkType,TYPE_EFFECT),2)
	-- ①：这张卡连接召唤的场合，以那1只作为连接素材的连接怪兽为对象才能发动。这张卡的攻击力上升那只怪兽的连接标记数量×1000。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(86066372,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCondition(c86066372.atkcon)
	e1:SetTarget(c86066372.atktg)
	e1:SetOperation(c86066372.atkop)
	c:RegisterEffect(e1)
	-- ②：从自己的场上·墓地把1只连接怪兽除外才能发动。对方场上1张卡破坏。这个回合，自己不能为让「访问码语者」的效果发动而把相同属性的怪兽除外。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(86066372,1))
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c86066372.descost)
	e2:SetTarget(c86066372.destg)
	e2:SetOperation(c86066372.desop)
	c:RegisterEffect(e2)
end
-- 过滤作为连接素材且存在于墓地或除外状态（表侧表示）的连接怪兽，且该怪兽可以被选为效果对象
function c86066372.atkfilter(c,e)
	return c:IsType(TYPE_LINK) and (c:IsLocation(LOCATION_GRAVE) or (c:IsLocation(LOCATION_REMOVED) and c:IsFaceup()))
		and c:IsCanBeEffectTarget(e)
end
-- 连锁限制条件函数，仅允许发动效果的玩家进行连锁（即对方不能对应发动效果）
function c86066372.chainlm(e,ep,tp)
	return tp==ep
end
-- 检查这张卡是否是通过连接召唤特殊召唤的
function c86066372.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
-- 效果①的靶向（Target）函数，获取连接素材并选择其中1只连接怪兽作为对象，同时设置连锁限制
function c86066372.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local mg=e:GetHandler():GetMaterial()
	if mg:GetCount()<1 then return false end
	if chkc then return mg:IsContains(chkc) and c86066372.atkfilter(chkc,e) end
	if chk==0 then return mg:IsExists(c86066372.atkfilter,1,nil,e) end
	-- 给玩家发送提示信息，提示选择效果的对象
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	local g=mg:FilterSelect(tp,c86066372.atkfilter,1,1,nil,e)
	-- 将选择的卡片设置为当前连锁的效果对象
	Duel.SetTargetCard(g)
	-- 设定连锁限制，使得对方不能对应这个效果的发动来发动效果
	Duel.SetChainLimit(c86066372.chainlm)
end
-- 效果①的处理（Operation）函数，使这张卡的攻击力上升作为对象的怪兽的连接标记数量×1000
function c86066372.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁中被选为对象的卡片
	local tc=Duel.GetFirstTarget()
	if c:IsFaceup() and c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 这张卡的攻击力上升那只怪兽的连接标记数量×1000。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(tc:GetLink()*1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己场上或墓地可以作为发动代价除外的连接怪兽
function c86066372.cfilter(c)
	return c:IsType(TYPE_LINK) and c:IsAbleToRemoveAsCost() and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
end
-- 效果②的代价（Cost）函数，从自己场上或墓地选择1只连接怪兽除外，并记录其属性
function c86066372.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上或墓地是否存在至少1只可以作为发动代价除外的连接怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c86066372.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息，提示选择要除外的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上或墓地选择1只满足条件的连接怪兽
	local g=Duel.SelectMatchingCard(tp,c86066372.cfilter,tp,LOCATION_MZONE+LOCATION_GRAVE,0,1,1,nil)
	e:SetLabel(g:GetFirst():GetAttribute())
	-- 将选择的怪兽表侧表示除外，作为发动效果的代价
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的靶向（Target）函数，检查对方场上是否有卡，设置破坏操作信息，并设置连锁限制
function c86066372.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查对方场上是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 获取对方场上所有的卡片
	local g=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD,nil)
	-- 设置破坏操作信息，表示该效果在处理时会破坏对方场上的1张卡
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	-- 设定连锁限制，使得对方不能对应这个效果的发动来发动效果
	Duel.SetChainLimit(c86066372.chainlm)
end
-- 效果②的处理（Operation）函数，让玩家选择对方场上1张卡破坏，并注册“本回合不能将相同属性的怪兽除外以发动访问码语者效果”的限制
function c86066372.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 给玩家发送提示信息，提示选择要破坏的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 让玩家选择对方场上的1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	if g:GetCount()>0 then
		-- 闪烁显示被选中的卡片，向双方玩家展示
		Duel.HintSelection(g)
		-- 因效果将选中的卡片破坏
		Duel.Destroy(g,REASON_EFFECT)
	end
	-- 这个回合，自己不能为让「访问码语者」的效果发动而把相同属性的怪兽除外。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_REMOVE)
	e1:SetTargetRange(1,0)
	e1:SetTarget(c86066372.rmlimit)
	e1:SetLabel(e:GetLabel())
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 在全局环境中为玩家注册该限制效果，持续到回合结束
	Duel.RegisterEffect(e1,tp)
end
-- 限制除外的具体条件函数，阻止玩家为了发动「访问码语者」的效果而将与本次发动相同属性的怪兽作为代价除外
function c86066372.rmlimit(e,c,tp,r,re)
	return c:IsAttribute(e:GetLabel()) and re and re:IsActiveType(TYPE_MONSTER) and re:GetHandler():IsCode(86066372) and r==REASON_COST
end
