--化合獣オキシン・オックス
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●自己主要阶段才能发动。从手卡把1只二重怪兽特殊召唤，自己场上的全部二重怪兽的等级直到回合结束时变成和这个效果特殊召唤的怪兽的原本等级相同。「化合兽 氧素牛」的这个效果1回合只能使用1次。
function c18993198.initial_effect(c)
	-- 可以使用通常召唤机会把场上的当作通常怪兽的这张卡作为表侧表示再1次召唤。那场合这张卡变成当作效果怪兽使用并得到以下效果。
	aux.EnableDualAttribute(c)
	-- ●自己主要阶段才能发动。手卡1只二重怪兽特殊召唤，自己场上的全部二重怪兽的等级直到回合结束时变成和那个特殊召唤的怪兽的原本等级相同。「化合兽 氧素牛」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18993198,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,18993198)
	e1:SetRange(LOCATION_MZONE)
	-- 可从手卡特殊召唤的二重怪兽的过滤条件
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c18993198.sptg)
	e1:SetOperation(c18993198.spop)
	c:RegisterEffect(e1)
end
-- 手卡特殊召唤及等级变更效果的发动准备
function c18993198.filter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 检查自己场上是否有空怪兽区域且手卡中是否有可特殊召唤的二重怪兽
function c18993198.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 设置操作信息为从手卡特殊召唤1只怪兽
function c18993198.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 可更改等级的自己场上表侧表示二重怪兽的过滤条件
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 手卡特殊召唤及等级变更效果的执行
		and Duel.IsExistingMatchingCard(c18993198.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 若自己场上已无空怪兽区域，则效果不处理
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 向玩家发送提示，请选择要特殊召唤的卡
function c18993198.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 选择手卡中1只二重怪兽为特殊召唤目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 将选中的二重怪兽特殊召唤到自己场上
	local g=Duel.SelectMatchingCard(tp,c18993198.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若特殊召唤成功，则获取那只怪兽的原本等级，并遍历自己场上所有二重怪兽
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0 then
		local lv=g:GetFirst():GetOriginalLevel()
		-- 自己场上的全部二重怪兽的等级直到回合结束时变成和那个特殊召唤的怪兽的原本等级相同。
		local tg=Duel.GetMatchingGroup(c18993198.lvfilter,tp,LOCATION_MZONE,0,nil)
		local tc=tg:GetFirst()
		while tc do
			if not tc:IsLevel(lv) then
				-- 注册等级更改的单体持续限制效果
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(lv)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				tc:RegisterEffect(e1)
			end
			tc=tg:GetNext()
		end
	end
end
