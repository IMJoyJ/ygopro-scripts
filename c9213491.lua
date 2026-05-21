--静寂のサイコガール
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己1张手卡除外，除「静寂的念力少女」外的1只4星以下的念动力族怪兽从卡组特殊召唤。这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。
-- ②：以最多有自己场上的念动力族怪兽数量的场上的表侧表示怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升1星。
local s,id,o=GetID()
-- 注册卡片效果：①召唤·特殊召唤成功时，除外1张手卡并从卡组特殊召唤1只4星以下非同名念动力族怪兽；②场上表侧表示怪兽等级上升。
function s.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。选自己1张手卡除外，除「静寂的念力少女」外的1只4星以下的念动力族怪兽从卡组特殊召唤。这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：以最多有自己场上的念动力族怪兽数量的场上的表侧表示怪兽为对象才能发动。那些怪兽的等级直到回合结束时上升1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"等级上升"
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1,id+o)
	e3:SetTarget(s.lvtg)
	e3:SetOperation(s.lvop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中除「静寂的念力少女」以外的4星以下且可以特殊召唤的念动力族怪兽。
function s.spfilter(c,e,tp)
	return not c:IsCode(id) and c:IsRace(RACE_PSYCHO) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①号效果的发动准备与合法性检测（检查怪兽区域空位、手卡是否有可除外的卡、卡组是否有可特召的怪兽）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有可用于特殊召唤的怪兽区域空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己手卡是否存在可以因效果表侧表示除外的卡。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,nil,tp,POS_FACEUP,REASON_EFFECT)
		-- 检查自己卡组是否存在满足特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息：从手卡除外1张卡。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_HAND)
	-- 设置操作信息：从卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
-- ①号效果的处理：除外1张手卡，从卡组特殊召唤怪兽，并适用额外卡组特殊召唤限制。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己手卡中1张可以除外的卡。
	local hg=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,LOCATION_HAND,0,1,1,nil,tp,POS_FACEUP,REASON_EFFECT)
	-- 如果成功选择并表侧表示除外了该手卡。
	if hg:GetCount()>0 and Duel.Remove(hg,POS_FACEUP,REASON_EFFECT)>0
		-- 并且此时自己场上仍有可用的怪兽区域空位。
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 提示玩家选择要特殊召唤的怪兽。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从卡组选择1只满足条件的念动力族怪兽。
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽以表侧表示特殊召唤到自己场上。
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	-- 这个回合，自己不是念动力族怪兽不能从额外卡组特殊召唤。②：以最多有自己场上的念动力族怪兽数量的场上的表侧表示怪兽为对象才能发动。
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	-- 注册额外卡组特殊召唤限制的玩家效果。
	Duel.RegisterEffect(e1,tp)
end
-- 限制条件：不能特殊召唤非念动力族的额外卡组怪兽。
function s.splimit(e,c)
	return not c:IsRace(RACE_PSYCHO) and c:IsLocation(LOCATION_EXTRA)
end
-- 过滤条件：场上表侧表示且等级在1以上的怪兽。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(1)
end
-- ②号效果的发动准备与对象选择（计算自己场上念动力族怪兽数量，并选择对应数量的表侧表示怪兽作为对象）。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 计算自己场上表侧表示的念动力族怪兽数量。
	local mat=Duel.GetMatchingGroupCount(aux.AND(Card.IsFaceup,Card.IsRace),tp,LOCATION_MZONE,0,nil,RACE_PSYCHO)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在念动力族怪兽，且场上是否存在至少1只可以作为对象的表侧表示怪兽。
	if chk==0 then return mat>0 and Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	-- 向对方玩家提示发动的效果。
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 提示玩家选择效果的对象。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 选择最多等同于自己场上念动力族怪兽数量的场上的表侧表示怪兽作为效果对象。
	Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,mat,nil)
end
-- ②号效果的处理：使作为对象的怪兽等级直到回合结束时上升1星。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	-- 筛选出依然存在于场上且表侧表示的对象怪兽。
	local g=Duel.GetTargetsRelateToChain():Filter(aux.AND(Card.IsType,Card.IsFaceup),nil,TYPE_MONSTER)
	if g:GetCount()==0 then return end
	-- 遍历所有符合条件的对象怪兽。
	for tc in aux.Next(g) do
		-- 那些怪兽的等级直到回合结束时上升1星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
end
