--火天獣－キャンドル
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
-- ②：1回合最多3次，怪兽被送去自己墓地的场合才能发动（同一连锁上最多1次）。这张卡的等级上升或下降1星。
local s,id,o=GetID()
-- 注册①效果：这张卡用抽卡以外的方法加入手卡的场合才能发动，将其特殊召唤；注册②效果：该卡在自己场上存在时，1回合最多3次，怪兽被送去自己墓地的场合才能发动（同一连锁上最多1次），该卡等级上升或下降1星。
function s.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡用抽卡以外的方法加入手卡的场合才能发动。这张卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_TO_HAND)
	e1:SetCountLimit(1,id)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	-- ②：1回合最多3次，怪兽被送去自己墓地的场合才能发动（同一连锁上最多1次）。这张卡的等级上升或下降1星。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"等级变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(3)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(s.lvcon)
	e2:SetTarget(s.lvtg)
	e2:SetOperation(s.lvop)
	c:RegisterEffect(e2)
end
-- ①效果的发动条件：这张卡加入手卡的原因不是抽卡，即用抽卡以外的方法加入手卡。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsReason(REASON_DRAW)
end
-- ①效果发动时检查：自己主要怪兽区有空位，且这张卡可以被自己以表侧表示特殊召唤。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的主要怪兽区是否存在可用的空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 向系统登记本次连锁操作包含特殊召唤，对象为这张卡，数量为1，供场上其他效果（如星尘龙等）进行发动检测。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- ①效果处理：若这张卡仍与效果相关联，则将其以表侧表示特殊召唤到自己场上。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认这张卡没有在效果处理前离场或失去关联后，将其以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) then Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP) end
end
-- ②效果的过滤器：送去墓地的卡必须是怪兽，且其控制者是自己，即怪兽被送去自己墓地。
function s.filter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsControler(tp)
end
-- ②效果的发动条件：本次送去墓地的怪兽组中存在至少1只满足条件的自己控制的怪兽。
function s.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil,tp)
end
-- ②效果发动前检查：自身存在（以等级不低于0作为恒真条件），且本连锁上尚未发动过②效果；随后注册一个连锁结束时重置的标志，实现同一连锁最多发动1次。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsLevelAbove(0) and c:GetFlagEffect(id)==0 end
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
-- ②效果处理：若这张卡仍与效果关联且为表侧表示，则让玩家选择等级上升或下降1星（等级为1时不可选下降），然后给这张卡附加对应数值的等级变更效果。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	local down=c:IsLevelAbove(2)
	-- 弹出选项让玩家选择等级上升或下降：上升始终可选，下降仅在等级不低于2时可选；选择结果作为等级变更的数值（+1或-1）。
	local op=aux.SelectFromOptions(tp,
		{true,aux.Stringid(id,2),1},  --"等级上升"
		{down,aux.Stringid(id,3),-1})  --"等级下降"
	-- 这张卡的等级上升或下降1星。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_LEVEL)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
	e1:SetValue(op)
	c:RegisterEffect(e1)
end
