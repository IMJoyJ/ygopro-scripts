--破滅と終焉の支配者
-- 效果：
-- 「世界末日」卡降临
-- 这个卡名的②③的效果1回合各能使用1次。
-- ①：这张卡的卡名只要在手卡·场上存在当作「终焉之王 迪米斯」使用。
-- ②：把手卡的这张卡给对方观看，支付2000基本分，从卡组把1张仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
-- ③：支付2000基本分才能发动。场上的其他卡全部破坏。那之后，这张卡的攻击力上升2900。
local s,id,o=GetID()
-- 初始化卡片效果，启用召唤限制并设置卡号变更效果，注册两个起动效果
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置该卡在场上或手牌时视为「终焉之王 迪米斯」
	aux.EnableChangeCode(c,72426662,LOCATION_MZONE+LOCATION_HAND)
	-- ②：把手卡的这张卡给对方观看，支付2000基本分，从卡组把1张仪式魔法卡除外才能发动。那张仪式魔法卡发动时的仪式召唤效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"复制仪式"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.rscost)
	e1:SetTarget(s.rstg)
	e1:SetOperation(s.rsop)
	c:RegisterEffect(e1)
	-- ③：支付2000基本分才能发动。场上的其他卡全部破坏。那之后，这张卡的攻击力上升2900。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"破坏效果"
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCost(s.descost)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断卡组中是否存在可作为仪式魔法卡除外的卡片
function s.cfilter(c)
	return c:IsAllTypes(TYPE_RITUAL+TYPE_SPELL) and c:IsAbleToRemoveAsCost() and c:CheckActivateEffect(true,true,false)~=nil
end
-- 检查是否满足②效果的费用条件，包括手卡公开和支付2000基本分
function s.rscost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsPublic()
		-- 检查是否满足②效果的费用条件，包括手卡公开和支付2000基本分
		and Duel.CheckLPCost(tp,2000) end
	-- 支付2000基本分作为②效果的费用
	Duel.PayLPCost(tp,2000)
end
-- 检查是否满足②效果的发动条件，包括手卡公开和卡组中存在符合条件的仪式魔法卡
function s.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:IsCostChecked()
		-- 检查卡组中是否存在符合条件的仪式魔法卡
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_DECK,0,1,nil)
	end
	e:SetLabel(0)
	-- 提示玩家选择要除外的仪式魔法卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择一张符合条件的仪式魔法卡并除外
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_DECK,0,1,1,nil)
	local te=g:GetFirst():CheckActivateEffect(true,true,false)
	e:SetLabelObject(te)
	-- 将选中的仪式魔法卡从卡组除外作为②效果的费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	-- 清除当前连锁的操作信息
	Duel.ClearOperationInfo(0)
end
-- 执行②效果的处理操作，复制选中仪式魔法卡的发动效果
function s.rsop(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local op=te:GetOperation()
	if op then op(e,tp,eg,ep,ev,re,r,rp) end
end
-- 检查是否满足③效果的费用条件，包括支付2000基本分
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足③效果的费用条件，包括支付2000基本分
	if chk==0 then return Duel.CheckLPCost(tp,2000)
	-- 支付2000基本分作为③效果的费用
	else Duel.PayLPCost(tp,2000) end
end
-- 设置③效果的发动目标，检测场上是否存在可破坏的卡片
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测场上是否存在可破坏的卡片
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,c) end
	-- 获取场上所有可破坏的卡片组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	-- 设置③效果的处理信息，指定要破坏的卡片数量
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,sg:GetCount(),0,0)
end
-- 执行③效果的处理操作，破坏场上其他卡片并提升自身攻击力
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取场上除自身外的所有卡片组
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,aux.ExceptThisCard(e))
	-- 破坏场上所有其他卡片
	if Duel.Destroy(sg,REASON_EFFECT)>0
		and c:IsRelateToChain() and c:IsFaceup() and c:IsType(TYPE_MONSTER) then
		-- 中断当前效果处理，使后续效果视为错时处理
		Duel.BreakEffect()
		-- 使自身攻击力上升2900
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(2900)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
