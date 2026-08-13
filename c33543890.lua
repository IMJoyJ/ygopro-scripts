--竜輝巧－ラスβ
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：从自己的手卡·场上把1只这张卡以外的「龙辉巧」怪兽或者仪式怪兽解放才能发动。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以选除外的1只自己的「龙辉巧」怪兽回到墓地。这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤。
function c33543890.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c33543890.splimit)
	c:RegisterEffect(e1)
	-- 为这张卡注册“龙辉巧”系列通用特殊召唤效果：解放手牌·场上的其他“龙辉巧”怪兽或仪式怪兽，从手卡·墓地守备表示特殊召唤，并指定特召成功后执行extraop追加操作；同时附加本回合限制特殊召唤非不能通常召唤怪兽的通用规则。
	local e2=aux.AddDrytronSpSummonEffect(c,c33543890.extraop)
	e2:SetDescription(aux.Stringid(33543890,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e2:SetCountLimit(1,33543890)
end
-- 特殊召唤条件判定函数：只允许当特殊召唤的发动方卡（se的handler）为“龙辉巧”卡时，此卡才能被特殊召唤，对应“用「龙辉巧」卡的效果才能特殊召唤”的限制。
function c33543890.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 筛选出除外区中表侧表示且属于“龙辉巧”字段的怪兽，作为可选回墓地的目标。
function c33543890.tgfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x154) and c:IsType(TYPE_MONSTER)
end
-- 特召成功后的追加操作：从除外的自己的“龙辉巧”怪兽中选出1只，询问是否送回墓地；若选择是，则将其送去墓地。
function c33543890.extraop(e,tp)
	-- 获取自己除外区中所有满足tgfilter条件的“龙辉巧”怪兽，组成可供选择的候选集合。
	local g=Duel.GetMatchingGroup(c33543890.tgfilter,tp,LOCATION_REMOVED,0,nil)
	-- 判断是否存在符合条件的除外“龙辉巧”怪兽，并让玩家决定是否执行送墓效果。
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(33543890,1)) then  --"是否选除外的怪兽回到墓地？"
		-- 中断当前效果处理，使后续“回到墓地”的操作与特殊召唤处理分离开，避免时点被占用或错过。
		Duel.BreakEffect()
		-- 向玩家显示“选择要送去墓地的卡”的提示消息，为接下来的选卡操作提供界面提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选择的“龙辉巧”怪兽从除外区送去墓地，原因记为效果与回到墓地，从而完成“选除外的龙辉巧怪兽回到墓地”的效果。
		Duel.SendtoGrave(sg,REASON_EFFECT+REASON_RETURN)
	end
end
