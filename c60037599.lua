--竜輝巧－エルγ
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的自己的手卡·场上1只「龙辉巧」怪兽或仪式怪兽解放才能发动（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤）。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以从自己墓地把「龙辉巧-天棓四γ」以外的1只攻击力2000的「龙辉巧」怪兽特殊召唤。
function c60037599.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c60037599.splimit)
	c:RegisterEffect(e1)
	-- 注册龙辉巧怪兽通用的特殊召唤效果，并指定特殊召唤成功后的追加效果处理函数为extraop
	local e2=aux.AddDrytronSpSummonEffect(c,c60037599.extraop)
	e2:SetDescription(aux.Stringid(60037599,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetCountLimit(1,60037599)
end
-- 限制该卡只能通过「龙辉巧」卡片的效果进行特殊召唤
function c60037599.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 定义从墓地特殊召唤怪兽的过滤条件函数
function c60037599.rbfilter(c,e,tp)
	-- 过滤出自己墓地中除「龙辉巧-天棓四γ」以外、攻击力为2000且可以特殊召唤的「龙辉巧」怪兽
	return c:IsSetCard(0x154) and c:IsAttack(2000) and not c:IsCode(60037599) and c:IsCanBeSpecialSummoned(e,0,tp,false,aux.DrytronSpSummonType(c))
end
-- 定义特殊召唤自身成功后的追加效果：可以从自己墓地把「龙辉巧-天棓四γ」以外的1只攻击力2000的「龙辉巧」怪兽特殊召唤
function c60037599.extraop(e,tp)
	-- 获取自己墓地中不受「王家之谷」影响且满足特殊召唤条件的「龙辉巧」怪兽组
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(c60037599.rbfilter),tp,LOCATION_GRAVE,0,nil,e,tp)
	-- 检查墓地中是否存在满足条件的怪兽，且己方场上是否有空余的怪兽区域
	if g:GetCount()>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 询问玩家是否选择发动追加效果，从墓地特殊召唤1只怪兽
		and Duel.SelectYesNo(tp,aux.Stringid(60037599,1)) then  --"是否从墓地把怪兽特殊召唤？"
		-- 中断当前效果处理，使后续的特殊召唤处理与前面的特殊召唤不视为同时进行（满足“那之后”的时点关系）
		Duel.BreakEffect()
		-- 提示玩家选择要特殊召唤的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		local sc=sg:GetFirst()
		-- 将选中的怪兽特殊召唤，若成功召唤且该怪兽为主卡组特殊召唤怪兽（无苏生限制），则完成其正规出场程序
		if Duel.SpecialSummon(sg,0,tp,tp,false,aux.DrytronSpSummonType(sc),POS_FACEUP)~=0 and aux.DrytronSpSummonType(sc) then
			sc:CompleteProcedure()
		end
	end
end
