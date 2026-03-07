--竜輝巧－ラスβ
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把1只这张卡以外的「龙辉巧」怪兽或者仪式怪兽解放才能发动。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以选除外的1只自己的「龙辉巧」怪兽回到墓地。这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。
function c33543890.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文内容：这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c33543890.splimit)
	c:RegisterEffect(e1)
	-- 效果作用：为该卡添加一个特殊召唤效果，使其能通过解放「龙辉巧」怪兽或仪式怪兽从手卡或墓地守备表示特殊召唤。
	local e2=aux.AddDrytronSpSummonEffect(c,c33543890.extraop)
	e2:SetDescription(aux.Stringid(33543890,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetCountLimit(1,33543890)
end
-- 效果作用：限制该卡只能通过「龙辉巧」系列的卡的效果进行特殊召唤。
function c33543890.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 效果作用：定义了用于筛选除外区中「龙辉巧」怪兽的过滤函数。
function c33543890.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER)
end
-- 效果作用：定义了特殊召唤成功后可选的追加效果，即是否将除外区的「龙辉巧」怪兽送回墓地。
function c33543890.extraop(e,tp)
	-- 效果作用：获取玩家除外区中所有满足条件的「龙辉巧」怪兽组成一个卡组。
	local g=Duel.GetMatchingGroup(c33543890.tgfilter,tp,LOCATION_REMOVED,0,nil)
	-- 效果作用：判断是否有符合条件的除外怪兽，并询问玩家是否选择将其中一只送回墓地。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(33543890,1)) then  --"是否选除外的怪兽回到墓地？"
		-- 效果作用：中断当前效果处理流程，防止后续效果与当前效果同时处理。
		Duel.BreakEffect()
		-- 效果作用：向玩家发送提示信息，提示其选择要送去墓地的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 效果作用：将选定的卡以效果和回到墓地的原因送入墓地。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
