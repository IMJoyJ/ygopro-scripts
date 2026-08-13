--ヴェーダ＝カーランタ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：场上的卡被效果破坏的场合，若场上有「维萨斯-斯塔弗罗斯特」存在则能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「新世坏」加入手卡。
-- ②：这张卡以外的自己怪兽被效果破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
local s,id,o=GetID()
-- 定义这张卡的初始效果注册函数：将『维萨斯-斯塔弗罗斯特』的卡号加入代码列表；随后创建并注册①效果（场上的卡被效果破坏时从手卡特召自身并从卡组·墓地检索「新世坏」）和②效果（自己怪兽被效果破坏时破坏对方怪兽并上升攻击力），两个效果均有1回合1次的限制。
function s.initial_effect(c)
	-- 将卡号56099748（维萨斯-斯塔弗罗斯特）登记到这张卡的代码列表，使这张卡在规则上被视为记载了该卡名，可供相关效果识别。
	aux.AddCodeList(c,56099748)
	-- ①：场上的卡被效果破坏的场合，若场上有「维萨斯-斯塔弗罗斯特」存在则能发动。这张卡从手卡特殊召唤。那之后，可以从自己的卡组·墓地把1张「新世坏」加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"这张卡从手卡特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_GRAVE_ACTION)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡以外的自己怪兽被效果破坏的场合，以对方场上1只怪兽为对象才能发动。那只怪兽破坏，这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"对方怪兽破坏"
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤条件：该卡是因效果而被破坏，且破坏前位于场上，用于判断是否满足“场上的卡被效果破坏的场合”。
function s.desfilter(c)
	return c:IsReason(REASON_EFFECT) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤条件：卡为表侧表示且卡号是56099748，即表侧表示的「维萨斯-斯塔弗罗斯特」，用于①的“若场上有「维萨斯-斯塔弗罗斯特」存在”。
function s.confilter(c)
	return c:IsFaceup() and c:IsCode(56099748)
end
-- ①的发动条件：本次被破坏的卡片组中存在满足s.desfilter的卡，即至少有1张场上的卡因效果被破坏。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter,1,nil)
end
-- ①的发动时点合法性检查：自己主要怪兽区有空位、场上有表侧表示的「维萨斯-斯塔弗罗斯特」，并且这张卡在手牌可以被特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否存在可用的主要怪兽区空格，以保证能够特殊召唤这张卡。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查场上是否存在表侧表示的「维萨斯-斯塔弗罗斯特」（卡号56099748），满足①发动所需的场合条件。
		and Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本次连锁将特殊召唤这张卡（1张），供星尘龙等需要检测连锁内容的卡判断。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 检索过滤条件：卡号为21570001（新世坏）且能够加入手卡，用于从卡组·墓地中检索。
function s.thfilter(c)
	return c:IsCode(21570001) and c:IsAbleToHand()
end
-- ①效果处理：若这张卡仍与效果关联则将其特殊召唤；特召成功后，从自己的卡组·墓地筛选出「新世坏」并让玩家决定是否加入手卡，加入后向对方展示。墓地检索受「王家长眠之谷」影响，因此使用aux.NecroValleyFilter过滤。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 实际执行特殊召唤；若特殊召唤返回0，表示这张卡没能成功特殊召唤，则不再执行后续检索。
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)==0 then return end
	-- 获取从自己卡组·墓地中选出、满足s.thfilter且不受「王家长眠之谷」影响的「新世坏」候选集合。
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil)
	-- 若存在候选卡且玩家在“是否把「新世坏」加入手卡？”的提示下选择“是”，则继续执行加入手卡的处理。
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then  --"是否把「新世坏」加入手卡？"
		-- 中断当前效果处理，使之后的加入手卡处理与之前的特殊召唤不视为同时进行，以避免合并时点。
		Duel.BreakEffect()
		-- 向玩家显示选择提示“请选择要加入手牌的卡”，为接下来的卡片选择设定消息。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tag=g:Select(tp,1,1,nil)
		-- 将选中的「新世坏」卡片加入其持有者的手卡（第二参数为nil表示回持有者手卡），操作原因为效果。
		Duel.SendtoHand(tag,nil,REASON_EFFECT)
		-- 将刚刚加入手卡的「新世坏」展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,tag)
	end
end
-- 过滤条件：该卡破坏前位于己方怪兽区域、控制者为己方且因效果被破坏，用于检测“这张卡以外的自己怪兽被效果破坏的场合”。
function s.desfilter2(c,tp)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp) and c:IsReason(REASON_EFFECT)
end
-- ②的发动条件：本次破坏事件中存在满足s.desfilter2的卡，即自己场上的怪兽被效果破坏。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.desfilter2,1,nil,tp)
end
-- ②的发动时点处理：选择对方场上1只怪兽作为对象，提示选择要破坏的卡，并设置破坏操作信息；若没有可选对象则不能发动。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) end
	-- 检查对方场上是否存在至少1只能够成为效果对象的怪兽，以满足取对象效果的条件。
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_MZONE,1,nil) end
	-- 显示选择提示“请选择要破坏的卡”，引导玩家选择要破坏的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 玩家从对方场上选择1只怪兽作为对象，并自动将该卡与当前连锁的对象关联。
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_MZONE,1,1,nil)
	-- 设置操作信息：本次连锁将破坏对象怪兽1张，供连锁检测和时点提示使用。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ②效果处理：取得对象怪兽；若对象仍与效果关联，则将其破坏；若这张卡仍与效果关联且表侧表示，则将这张卡的攻击力上升对象怪兽的原本攻击力数值，直到回合结束时有效。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得当前连锁中玩家选择的那1张对方怪兽，作为待破坏对象。
	local tc=Duel.GetFirstTarget()
	-- 判定对象怪兽仍与效果关联且破坏成功，同时这张卡仍与效果关联且表侧表示，全部满足才继续上升攻击力。
	if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)~=0
		and c:IsRelateToEffect(e) and c:IsFaceup() then
		local atk=tc:GetBaseAttack()
		-- 这张卡的攻击力直到回合结束时上升那个原本攻击力数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(atk)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
