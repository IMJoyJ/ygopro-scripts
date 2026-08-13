--ライトロード・アテナ ミネルバ
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的「光道」怪兽数量的「光道」怪兽从卡组送去墓地（相同种族最多1只）。
-- ②：自己场上的「光道」怪兽不能用效果除外。
-- ③：从自己墓地把最多4只「光道」怪兽除外才能发动。把除外数量的卡从自己卡组上面送去墓地。
local s,id,o=GetID()
-- 初始化函数：为这张卡添加同调召唤手续和苏生限制，并注册①同调召唤成功时从卡组送墓光道怪兽、②保护自己场上光道怪兽不被效果除外、③除外墓地光道怪兽后从卡组顶送墓这三个效果。
function s.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整（无限制）＋调整以外的怪兽1只，合计素材至少2只。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。把最多有那些作为同调素材的「光道」怪兽数量的「光道」怪兽从卡组送去墓地（相同种族最多1只）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"从卡组送去墓地"
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.tgcon)
	e1:SetTarget(s.tgtg)
	e1:SetOperation(s.tgop)
	c:RegisterEffect(e1)
	-- ②：自己场上的「光道」怪兽不能用效果除外。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_REMOVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.efilter)
	c:RegisterEffect(e2)
	-- ③：从自己墓地把最多4只「光道」怪兽除外才能发动。把除外数量的卡从自己卡组上面送去墓地。
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_DECKDES)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1,id+o)
	e4:SetCost(s.recost)
	e4:SetTarget(s.retg)
	e4:SetOperation(s.reop)
	c:RegisterEffect(e4)
end
-- ①的发动条件：只有这张卡以同调召唤方式成功出场时，该效果才能发动。
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 筛选可被①效果从卡组送去墓地的卡：必须是「光道」怪兽、属于怪兽卡且能够被送去墓地。
function s.tgfilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToGrave()
end
-- ①的发动时点处理：检查是否存在作为同调素材的「光道」怪兽以及卡组中是否有可送去墓地的「光道」怪兽，并在满足条件时设置从卡组送墓的操作信息。
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查发动条件：作为同调素材的怪兽中存在「光道」怪兽，且卡组中存在至少1只可送去墓地的「光道」怪兽。
	if chk==0 then return e:GetHandler():GetMaterial():FilterCount(Card.IsSetCard,nil,0x38)>0 and Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：本次效果会把卡组中的卡送去墓地，用于连锁中的效果检测。
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,0,tp,LOCATION_DECK)
end
-- 选择子组的过滤器：要求选出的卡组中所有卡种族均不相同，以对应“相同种族最多1只”的限制。
function s.fselect(g)
	return g:GetClassCount(Card.GetRace)==g:GetCount()
end
-- ①的效果处理：从卡组中选出1～（同调素材中「光道」怪兽数量）只彼此种族不同的「光道」怪兽，将其送去墓地。
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local mc=e:GetHandler():GetMaterial():FilterCount(Card.IsSetCard,nil,0x38)
	-- 获取卡组中所有满足tgfilter条件（「光道」怪兽且可送墓）的卡集合。
	local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
	if g:GetCount()>0 and mc>0 then
		-- 向玩家发出选择提示，需要选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 让玩家从符合条件的卡组「光道」怪兽中选择1～mc张种族互不相同的卡，并以效果原因送去墓地。
		Duel.SendtoGrave(g:SelectSubGroup(tp,s.fselect,false,1,mc),REASON_EFFECT)
	end
end
-- ②的效果过滤器：仅使自己场上表侧表示的「光道」怪兽不受效果除外；若除外会因其他效果改变去向（如送墓改为除外）则不适用该保护。
function s.efilter(e,c,rp,r,re)
	local tp=e:GetHandlerPlayer()
	return c:IsControler(tp) and c:IsLocation(LOCATION_MZONE) and c:IsSetCard(0x38) and c:IsFaceup()
		and r&REASON_EFFECT>0 and r&REASON_REDIRECT==0
end
-- 筛选可作为③代价除外的卡：墓地中的「光道」怪兽且能够作为代价除外。
function s.refilter(c)
	return c:IsSetCard(0x38) and c:IsType(TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ③的代价处理：在cost阶段仅设置标签标记发动流程，实际选择并除外墓地「光道」怪兽的动作推迟到target阶段执行；chk==0时总是返回true表示代价可支付。
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100)
	if chk==0 then return true end
end
-- ③的发动时处理：确认至少能从卡组顶送墓1张卡、墓地存在可除外的「光道」怪兽且卡组数量大于0；随后选择1～4只墓地「光道」怪兽除外作为代价，并设置从卡组送墓的操作信息。
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取当前玩家卡组中的卡片总数量。
	local dc=Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)
	if chk==0 then
		if e:GetLabel()~=100 then return false end
		e:SetLabel(0)
		-- 检查发动③所需条件：卡组顶端至少能送墓1张卡、墓地存在至少1只可除外的「光道」怪兽，且卡组数量大于0。
		return Duel.IsPlayerCanDiscardDeck(tp,1) and Duel.IsExistingMatchingCard(s.refilter,tp,LOCATION_GRAVE,0,1,nil) and dc>0
	end
	-- 向玩家发出选择提示，需要选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1～min(卡组数量,4)只满足refilter的「光道」怪兽作为发动代价。
	local cg=Duel.SelectMatchingCard(tp,s.refilter,tp,LOCATION_GRAVE,0,1,math.min(dc,4),nil)
	e:SetLabel(0,cg:GetCount())
	-- 将已选择的墓地「光道」怪兽以表侧表示除外，作为发动效果的费用。
	Duel.Remove(cg,POS_FACEUP,REASON_COST)
	-- 设置操作信息：本次效果将把与除外数量相同的卡从卡组送去墓地，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,cg:GetCount())
end
-- ③的效果处理：从卡组顶端将数量等于已除外「光道」怪兽数的卡送去墓地。
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	local label,count=e:GetLabel()
	-- 以效果原因将玩家卡组顶端的count张卡送去墓地。
	Duel.DiscardDeck(tp,count,REASON_EFFECT)
end
