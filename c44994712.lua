--捕食植物ロンギネフィラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「捕食植物 长叶挖耳草络新妇」以外的1张「捕食」卡加入手卡。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●给场上1只表侧表示怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ●自己的墓地·除外状态的1张「融合」在自己场上盖放。
local s,id,o=GetID()
-- 定义initial_effect函数，用于注册卡片效果。
function s.initial_effect(c)
	-- 将该卡加入捕食植物代码列表。
	aux.AddCodeList(c,24094653)
	-- 创建检索「捕食」卡的触发效果。①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「捕食植物 长叶挖耳草络新妇」以外的1张「捕食」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- 创建墓地除外后选择效果的起动效果。②：可以把墓地的这张卡除外，从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动"
	e3:SetCategory(CATEGORY_COUNTER+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置cost为将该卡从场上移除。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x1041]=true,
}
-- 定义thfilter函数，用于过滤可加入手牌的「捕食」卡。
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xf3) and c:IsAbleToHand()
end
-- 定义thtg函数，作为检索效果的目标选择条件。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否有满足条件的卡片存在于卡组中。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息为将一张卡从卡组加入手牌。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 定义thop函数，执行检索效果的操作。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组中选择满足条件的卡片。
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡片加入玩家的手牌。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认加入手牌的卡片。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 定义cfilter函数，用于过滤可以放置指示物的怪兽。
function s.cfilter(c)
	return c:IsControlerCanBeChanged() and c:GetCounter(0x1072)>0
end
-- 定义setfilter函数，用于过滤可以盖放的「融合」魔法卡。
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsCode(24094653) and c:IsSSetable()
end
-- 定义efftg函数，作为选择效果的目标选择条件。
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查场上是否存在可以添加指示物的怪兽。
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1)
	-- 检查墓地或除外区是否存在满足条件的「融合」魔法卡。
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 使用aux.SelectFromOptions让玩家选择放置指示物或者盖放「融合」魔法卡。
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置指示物"
			{b2,aux.Stringid(id,3),2})  --"盖放「融合」"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 获取可以添加指示物的怪兽组。
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
		-- 设置操作信息为在场上怪兽上放置指示物。
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 定义effop函数，执行选择效果的操作。
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if e:GetLabel()==1 then
		-- 提示玩家选择要放置指示物的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让玩家从场上选择可以添加指示物的怪兽。
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1041,1)
		local tc=g:GetFirst()
		if tc then
			-- 高亮选中的怪兽。
			Duel.HintSelection(g)
			if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
				-- 给选中的怪兽放置1个捕食指示物，并将其等级变为1星。有捕食指示物放置的2星以上的怪兽的等级变成1星。
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetCode(EFFECT_CHANGE_LEVEL)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				e1:SetCondition(s.lvcon)
				e1:SetValue(1)
				tc:RegisterEffect(e1)
			end
		end
	else
		-- 提示玩家选择要盖放的卡。
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从墓地或除外区选择满足条件的「融合」魔法卡。
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 高亮选中的卡片。
			Duel.HintSelection(g)
			-- 将选中的卡片在自己场上盖放。自己的墓地·除外状态的1张「融合」在自己场上盖放。
			Duel.SSet(tp,g)
		end
	end
end
-- 定义lvcon函数，作为等级变化效果的条件判断。
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
