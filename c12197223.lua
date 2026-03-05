--天雷ノ双風神 シーナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：自己场上有风属性怪兽存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。那之后，那个对方的效果种类的以下效果适用。
-- ●怪兽：「天雷之双风神 息那」以外的场上的表侧表示怪兽全部回到手卡。
-- ●魔法·陷阱：场上的魔法·陷阱卡全部回到手卡。
-- ②：这张卡1回合只有1次不会被战斗破坏。
local s,id,o=GetID()
-- 注册效果：①效果为诱发即时效果，发动条件为对方发动魔法·陷阱·怪兽效果，满足条件时可从手卡特殊召唤并触发后续效果
function s.initial_effect(c)
	-- ①：自己场上有风属性怪兽存在，对方把魔法·陷阱·怪兽的效果发动时才能发动。这张卡从手卡特殊召唤。那之后，那个对方的效果种类的以下效果适用。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_CHAINING)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡1回合只有1次不会被战斗破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e2:SetCountLimit(1)
	e2:SetValue(s.valcon)
	c:RegisterEffect(e2)
end
-- 过滤函数：检查场上是否存在正面表示的风属性怪兽
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_WIND)
end
-- 效果发动条件函数：判断是否为对方发动效果且己方场上存在风属性怪兽
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
		-- 检查己方场上是否存在至少1只正面表示的风属性怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 过滤函数：根据效果类型（怪兽或魔法陷阱）筛选可送回手牌的卡
function s.thfilter(c,res)
	if c:IsCode(id) and c:IsLocation(LOCATION_MZONE) then return false end
	return (res and c:IsFaceup() and c:IsType(TYPE_MONSTER)
		or not res and c:IsType(TYPE_SPELL+TYPE_TRAP)) and c:IsAbleToHand()
end
-- 效果的发动准备函数：判断是否满足特殊召唤条件并设置操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local res=re:IsActiveType(TYPE_MONSTER)
	if chk==0 then
		-- 检查己方怪兽区域是否有空位
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
			-- 检查场上是否存在满足条件的卡（用于送回手牌）
			and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,res)
	end
	-- 获取满足条件的卡组用于送回手牌
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,res)
	if res then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
	-- 设置操作信息：将目标卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,g:GetCount(),0,0)
	-- 设置操作信息：将自身特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果处理函数：特殊召唤自身并根据对方效果类型执行后续处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断自身是否能特殊召唤并执行特殊召唤
	if c:IsRelateToChain() and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		local res=false
		if e:GetLabel()==1 then res=true end
		-- 获取满足条件的卡组用于送回手牌
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,res)
		if g:GetCount()>0 then
			-- 中断当前连锁处理，使后续效果视为错时处理
			Duel.BreakEffect()
			-- 将符合条件的卡送回手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
		end
	end
end
-- 效果值函数：判断是否为战斗破坏导致的破坏
function s.valcon(e,re,r,rp)
	return bit.band(r,REASON_BATTLE)~=0
end
