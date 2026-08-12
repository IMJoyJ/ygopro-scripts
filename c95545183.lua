--異譚の忍法帖
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：对方场上有卡存在的场合才能发动。「异谭的忍法帖」以外的「忍法」魔法·陷阱卡以及「忍者」怪兽各最多1张从自己的卡组·墓地选出在自己场上盖放（从卡组·墓地各只能有最多1张盖放）。
-- ②：盖放的这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含①效果（发动并盖放卡片）和②效果（送墓变里侧守备表示）
function s.initial_effect(c)
	-- ①：对方场上有卡存在的场合才能发动。「异谭的忍法帖」以外的「忍法」魔法·陷阱卡以及「忍者」怪兽各最多1张从自己的卡组·墓地选出在自己场上盖放（从卡组·墓地各只能有最多1张盖放）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON+CATEGORY_GRAVE_ACTION+CATEGORY_MSET+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.setcon)
	e1:SetTarget(s.settg)
	e1:SetOperation(s.setop)
	c:RegisterEffect(e1)
	-- ②：盖放的这张卡被送去墓地的场合，以场上1只表侧表示怪兽为对象才能发动。那只怪兽变成里侧守备表示。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_MSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetCountLimit(1,id+o)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件判定函数：对方场上有卡存在
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查对方场上的卡片数量是否大于0
	return Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
end
-- 过滤函数：筛选卡组或墓地中可以特殊召唤的「忍者」怪兽，或者可以盖放的「忍法」魔陷（不含同名卡）
function s.filter(c,e,tp,sft)
	-- 如果是怪兽卡，则必须是「忍者」怪兽，且己方怪兽区域有空位
	if c:IsType(TYPE_MONSTER) then return c:IsSetCard(0x2b) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEDOWN_DEFENSE)
	else return c:IsSetCard(0x61) and (c:IsType(TYPE_FIELD) or sft>0)
		and c:IsSSetable(true) and not c:IsCode(id) end
end
-- ①效果的发动准备与合法性检测函数（Target）
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		-- 获取己方魔法与陷阱区域的可用空格数
		local sft=Duel.GetLocationCount(tp,LOCATION_SZONE)
		if e:IsHasType(EFFECT_TYPE_ACTIVATE) and not e:GetHandler():IsLocation(LOCATION_SZONE) then sft=sft-1 end
		-- 检查卡组或墓地中是否存在至少1张满足条件的「忍者」怪兽或「忍法」魔陷
		return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,e,tp,sft)
	end
	-- 设置连锁处理的操作信息：从卡组或墓地特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
end
-- 组选择检查函数：确保选出的卡片中「忍者」怪兽和「忍法」魔陷各不超过1张，且卡组和墓地各最多选1张
function s.gcheck(g)
	return g:FilterCount(Card.IsSetCard,nil,0x2b)<2 and g:FilterCount(Card.IsSetCard,nil,0x61)<2
		and g:GetClassCount(Card.GetLocation)==#g
end
-- ①效果的实际处理函数（Operation）：从卡组·墓地选择卡片并盖放
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取己方怪兽区域和魔陷区域的可用空格数
	local mft,sft=Duel.GetLocationCount(tp,LOCATION_MZONE),Duel.GetLocationCount(tp,LOCATION_SZONE)
	if mft<=0 and sft<=0 then return end
	-- 获取卡组和墓地中所有满足条件的卡片（受王家长眠之谷影响）
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.filter),tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp,sft)
	-- 向玩家发送提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	local tg=g:SelectSubGroup(tp,s.gcheck,false,1,2)
	if not tg then return end
	-- 从选中的卡片中筛选出非怪兽卡（即魔陷卡）
	local sg=tg:Filter(aux.NOT(Card.IsType),nil,TYPE_MONSTER)
	if #sg>0 then
		-- 将选中的魔陷卡在己方场上盖放
		Duel.SSet(tp,sg)
	end
	local mg=tg:Filter(Card.IsType,nil,TYPE_MONSTER)
	if #mg>0 then
		-- 将选中的怪兽以里侧守备表示特殊召唤到己方场上
		Duel.SpecialSummon(mg,0,tp,tp,false,false,POS_FACEDOWN_DEFENSE)
		-- 让对方玩家确认特殊召唤的里侧怪兽
		Duel.ConfirmCards(1-tp,mg)
	end
end
-- ②效果的发动条件判定函数：盖放的这张卡被送去墓地
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEDOWN) and c:IsPreviousLocation(LOCATION_ONFIELD)
end
-- 过滤函数：筛选场上可以变成里侧守备表示的表侧表示怪兽
function s.pfilter(c)
	return c:IsFaceup() and c:IsCanTurnSet()
end
-- ②效果的发动准备与取对象函数（Target）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.pfilter(chkc) end
	-- 在发动时，检查场上是否存在至少1只可以变成里侧守备表示的表侧表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向玩家发送提示信息：请选择表侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择场上1只表侧表示怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,s.pfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	-- 设置连锁处理的操作信息：改变1张卡片表示形式
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- ②效果的实际处理函数（Operation）：将对象怪兽变成里侧守备表示
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取本次效果发动的对象怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsLocation(LOCATION_MZONE) and tc:IsFaceup() then
		-- 将对象怪兽变成里侧守备表示
		Duel.ChangePosition(tc,POS_FACEDOWN_DEFENSE)
	end
end
