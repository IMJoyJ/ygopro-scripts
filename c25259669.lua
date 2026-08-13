--ゴブリンドバーグ
-- 效果：
-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
function c25259669.initial_effect(c)
	-- ①：这张卡召唤时才能发动。从手卡把1只4星以下的怪兽特殊召唤。这张卡是攻击表示的场合，再让这张卡变成守备表示。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25259669,0))  --"特殊召唤"
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c25259669.sumtg)
	e1:SetOperation(c25259669.sumop)
	c:RegisterEffect(e1)
end
-- 定义特殊召唤的过滤函数：选择手牌中4星以下且能够被特殊召唤的怪兽。
function c25259669.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 特殊召唤效果的发动条件判定函数：需要自己主要怪兽区有空位，并且手牌存在符合过滤条件的怪兽。
function c25259669.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上主要怪兽区是否存在可用的空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手牌中是否存在至少1只满足4星以下且可被特殊召唤条件的怪兽。
		and Duel.IsExistingMatchingCard(c25259669.filter,tp,LOCATION_HAND,0,1,nil,e,tp) end
	-- 设置操作信息，声明本效果将进行从手牌特殊召唤1只怪兽的处理。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 特殊召唤效果的处理：若有空位则选择手牌中符合条件的怪兽特殊召唤，若特殊召唤成功且此卡仍在场并处于表侧攻击表示，则将其变更为守备表示。
function c25259669.sumop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 效果处理时再次确认自己场上存在可用的主要怪兽区空位。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		-- 向操作者发送选择提示，要求选择要特殊召唤的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手牌中选择1只满足4星以下且可被特殊召唤条件的怪兽。
		local g=Duel.SelectMatchingCard(tp,c25259669.filter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
		-- 若选中的卡数量大于0且特殊召唤成功，则继续后续判断。
		if g:GetCount()>0 and Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)>0
			and c:IsRelateToEffect(e) and c:IsPosition(POS_FACEUP_ATTACK) then
			-- 中断当前效果处理，使后续的表示形式变更视为另一次处理，避免错失时点。
			Duel.BreakEffect()
			-- 将哥布林德伯格从表侧攻击表示变为表侧守备表示。
			Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
		end
	end
end
