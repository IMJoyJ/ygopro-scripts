--ユニバード
-- 效果：
-- 把自己场上表侧表示存在的1只怪兽和这张卡从游戏中除外，从自己墓地选择持有那个原本等级合计数值以下的等级的1只同调怪兽发动。选择的怪兽从墓地特殊召唤。
function c21296383.initial_effect(c)
	-- 把自己场上表侧表示存在的1只怪兽和这张卡从游戏中除外，从自己墓地选择持有那个原本等级合计数值以下的等级的1只同调怪兽发动。选择的怪兽从墓地特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21296383,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(c21296383.target)
	e1:SetOperation(c21296383.operation)
	c:RegisterEffect(e1)
end
-- 筛选墓地中满足条件的同调怪兽：必须是同调怪兽、能够被当前效果特殊召唤、且能成为效果的对象（取对象）。
function c21296383.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 筛选可作为代价除外的场上怪兽：必须是表侧表示、可以作为代价除外、且其原本等级不低于参数lv（以保证与独角鸟合计等级能达到目标同调怪兽的最低等级）。
function c21296383.cfilter(c,lv)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and c:GetOriginalLevel()>=lv
end
-- target函数整体：发动时的条件判定与处理，首先获取墓地可特殊召唤的同调怪兽组，若无则不能发动；然后计算墓地同调怪兽的最低等级与独角鸟原本等级的差值，确定可除外怪兽所需的最低等级；再检查自身能否除外且场上存在符合条件的怪兽。满足条件后提示选择除外怪兽和选择要特殊召唤的目标，并设置相关连锁信息。
function c21296383.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 获取自己墓地中所有可作为效果对象且能被特殊召唤的同调怪兽，存入组sg。
	local sg=Duel.GetMatchingGroup(c21296383.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return sg:IsContains(chkc) and chkc:IsLevelBelow(e:GetLabel()) end
	if sg:GetCount()==0 then return false end
	local mg,mlv=sg:GetMinGroup(Card.GetLevel)
	local elv=e:GetHandler():GetOriginalLevel()
	local lv=(elv>=mlv) and 1 or (mlv-elv)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查自己场上是否存在1只满足cfilter（表侧表示、可作代价除外、原本等级不低于lv）的怪兽，作为发动代价的候选。
		and Duel.IsExistingMatchingCard(c21296383.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),lv) end
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 让玩家从自己场上选择1只满足cfilter条件的表侧表示怪兽，作为即将除外的代价怪兽。
	local g=Duel.SelectMatchingCard(tp,c21296383.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),lv)
	local slv=elv+g:GetFirst():GetLevel()
	g:AddCard(e:GetHandler())
	-- 将选择的代价怪兽和独角鸟自身以表侧表示除外（REASON_COST，作为发动代价）。
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 给玩家显示“请选择要特殊召唤的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	e:SetLabel(slv)
	local g=sg:FilterSelect(tp,Card.IsLevelBelow,1,1,nil,slv)
	-- 将选择的目标同调怪兽设为当前连锁的取对象对象，使效果与该卡建立关联。
	Duel.SetTargetCard(g)
	-- 设置操作信息，标明本连锁将进行1只怪兽的特殊召唤，目标为g，用于后续卡片的状态检测与响应。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- operation函数整体：效果处理时获取对象卡，若对象仍与效果关联（没有离场等导致重置），则将其特殊召唤。
function c21296383.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁第一个（也是唯一一个）对象卡。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标同调怪兽以表侧表示特殊召唤到自己的主要怪兽区。
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
