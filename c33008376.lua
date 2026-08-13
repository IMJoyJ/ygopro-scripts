--マテリアクトル・ギガドラ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：只要这张卡在怪兽区域存在，自己不是超量怪兽不能从额外卡组特殊召唤。
-- ②：丢弃1张手卡才能发动。从手卡·卡组把1只3星通常怪兽特殊召唤。把通常怪兽丢弃发动的场合，可以把特殊召唤的怪兽改成1只「原质炉」怪兽。
function c33008376.initial_effect(c)
	-- 这个卡名的②的效果1回合只能使用1次。②：丢弃1张手卡才能发动。从手卡·卡组把1只3星通常怪兽特殊召唤。把通常怪兽丢弃发动的场合，可以把特殊召唤的怪兽改成1只「原质炉」怪兽。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(33008376,0))  --"自己不是超量怪兽不能从额外卡组特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,33008376)
	e1:SetCost(c33008376.spcost)
	e1:SetTarget(c33008376.sptg)
	e1:SetOperation(c33008376.spop)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在怪兽区域存在，自己不是超量怪兽不能从额外卡组特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c33008376.splimit)
	c:RegisterEffect(e2)
end
-- 定义代价筛选函数costfilter：用于选择1张可作为代价丢弃的手牌，并在丢弃后仍存在可特殊召唤的符合条件的怪兽（通过spfilter确认），以保证发动时条件成立。
function c33008376.costfilter(c,e,tp)
	-- 返回条件：手牌可以丢弃（c:IsDiscardable()），并且手卡·卡组中存在可通过spfilter筛选出的可特殊召唤怪兽；同时把当前手牌是否为通常怪兽作为normal参数传递给spfilter，用于后续决定检索范围。
	return c:IsDiscardable() and Duel.IsExistingMatchingCard(c33008376.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp,c:IsType(TYPE_NORMAL))
end
-- 定义特殊召唤对象筛选函数spfilter：若normal为真（丢弃的是通常怪兽），则可选择卡名包含「原质炉」的怪兽；否则只能选择3星通常怪兽；且目标必须能被该效果特殊召唤。
function c33008376.spfilter(c,e,tp,normal)
	return (normal and c:IsSetCard(0x160) or c:IsLevel(3) and c:IsType(TYPE_NORMAL)) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 代价处理函数spcost：将效果标签置为(100,0)；检查存在可丢弃手牌；选择1张手牌丢弃，并根据丢弃的卡是否为通常怪兽将标签设为(100,1)或(100,0)；最后将这张手牌送去墓地（REASON_COST+REASON_DISCARD）。
function c33008376.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	e:SetLabel(100,0)
	-- 发动合法性检查：当chk==0时，确认手牌中存在满足costfilter的卡（即可丢弃且丢弃后仍有可特殊召唤目标），否则不能发动。
	if chk==0 then return Duel.IsExistingMatchingCard(c33008376.costfilter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 向玩家显示提示消息，要求选择1张要丢弃的手牌（HINTMSG_DISCARD）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 玩家从手牌中选择1张符合costfilter的卡作为发动代价。
	local sg=Duel.SelectMatchingCard(tp,c33008376.costfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if sg:GetFirst():IsType(TYPE_NORMAL) then
		e:SetLabel(100,1)
	else
		e:SetLabel(100,0)
	end
	-- 将选中的手牌送去墓地，原因是作为代价丢弃（REASON_COST+REASON_DISCARD）。
	Duel.SendtoGrave(sg,REASON_COST+REASON_DISCARD)
end
-- 目标选择函数sptg：读取代价阶段记录的标签；在chk==0时临时清除标签并判定是否满足发动条件（cost成功且主要怪兽区有空位）；实际发动时恢复标签并设置操作信息，声明将从手卡·卡组特殊召唤1只怪兽。
function c33008376.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local check,label=e:GetLabel()
	if chk==0 then
		e:SetLabel(0,0)
		-- 返回chk==0时的合法性结果：代价记录中的check必须为100（已经支付代价）且我方主要怪兽区有空位，否则不能发动。
		return check==100 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	end
	e:SetLabel(0,label)
	-- 设置本连锁的操作信息：效果类别为特殊召唤（CATEGORY_SPECIAL_SUMMON），处理时从手卡·卡组特殊召唤1只怪兽，供其他效果（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- 效果处理函数spop：首先确认主要怪兽区仍有空位；读取代价阶段记录的标签得到normal标志；显示特殊召唤选择提示；从手卡·卡组选择1只符合条件的怪兽（spfilter根据normal决定范围）；若选择成功则以表侧攻击表示特殊召唤到场上。
function c33008376.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 若我方主要怪兽区没有空位，则不进行特殊召唤处理，效果处理结束。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local check,label=e:GetLabel()
	local normal=label==1
	-- 向玩家显示提示消息，要求选择1只要特殊召唤的怪兽（HINTMSG_SPSUMMON）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 玩家从手卡·卡组中选择1只符合spfilter的怪兽，spfilter的normal参数决定是否允许选择「原质炉」怪兽。
	local g=Duel.SelectMatchingCard(tp,c33008376.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp,normal)
	if g:GetCount()>0 then
		-- 将选中的怪兽特殊召唤到我方场上，表示形式为表侧攻击表示（POS_FACEUP）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
-- 效果①的限制判定函数：如果被特殊召唤的卡从额外卡组来（c:IsLocation(LOCATION_EXTRA)）且不是超量怪兽（not c:IsType(TYPE_XYZ)），则禁止该特殊召唤。
function c33008376.splimit(e,c,sump,sumtype,sumpos,targetp)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsType(TYPE_XYZ)
end
