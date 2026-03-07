--月光銀狗
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被效果送去墓地的场合才能发动。从卡组把「月光银狗」以外的1只「月光」怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「月光」怪兽不能从额外卡组特殊召唤。
-- ②：魔法·陷阱卡的效果在场上发动时，从自己墓地把这张卡和1只「月光」融合怪兽除外才能发动。那个发动无效。
local s,id,o=GetID()
-- 创建两个效果，分别对应①和②效果，①为诱发选发效果，②为诱发即时效果
function s.initial_effect(c)
	-- ①：这张卡被效果送去墓地的场合才能发动。从卡组把「月光银狗」以外的1只「月光」怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：魔法·陷阱卡的效果在场上发动时，从自己墓地把这张卡和1只「月光」融合怪兽除外才能发动。那个发动无效。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"无效"
	e2:SetCategory(CATEGORY_NEGATE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetCountLimit(1,id+o)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.negcon)
	e2:SetCost(s.negcost)
	e2:SetTarget(s.negtg)
	e2:SetOperation(s.negop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：该卡因效果被送去墓地
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 过滤函数，用于筛选满足条件的「月光」怪兽（非本卡）
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动条件检查：判断场上是否有空位且卡组是否存在符合条件的怪兽
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断卡组是否存在符合条件的怪兽
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置效果①的发动信息，表示将特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数，执行特殊召唤操作并设置限制效果
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断场上是否有空位，若无则返回
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 选择满足条件的怪兽
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 执行特殊召唤操作，若成功则注册限制效果
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 限制非「月光」怪兽从额外卡组特殊召唤的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetCondition(s.splimitcon)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CONTROL)
		tc:RegisterEffect(e1,true)
	end
end
-- 限制效果的触发条件：该卡控制者为效果拥有者
function s.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 限制效果的目标过滤函数：非「月光」怪兽且在额外卡组
function s.splimit(e,c)
	return not c:IsSetCard(0xdf) and c:IsLocation(LOCATION_EXTRA)
end
-- 效果②的发动条件：发动的为魔法或陷阱卡且在场上发动
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁发动位置信息
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		-- 判断发动的为魔法或陷阱卡且该连锁可被无效
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- 过滤函数，用于筛选墓地中的「月光」融合怪兽
function s.cfilter(c)
	return c:IsSetCard(0xdf) and c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- 效果②的发动成本检查：判断是否能除外本卡和符合条件的融合怪兽
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 判断墓地是否存在符合条件的融合怪兽
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 提示玩家选择要除外的融合怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的融合怪兽
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将选中的卡除外作为发动成本
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 效果②的目标设置函数，设置发动无效的效果
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果②的发动信息，表示将使发动无效
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- 效果②的处理函数，执行发动无效操作
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行发动无效操作
	Duel.NegateActivation(ev)
end
