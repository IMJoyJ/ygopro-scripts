--月光銀狗
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡被效果送去墓地的场合才能发动。从卡组把「月光银狗」以外的1只「月光」怪兽特殊召唤。只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「月光」怪兽不能从额外卡组特殊召唤。
-- ②：魔法·陷阱卡的效果在场上发动时，从自己墓地把这张卡和1只「月光」融合怪兽除外才能发动。那个发动无效。
local s,id,o=GetID()
-- 定义该卡的两个效果：①效果在作为效果送去墓地时从卡组特殊召唤“月光”怪兽并给该怪兽附加额外召唤限制；②效果通过除外自身和1只“月光”融合怪兽来无效场上发动的魔法·陷阱卡效果。
function s.initial_effect(c)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡被效果送去墓地的场合才能发动。从卡组把「月光银狗」以外的1只「月光」怪兽特殊召唤。
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
-- ①效果的发动条件：这张卡是被效果（而非战斗等）送去墓地。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_EFFECT)
end
-- 检索/选择的过滤：必须是「月光」怪兽、卡名不是「月光银狗」、且可以被特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0xdf) and not c:IsCode(id) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动时点的合法性检测：需要自己场上有特殊召唤用的空位，且卡组中存在符合条件的「月光」怪兽。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查卡组中是否存在满足s.spfilter的「月光」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本次操作是从卡组特殊召唤1只怪兽，用于触发相关卡片的联动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①效果处理：从卡组选择1只符合条件的「月光」怪兽特殊召唤；若特殊召唤成功，则给它附加“只要这只怪兽在自己场上表侧表示存在，自己不是「月光」怪兽不能从额外卡组特殊召唤”的限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此时没有可用主怪兽区空格，则终止本次处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示“请选择要特殊召唤的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从卡组中选取1张满足s.spfilter条件的「月光」怪兽。
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	-- 将选择的怪兽以表侧表示特殊召唤，并判断是否成功。
	if tc and Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 只要这个效果特殊召唤的怪兽在自己场上表侧表示存在，自己不是「月光」怪兽不能从额外卡组特殊召唤。
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
-- 限制效果的条件：只有特召怪兽的控制者为发动效果的一方时，该召唤限制才生效。
function s.splimitcon(e)
	return e:GetHandler():IsControler(e:GetOwnerPlayer())
end
-- 限制内容：不能从额外卡组特殊召唤非「月光」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0xdf) and c:IsLocation(LOCATION_EXTRA)
end
-- ②效果的发动条件：场上发动的效果为魔法·陷阱卡效果，且该连锁的发动可以被无效。
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的效果发动位置，用于判断是否在场上发动。
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return bit.band(loc,LOCATION_ONFIELD)~=0
		-- 确认该效果是魔法·陷阱卡效果，且该连锁能够被无效。
		and re:IsActiveType(TYPE_SPELL+TYPE_TRAP) and Duel.IsChainNegatable(ev)
end
-- ②效果cost要除外的「月光」融合怪兽的过滤条件：必须是「月光」字段的融合怪兽，且可以作为cost除外。
function s.cfilter(c)
	return c:IsSetCard(0xdf) and c:IsAllTypes(TYPE_FUSION+TYPE_MONSTER) and c:IsAbleToRemoveAsCost()
end
-- ②效果的cost检查：本卡自身可以除外，且墓地存在符合条件的「月光」融合怪兽。
function s.negcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 墓地中存在可作为cost的「月光」融合怪兽。
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) end
	-- 显示“请选择要除外的卡”的提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从墓地选择1只符合条件的「月光」融合怪兽。
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
	g:AddCard(e:GetHandler())
	-- 将自身和选择的「月光」融合怪兽表侧表示除外，作为发动代价。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- ②效果的目标判定：始终可行；设置本次无效的对象为当前连锁。
function s.negtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置操作信息：本次操作为无效魔法·陷阱卡效果的发动，目标为当前连锁的eg。
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
end
-- ②效果处理：将当前连锁的发动无效。
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	-- 执行无效动作，使目标连锁发动无效。
	Duel.NegateActivation(ev)
end
