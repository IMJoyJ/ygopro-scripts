--化合獣オキシン・オックス
-- 效果：
-- ①：这张卡只要在场上·墓地存在，当作通常怪兽使用。
-- ②：可以把场上的当作通常怪兽使用的这张卡作为通常召唤作再1次召唤。那个场合这张卡变成当作效果怪兽使用并得到以下效果。
-- ●自己主要阶段才能发动。从手卡把1只二重怪兽特殊召唤，自己场上的全部二重怪兽的等级直到回合结束时变成和这个效果特殊召唤的怪兽的原本等级相同。「化合兽 氧素牛」的这个效果1回合只能使用1次。
function c18993198.initial_effect(c)
	-- 为卡片添加二重怪兽属性
	aux.EnableDualAttribute(c)
	-- ●自己主要阶段才能发动。从手卡把1只二重怪兽特殊召唤，自己场上的全部二重怪兽的等级直到回合结束时变成和这个效果特殊召唤的怪兽的原本等级相同。「化合兽 氧素牛」的这个效果1回合只能使用1次。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18993198,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1,18993198)
	e1:SetRange(LOCATION_MZONE)
	-- 效果发动条件：该怪兽必须处于再度召唤状态
	e1:SetCondition(aux.IsDualState)
	e1:SetTarget(c18993198.sptg)
	e1:SetOperation(c18993198.spop)
	c:RegisterEffect(e1)
end
-- 过滤函数：检查手牌中是否存在可特殊召唤的二重怪兽
function c18993198.filter(c,e,tp)
	return c:IsType(TYPE_DUAL) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 过滤函数：检查场上正面表示的二重怪兽
function c18993198.lvfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_DUAL)
end
-- 效果发动时点的检查函数：判断是否满足特殊召唤条件
function c18993198.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 判断玩家场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断手牌中是否存在满足条件的二重怪兽
		and Duel.IsExistingMatchingCard(c18993198.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置效果处理时的操作信息，提示将要特殊召唤1只怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 效果处理函数：选择并特殊召唤1只二重怪兽，然后将场上所有二重怪兽等级调整为该怪兽的原本等级
function c18993198.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌中选择1只满足条件的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c18993198.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	-- 若成功特殊召唤，则继续处理等级调整效果
	if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP) then
		local lv=g:GetFirst():GetOriginalLevel()
		-- 获取场上所有正面表示的二重怪兽
		local tg=Duel.GetMatchingGroup(c18993198.lvfilter,tp,LOCATION_MZONE,0,nil)
		local tc=tg:GetFirst()
		while tc do
			if not tc:IsLevel(lv) then
				-- 为场上二重怪兽设置等级变更效果，使其等级变为特殊召唤怪兽的原本等级
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
