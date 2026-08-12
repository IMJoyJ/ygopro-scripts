--捕食植物ロンギネフィラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「捕食植物 长叶挖耳草络新妇」以外的1张「捕食」卡加入手卡。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●给场上1只表侧表示怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ●自己的墓地·除外状态的1张「融合」在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果：注册这张卡上记载卡名「融合」，注册召唤成功时和特殊召唤成功时触发的卡组检索效果（①），以及墓地的起动效果（②）
function s.initial_effect(c)
	-- 记录这张卡上记载着卡名「融合」（卡号24094653）
	aux.AddCodeList(c,24094653)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「捕食植物 长叶挖耳草络新妇」以外的1张「捕食」卡加入手卡。
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
	-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动"
	e3:SetCategory(CATEGORY_COUNTER+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置发动代价：把墓地的这张卡除外
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
s.mentioned_counter={
	[0x1041]=true,
}
-- 检索过滤条件：不是「捕食植物 长叶挖耳草络新妇」且是「捕食」卡并且可以加入手卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xf3) and c:IsAbleToHand()
end
-- 检索效果的目标函数：确认卡组存在可检索的卡，并设置回手牌的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动条件检测：自己的卡组存在至少1张满足检索条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：预计从卡组把1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：让玩家从卡组选1张满足条件的卡加入手卡，并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 向玩家提示「请选择要加入手牌的卡」
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从卡组选择1张满足检索条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 把选择的卡以效果原因加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 把加入手卡的卡给对方玩家确认
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 过滤条件：控制权可以变更且放置有捕食指示物（0x1072）的怪兽（本脚本未使用）
function s.cfilter(c)
	return c:IsControlerCanBeChanged() and c:GetCounter(0x1072)>0
end
-- 盖放过滤条件：表侧表示或除外状态、卡名为「融合」且可以在场上盖放的卡
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsCode(24094653) and c:IsSSetable()
end
-- 墓地效果的目标函数：判断两个可选效果是否可发动，让玩家选择其中1个，并根据选择设置对应的效果分类和操作信息
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检测场上是否存在至少1只可以放置1个捕食指示物的怪兽（选项一是否可发动）
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1)
	-- 检测自己的墓地·除外状态是否存在至少1张可以盖放的「融合」（选项二是否可发动）
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家从可发动的选项（放置指示物／盖放「融合」）中选择1个发动
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置指示物"
			{b2,aux.Stringid(id,3),2})  --"盖放「融合」"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 取得双方场上所有可以放置捕食指示物的怪兽
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
		-- 设置操作信息：预计给其中1只怪兽放置1个捕食指示物
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 墓地效果的处理：若选择放置指示物，则选场上1只怪兽放置1个捕食指示物并使其等级变成1星；若选择盖放，则选墓地·除外状态的1张「融合」在自己场上盖放
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if e:GetLabel()==1 then
		-- 向玩家提示「请选择要放置指示物的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 让玩家选择场上1只可以放置1个捕食指示物的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1041,1)
		local tc=g:GetFirst()
		if tc then
			-- 为选择的怪兽显示被选为对象的动画并记录
			Duel.HintSelection(g)
			if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
				-- 有捕食指示物放置的2星以上的怪兽的等级变成1星。
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
		-- 向玩家提示「请选择要盖放的卡」
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 让玩家从自己的墓地·除外状态选择1张可以盖放的「融合」（附加不受王家长眠之谷影响的过滤）
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 为选择的卡显示被选为对象的动画并记录
			Duel.HintSelection(g)
			-- 把选择的「融合」在自己场上盖放
			Duel.SSet(tp,g)
		end
	end
end
-- 等级变化效果的适用条件：该怪兽放置有捕食指示物
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
