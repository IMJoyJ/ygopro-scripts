--竜輝巧－ルタδ
-- 效果：
-- 这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。这个卡名的效果1回合只能使用1次。
-- ①：把这张卡以外的自己的手卡·场上1只「龙辉巧」怪兽或仪式怪兽解放才能发动（这个效果发动的回合，自己若非不能通常召唤的怪兽则不能特殊召唤）。这张卡从手卡·墓地守备表示特殊召唤。那之后，可以把手卡1只仪式怪兽或1张仪式魔法卡给对方观看让自己抽1张。
function c22420202.initial_effect(c)
	c:EnableReviveLimit()
	-- 对应效果原文：『这张卡不能通常召唤，用「龙辉巧」卡的效果才能特殊召唤。』
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(c22420202.splimit)
	c:RegisterEffect(e1)
	-- 调用龙辉巧系列通用特召效果注册函数，为这张卡赋予“解放自己以外的手卡·场上1只龙辉巧怪兽或仪式怪兽，自身从手卡·墓地守备表示特殊召唤”的起动效果，并指定特召成功后追加执行extraop操作。
	local e2=aux.AddDrytronSpSummonEffect(c,c22420202.extraop)
	e2:SetDescription(aux.Stringid(22420202,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_DRAW)
	e2:SetCountLimit(1,22420202)
end
-- 作为特殊召唤条件的判定函数：检查特殊召唤这张卡的效果的发动来源卡是否为「龙辉巧」字段卡片，以此实现“用「龙辉巧」卡的效果才能特殊召唤”的限制。
function c22420202.splimit(e,se,sp,st)
	return se:GetHandler():IsSetCard(0x154)
end
-- 过滤函数：筛选出己方手牌中满足“仪式怪兽或仪式魔法”且当前未公开状态的卡，用于后续展示给对手。
function c22420202.drfilter(c)
	return c:IsType(TYPE_RITUAL) and c:IsType(TYPE_MONSTER+TYPE_SPELL) and not c:IsPublic()
end
-- 特召成功后的追加效果：若手牌存在可展示的仪式怪兽/仪式魔法且自己可以抽卡，则询问玩家是否让对方确认1张手牌并抽1张；确认后先中断效果处理，再展示、洗切手牌并抽卡。
function c22420202.extraop(e,tp)
	-- 获取己方手牌中所有满足drfilter过滤条件（仪式怪兽或仪式魔法且未公开）的卡。
	local g=Duel.GetMatchingGroup(c22420202.drfilter,tp,LOCATION_HAND,0,nil)
	-- 判断存在符合条件的可展示手牌，并且己方当前能够通过效果抽1张卡。
	if g:GetCount()>0 and Duel.IsPlayerCanDraw(tp,1)
		-- 弹出让玩家选择“是否抽卡？”的确认框，只有玩家同意时才执行展示手牌并抽卡。
		and Duel.SelectYesNo(tp,aux.Stringid(22420202,1)) then  --"是否抽卡？"
		-- 中断当前效果处理，使后续的展示、抽卡动作与之前特殊召唤的处理分离，以便正确触发相关的时点。
		Duel.BreakEffect()
		-- 发送选择提示消息，提示内容为“请选择给对方确认的卡”，用于接下来选择手牌。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)  --"请选择给对方确认的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 将玩家选中的那张手牌展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,sg)
		-- 由于手牌被展示过，洗切己方手牌以隐藏手牌的具体顺序信息。
		Duel.ShuffleHand(tp)
		-- 己方从卡组抽1张卡，抽卡原因标记为效果（REASON_EFFECT）。
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end
