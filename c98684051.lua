--白鰯
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：从卡组把1只「白鰯」送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能从额外卡组特殊召唤。
-- ②：这张卡从墓地特殊召唤的场合才能发动。这个回合，这张卡当作调整使用。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含手牌特召效果（e1）和墓地特召当作调整效果（e2）
function s.initial_effect(c)
	-- ①：从卡组把1只「白鰯」送去墓地才能发动。这张卡从手卡特殊召唤。这个效果的发动后，直到回合结束时自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从墓地特殊召唤的场合才能发动。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.tncon)
	e2:SetOperation(s.tnop)
	c:RegisterEffect(e2)
end
s.treat_itself_tuner=true
-- 过滤卡组中同名卡「白鰯」且能作为代价送去墓地的卡片过滤函数
function s.filter(c)
	return c:IsCode(id) and c:IsAbleToGraveAsCost()
end
-- 效果①的发动代价：从卡组将1只「白鰯」送去墓地
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 代价合法性检查：检查卡组中是否存在可以送去墓地的「白鰯」
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 让玩家从卡组选择1张「白鰯」
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,1,nil)
	-- 将选中的卡作为发动代价送去墓地
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果①的发动准备：检查怪兽区域空位并确认自身是否可以特殊召唤，并设置特殊召唤的操作信息
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上是否有可用的怪兽区域空格
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息，表示此效果会特殊召唤1张自身
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 效果①的效果处理：将自身特殊召唤，并注册“不能从额外卡组特殊召唤水属性以外的怪兽”的限制
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若此卡仍存在于原本位置，则将其在自己场上表侧表示特殊召唤
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
	-- 这个效果的发动后，直到回合结束时自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.limit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 给玩家注册该回合内不能从额外卡组特殊召唤水属性以外怪兽的限制效果
	Duel.RegisterEffect(e1,tp)
end
-- 限制效果的过滤函数：限制从额外卡组特殊召唤非水属性的怪兽
function s.limit(e,c,sp,st,spos,tp,se)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsAttribute(ATTRIBUTE_WATER)
end
-- 效果②的发动条件：检查此卡是否是从墓地特殊召唤
function s.tncon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_GRAVE)
end
-- 效果②的效果处理：给自身添加“当作调整使用”的状态，持续到回合结束
function s.tnop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		-- 这个回合，这张卡当作调整使用。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_ADD_TYPE)
		e1:SetValue(TYPE_TUNER)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
