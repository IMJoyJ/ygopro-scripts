--竜輝巧－バンα
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的自己的手卡·场上1只「龙辉巧」怪兽或仪式怪兽解放才能发动（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤）。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以从卡组把1只仪式怪兽加入手卡。
function c97148796.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c97148796.splimit)
	c:RegisterEffect(e1)
	-- 注册“龙辉巧”怪兽通用的特殊召唤效果，并指定特殊召唤成功后的追加效果函数为extraop
	local e2=aux.AddDrytronSpSummonEffect(c,c97148796.extraop)
	e2:SetDescription(aux.Stringid(97148796,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_SEARCH)
	e2:SetCountLimit(1,97148796)
end
-- 限制该怪兽只能通过「龙辉巧」卡的效果才能特殊召唤
function c97148796.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 过滤卡组中可以加入手卡的仪式怪兽
function c97148796.thfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义特殊召唤成功后的追加效果：可以从卡组把1只仪式怪兽加入手卡
function c97148796.extraop(e,tp)
	-- 获取卡组中所有满足条件的仪式怪兽
	local g=Duel.GetMatchingGroup(c97148796.thfilter,tp,LOCATION_DECK,0,nil)
	-- 若卡组中存在仪式怪兽，则询问玩家是否将其加入手卡
	if g:GetCount()>0 and Duel.SelectYesNo(tp,aux.Stringid(97148796,1)) then  --"是否从卡组把仪式怪兽加入手卡？"
		-- 中断当前效果，使后续的检索处理与特殊召唤不视为同时进行
		Duel.BreakEffect()
		-- 提示玩家选择要加入手卡的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将选中的仪式怪兽加入玩家手卡
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手卡的仪式怪兽
		Duel.ConfirmCards(1-tp,sg)
	end
end
