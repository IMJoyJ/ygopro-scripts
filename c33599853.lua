--光と闇の儀式
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己的手卡·场上的怪兽解放或者作为解放的代替而把自己墓地的怪兽除外，从手卡把「黑色混沌之魔术师 黑混沌」或「光与暗之战士 混沌战士」仪式召唤。
-- ②：这张卡在墓地存在的场合才能发动。把有「光与暗的仪式」的卡名记述的1张卡和这张卡从自己墓地加入手卡。
local s,id,o=GetID()
-- 注册卡片效果：注册记载的卡片密码列表、①效果的仪式召唤程序，以及②效果（墓地起动回收手牌）。
function s.initial_effect(c)
	-- 登记此卡效果文本中记载了「光与暗的仪式」、「黑色混沌之魔术师 黑混沌」和「光与暗之战士 混沌战士」的卡名。
	aux.AddCodeList(c,33599853,44001993,70405001)
	-- 注册仪式召唤程序：等级合计达到仪式怪兽等级以上，解放手卡·场上怪兽或作为代替将墓地怪兽除外，从手卡仪式召唤指定怪兽。
	local e1=aux.AddRitualProcGreater2(c,s.rfilter,nil,s.grfilter)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	-- ②：这张卡在墓地存在的场合才能发动。把有「光与暗的仪式」的卡名记述的1张卡和这张卡从自己墓地加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"回收效果"
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
-- 过滤条件：被仪式召唤的怪兽必须是「黑色混沌之魔术师 黑混沌」或「光与暗之战士 混沌战士」。
function s.rfilter(c)
	return c:IsCode(44001993,70405001)
end
-- 过滤条件：可以代替解放而从墓地除外的怪兽。
function s.grfilter(c)
	return c:IsAbleToRemove() and c:IsType(TYPE_MONSTER)
end
-- 过滤条件：墓地中记述有「光与暗的仪式」卡名且可以加入手牌的卡片。
function s.thfilter(c)
	-- 判断卡片效果文本中是否记述有「光与暗的仪式」卡名，且能加入手牌。
	return aux.IsCodeListed(c,33599853) and c:IsAbleToHand()
end
-- ②效果的发动目标：检查墓地中的此卡和另一张符合条件的卡是否能加入手牌，并设置加入手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己墓地是否存在除这张卡以外符合条件的可以加入手牌的卡片。
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,c) end
	-- 设置操作信息：效果处理时将墓地的2张卡加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE)
end
-- ②效果处理：将墓地中的这张卡以及选中的1张符合条件的卡加入手牌，并向对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查这张卡是否仍与连锁有关，且不受墓地王家长眠之谷的效果影响。
	if c:IsRelateToChain() and aux.NecroValleyFilter()(c) then
		-- 提示玩家选择要加入手牌的卡片。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家在墓地选择1张除这张卡以外、有「光与暗的仪式」卡名记述的卡（受王家长眠之谷效果过滤）。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,c)
		if g:GetCount()>0 then
			-- 为选中的被回收卡片显示选中状态的动画。
			Duel.HintSelection(g)
			g:AddCard(c)
			-- 将选中的卡片以及这张卡一同送回玩家手牌。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认所加入的手牌卡片。
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
