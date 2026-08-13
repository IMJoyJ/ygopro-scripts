--水精鱗の深影隊
-- 效果：
-- 这个卡名在规则上也当作「海皇」卡使用。这个卡名的①②的效果1回合各能使用1次。
-- ①：把1张手卡丢弃去墓地才能发动。自己场上的全部水属性怪兽的等级直到回合结束时变成7星。
-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。除「水精鳞的深影队」外的4星以下的1只「海皇」怪兽或「水精鳞」怪兽从卡组特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 注册①的起动效果（丢弃手卡变星）和②的诱发效果（送墓后特召并附加额外限制）到这张卡上。
function s.initial_effect(c)
	-- ①：把1张手卡丢弃去墓地才能发动。自己场上的全部水属性怪兽的等级直到回合结束时变成7星。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"等级变更"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.lvcost)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ②：这张卡为让水属性怪兽的效果发动而被送去墓地的场合发动。除「水精鳞的深影队」外的4星以下的1只「海皇」怪兽或「水精鳞」怪兽从卡组特殊召唤。这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 筛选作为代价丢弃去墓地的手卡：需要能被丢弃且能作为代价送去墓地。
function s.lvcfilter(c)
	return c:IsAbleToGraveAsCost() and c:IsDiscardable()
end
-- 支付代价：检查能否丢弃1张手卡，若能则从手卡选择1张丢弃去墓地作为发动代价。
function s.lvcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动时确认：是否存在至少1张可作为代价丢弃的手卡，不存在则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvcfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	-- 从手卡丢弃1张满足筛选条件的手卡，丢弃原因记为代价+丢弃。
	Duel.DiscardHand(tp,s.lvcfilter,1,1,REASON_COST+REASON_DISCARD)
end
-- 筛选自己场上需要变星的水属性怪兽：表侧表示、等级1以上且当前等级不是7星。
function s.lvfilter(c)
	return c:IsAttribute(ATTRIBUTE_WATER) and c:IsFaceup() and c:IsLevelAbove(1) and not c:IsLevel(7)
end
-- 发动时确认：自己场上是否存在至少1只符合条件的表侧表示水属性怪兽，否则无法发动。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 如果不存在符合条件的怪兽则不能发动；存在则允许发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
end
-- 处理变星效果：获取自己场上全部符合条件的怪兽，将它们的等级变为7，直到回合结束时生效。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取自己场上所有需要变星的水属性怪兽（表侧、等级1以上且不是7星）。
	local g=Duel.GetMatchingGroup(s.lvfilter,tp,LOCATION_MZONE,0,nil)
	-- 遍历获取到的每一只怪兽，逐个施加等级变为7的效果。
	for tc in aux.Next(g) do
		-- 自己场上的全部水属性怪兽的等级直到回合结束时变成7星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(7)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
-- ②的发动条件：这张卡因水属性怪兽的效果发动而被作为代价送去墓地，且该效果是发动的怪兽效果。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsReason(REASON_COST) and re:IsActivated() and re:IsActiveType(TYPE_MONSTER)
		and re:GetHandler():IsAttribute(ATTRIBUTE_WATER)
end
-- 筛选卡组中可特殊召唤的怪兽：卡名含「水精鳞」或「海皇」、4星以下、不是「水精鳞的深影队」本身且满足特殊召唤条件。
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x74,0x77) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelBelow(4) and not c:IsCode(id)
end
-- ②发动时无条件允许，并设置本次效果含有从卡组进行1只特殊召唤的操作信息。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 登记本次效果操作：从卡组特殊召唤1只怪兽，用于其他卡片的连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- 处理②效果：若场上有空位则从卡组特殊召唤1只符合条件的怪兽，随后给发动玩家附加“非水属性怪兽不能从额外卡组特殊召唤”的限制直到回合结束。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 确认自己场上存在可用的主要怪兽区空格，否则不能进行特殊召唤。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向玩家弹出“请选择要特殊召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1张符合条件且能特殊召唤的怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选中的怪兽正面表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是水属性怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 将上述限制效果注册给发动玩家，使其在本回合持续生效。
	Duel.RegisterEffect(e1,tp)
end
-- 判断怪兽是否受限制：若该怪兽不是水属性且位于额外卡组，则不能进行特殊召唤。
function s.splimit(e,c)
	return not c:IsAttribute(ATTRIBUTE_WATER) and c:IsLocation(LOCATION_EXTRA)
end
