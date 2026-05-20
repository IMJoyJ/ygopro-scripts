--トレジャー・パンサー
-- 效果：
-- 这个卡名的①②③的效果1回合各能使用1次。
-- ①：这张卡在手卡存在，场上有里侧守备表示怪兽存在的场合才能发动。这张卡特殊召唤。
-- ②：以场上最多3只里侧守备表示怪兽为对象才能发动。那些怪兽变成攻击表示。这个效果把3只怪兽变成攻击表示的场合，再给与对方900伤害。
-- ③：这张卡反转的场合才能发动。从卡组把1只通常怪兽送去墓地。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- ①：这张卡在手卡存在，场上有里侧守备表示怪兽存在的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：以场上最多3只里侧守备表示怪兽为对象才能发动。那些怪兽变成攻击表示。这个效果把3只怪兽变成攻击表示的场合，再给与对方900伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"变更表示形式"
	e2:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetTarget(s.cptg)
	e2:SetOperation(s.cpop)
	c:RegisterEffect(e2)
	-- ③：这张卡反转的场合才能发动。从卡组把1只通常怪兽送去墓地。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"送去墓地"
	e3:SetCategory(CATEGORY_TOGRAVE)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,id+o*2)
	e3:SetTarget(s.tgtg)
	e3:SetOperation(s.tgop)
	c:RegisterEffect(e3)
end
-- 效果①的发动条件判定函数
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在里侧守备表示怪兽
	return Duel.IsExistingMatchingCard(Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,POS_FACEDOWN_DEFENSE)
end
-- 效果①的发动准备与合法性检测函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果①的效果处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() then
		-- 将这张卡特殊召唤到自己场上
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 过滤可改变表示形式的里侧守备表示怪兽
function s.cpfilter(c)
	return c:IsPosition(POS_FACEDOWN_DEFENSE) and c:IsCanChangePosition()
end
-- 效果②的发动准备与对象选择函数
function s.cptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.cpfilter(chkc) end
	-- 检查场上是否存在可作为对象的里侧守备表示怪兽
	if chk==0 then return Duel.IsExistingTarget(s.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 提示玩家选择里侧表示的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEDOWN)  --"请选择里侧表示的卡"
	-- 选择1到3只里侧守备表示怪兽作为效果对象
	local g=Duel.SelectTarget(tp,s.cpfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,3,nil)
	-- 设置改变表示形式的操作信息
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	if g:GetCount()==3 then
		e:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
		-- 设置给与对方900伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,900)
	else
		e:SetCategory(CATEGORY_POSITION)
	end
end
-- 过滤仍存在于场上且非攻击表示的怪兽
function s.filter(c)
	return c:IsRelateToChain() and c:IsLocation(LOCATION_MZONE)
		and c:IsType(TYPE_MONSTER) and not c:IsPosition(POS_ATTACK)
end
-- 效果②的效果处理函数
function s.cpop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁中仍有效的对象怪兽
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS):Filter(s.filter,nil)
	if g:GetCount()>0 then
		-- 将对象怪兽变成表侧攻击表示，并获取成功改变表示形式的怪兽数量
		local oc=Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		if oc==3 then
			-- 中断当前效果处理，使后续伤害处理不与改变表示形式同时进行
			Duel.BreakEffect()
			-- 给与对方900点伤害
			Duel.Damage(1-tp,900,REASON_EFFECT)
		end
	end
end
-- 过滤卡组中可送去墓地的通常怪兽
function s.tgfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsAbleToGrave()
end
-- 效果③的发动准备与合法性检测函数
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可送去墓地的通常怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置从卡组将1张卡送去墓地的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
-- 效果③的效果处理函数
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从卡组选择1只通常怪兽
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的怪兽送去墓地
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end
