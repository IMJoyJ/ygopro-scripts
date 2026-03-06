--竜輝巧－ルタδ
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的自己的手卡·场上1只「龙辉巧」怪兽或仪式怪兽解放才能发动（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤）。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以把手卡1只仪式怪兽或1张仪式魔法卡给对方观看让自己抽1张。
function c22420202.initial_effect(c)
	c:EnableReviveLimit()
	-- 效果原文：这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c22420202.splimit)
	c:RegisterEffect(e1)
	-- 注册一个通用的龙辉巧系列特殊召唤效果，使其能通过解放手卡或场上的特定怪兽从手卡或墓地守备表示特殊召唤自身。
	local e2=aux.AddDrytronSpSummonEffect(c,c22420202.extraop)
	e2:SetDescription(aux.Stringid(22420202,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetCountLimit(1,22420202)
end
-- 效果原文：用「龙辉巧」卡的效果才能特殊召唤。
function c22420202.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 定义一个过滤器，用于筛选手牌中未公开的仪式怪兽或仪式魔法卡。
function c22420202.drfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER+TYPE_SPELL) and not c:IsPublic()
end
-- 特殊召唤成功后执行的追加效果：若满足条件则询问是否抽一张卡，若选择是则展示一张手牌并抽一张卡。
function c22420202.extraop(e,tp)
	-- 检索满足条件的仪式怪兽或仪式魔法卡组成卡片组。
	local g=Duel.GetMatchingGroup(c22420202.drfilter,tp,LOCATION_HAND,0,nil)
	-- 判断是否有满足条件的卡片且玩家可以抽卡。
	if g:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
		-- 询问玩家是否抽一张卡。
		and Duel.SelectYesNo(tp,aux.Stringid(22420202,1)) then  --"是否抽卡？"
		-- 中断当前效果，使之后的效果处理视为不同时处理。
		Duel.BreakEffect()
		-- 提示玩家选择一张要给对方确认的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 确认将选中的卡给对方观看。
		Duel.ConfirmCards(1-tp,sg)
		-- 将玩家手牌洗切。
		Duel.ShuffleHand(tp)
		-- 让玩家抽一张卡。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
