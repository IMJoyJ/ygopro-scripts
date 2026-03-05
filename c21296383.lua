--ユニバード
-- 效果：
-- 把自己场上表侧表示存在的1只怪兽和这张卡从游戏中除外，从自己墓地选择持有那个原本等级合计数值以下的等级的1只同调怪兽发动。选择的怪兽从墓地特殊召唤。
function c21296383.initial_effect(c)
	-- 效果原文内容：把自己场上表侧表示存在的1只怪兽和这张卡从游戏中除外，从自己墓地选择持有那个原本等级合计数值以下的等级的1只同调怪兽发动。选择的怪兽从墓地特殊召唤。
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
-- 检索满足条件的同调怪兽，这些怪兽可以被特殊召唤且能成为效果的对象
function c21296383.spfilter(c,e,tp)
	return c:IsType(TYPE_SYNCHRO) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsCanBeEffectTarget(e)
end
-- 检索满足条件的场上怪兽，这些怪兽正面表示且能作为除外的代价
function c21296383.cfilter(c,lv)
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and c:GetOriginalLevel()>=lv
end
-- 判断是否满足发动条件，检查是否有足够的等级来选择同调怪兽
function c21296383.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检索满足条件的墓地同调怪兽组
	local sg=Duel.GetMatchingGroup(c21296383.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if chkc then return sg:IsContains(chkc) and chkc:IsLevelBelow(e:GetLabel()) end
	if sg:GetCount()==0 then return false end
	local mg,mlv=sg:GetMinGroup(Card.GetLevel)
	local elv=e:GetHandler():GetOriginalLevel()
	local lv=(elv>=mlv) and 1 or (mlv-elv)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost()
		-- 检查场上是否存在满足条件的怪兽作为除外的代价
		and Duel.IsExistingMatchingCard(c21296383.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler(),lv) end
	-- 提示玩家选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 选择满足条件的场上怪兽作为除外的代价
	local g=Duel.SelectMatchingCard(tp,c21296383.cfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler(),lv)
	local slv=elv+g:GetFirst():GetLevel()
	g:AddCard(e:GetHandler())
	-- 将选择的怪兽和此卡从游戏中除外
	Duel.Remove(g,POS_FACEUP,REASON_COST)
	-- 提示玩家选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	e:SetLabel(slv)
	local g=sg:FilterSelect(tp,Card.IsLevelBelow,1,1,nil,slv)
	-- 设置当前连锁的目标为选择的同调怪兽
	Duel.SetTargetCard(g)
	-- 设置当前连锁的操作信息为特殊召唤
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
-- 效果作用：将目标同调怪兽从墓地特殊召唤
function c21296383.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽特殊召唤到场上
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
