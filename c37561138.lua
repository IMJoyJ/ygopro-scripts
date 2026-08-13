--ネクロバレーの玉座
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：可以从以下效果选择1个发动。
-- ●从卡组把1只「守墓」怪兽加入手卡。
-- ●从手卡把1只「守墓」怪兽召唤。
function c37561138.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：可以从以下效果选择1个发动。●从卡组把1只「守墓」怪兽加入手卡。●从手卡把1只「守墓」怪兽召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,37561138+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c37561138.target)
	e1:SetOperation(c37561138.activate)
	c:RegisterEffect(e1)
end
-- 定义检索筛选条件：从卡组选出1只「守墓」怪兽且能被加入手卡的卡。
function c37561138.thfilter(c)
	return c:IsSetCard(0x2e) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 定义召唤筛选条件：从手牌选出1只「守墓」怪兽且能进行通常召唤的卡。
function c37561138.filter(c)
	return c:IsSetCard(0x2e) and c:IsSummonable(true,nil)
end
-- 进行效果发动时的合法判定：检查卡组是否存在可检索的「守墓」怪兽，或手牌是否存在可召唤的「守墓」怪兽；若满足则选择其中一个选项并设置对应的效果类别与操作信息。
function c37561138.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在至少1只满足检索条件的「守墓」怪兽，用于判定“从卡组把1只「守墓」怪兽加入手卡”选项是否可行。
	local b1=Duel.IsExistingMatchingCard(c37561138.thfilter,tp,LOCATION_DECK,0,1,nil)
	-- 检查手牌是否存在至少1只满足召唤条件的「守墓」怪兽，用于判定“从手卡把1只「守墓」怪兽召唤”选项是否可行。
	local b2=Duel.IsExistingMatchingCard(c37561138.filter,tp,LOCATION_HAND,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 and b2 then
		-- 当两个选项都可行时，通过选项对话框让玩家选择“从卡组把1只「守墓」怪兽加入手卡”或“从手卡把1只「守墓」怪兽召唤”。
		op=Duel.SelectOption(tp,aux.Stringid(37561138,0),aux.Stringid(37561138,1))  --"从卡组把1只「守墓」怪兽加入手卡/从手卡把1只「守墓」怪兽召唤"
	elseif b1 then
		-- 当只有检索选项可行时，直接将该分支标记为0（从卡组加入手卡）。
		op=Duel.SelectOption(tp,aux.Stringid(37561138,0))  --"从卡组把1只「守墓」怪兽加入手卡"
	else
		-- 当只有召唤选项可行时，选择选项1并加1修正为标签1（从手卡召唤）。
		op=Duel.SelectOption(tp,aux.Stringid(37561138,1))+1  --"从手卡把1只「守墓」怪兽召唤"
	end
	e:SetLabel(op)
	if op==0 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置当前连锁的操作信息为“从卡组将1张卡加入手卡”，供相关效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	else
		e:SetCategory(CATEGORY_SUMMON)
		-- 设置当前连锁的操作信息为“进行召唤”，供相关效果检测使用。
		Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,0,0)
	end
end
-- 效果处理时根据发动时选择的分支执行：分支0检索卡组「守墓」怪兽加入手牌并给对方确认；分支1从手牌选择「守墓」怪兽进行通常召唤（不占用通召次数）。
function c37561138.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==0 then
		-- 向玩家显示“请选择要加入手牌的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组选择1张满足thfilter条件的「守墓」怪兽卡。
		local g=Duel.SelectMatchingCard(tp,c37561138.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的「守墓」怪兽卡加入其持有者的手卡。
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 将检索加入手卡的卡展示给对方玩家确认。
			Duel.ConfirmCards(1-tp,g)
		end
	else
		-- 向玩家显示“请选择要召唤的卡”的选择提示。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
		-- 从手牌选择1张满足filter条件的「守墓」怪兽卡。
		local g=Duel.SelectMatchingCard(tp,c37561138.filter,tp,LOCATION_HAND,0,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 将选择的「守墓」怪兽无视通常召唤次数限制进行通常召唤。
			Duel.Summon(tp,tc,true,nil)
		end
	end
end
