--捕食植物ロンギネフィラ
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组把「捕食植物 长叶挖耳草络新妇」以外的1张「捕食」卡加入手卡。
-- ②：可以把墓地的这张卡除外，从以下效果选择1个发动。
-- ●给场上1只表侧表示怪兽放置1个捕食指示物。有捕食指示物放置的2星以上的怪兽的等级变成1星。
-- ●自己的墓地·除外状态的1张「融合」在自己场上盖放。
local s,id,o=GetID()
-- 初始化效果，注册三个效果：①通常召唤成功时的检索效果、②特殊召唤成功时的检索效果、③墓地发动效果
function s.initial_effect(c)
	-- 注册该卡的另一个卡名（24094653）用于效果识别
	aux.AddCodeList(c,24094653)
	-- 效果①：通常召唤成功时发动，检索满足条件的「捕食」卡加入手牌
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
	-- 效果②：墓地发动效果，可以选择放置指示物或盖放融合魔法
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))  --"发动"
	e3:SetCategory(CATEGORY_COUNTER+CATEGORY_SSET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,id+o)
	-- 设置发动效果②时需要将此卡除外作为费用
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.efftg)
	e3:SetOperation(s.effop)
	c:RegisterEffect(e3)
end
-- 检索过滤函数：排除自身，只选择「捕食」卡且能加入手牌
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0xf3) and c:IsAbleToHand()
end
-- 效果①的发动条件判断和操作信息设置：检查卡组是否存在满足条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组是否存在满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将要检索的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 效果①的处理函数：选择并检索卡牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择满足条件的卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 确认对方看到选中的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 指示物过滤函数：控制权可改变且拥有捕食指示物
function s.cfilter(c)
	return c:IsControlerCanBeChanged() and c:GetCounter(0x1072)>0
end
-- 盖放过滤函数：表侧表示、卡号为24094653且可盖放
function s.setfilter(c)
	return c:IsFaceupEx() and c:IsCode(24094653) and c:IsSSetable()
end
-- 效果②的发动条件判断和操作信息设置：判断是否可以放置指示物或盖放融合魔法
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 判断场上是否存在可放置捕食指示物的怪兽
	local b1=Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,0x1041,1)
	-- 判断墓地或除外区是否存在可盖放的融合魔法
	local b2=Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,c)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择效果②的选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},  --"放置指示物"
			{b2,aux.Stringid(id,3),2})  --"盖放「融合」"
	end
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_COUNTER)
		-- 获取可放置指示物的怪兽数组
		local g=Duel.GetMatchingGroup(Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,0x1041,1)
		-- 设置操作信息：将要放置指示物的怪兽
		Duel.SetOperationInfo(0,CATEGORY_COUNTER,g,1,0,0)
	elseif op==2 then
		e:SetCategory(CATEGORY_SSET)
	end
end
-- 效果②的处理函数：根据选择的选项执行放置指示物或盖放融合魔法
function s.effop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if e:GetLabel()==1 then
		-- 提示玩家选择要放置指示物的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)  --"请选择要放置指示物的卡"
		-- 选择可放置指示物的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,0x1041,1)
		local tc=g:GetFirst()
		if tc then
			-- 显示选中的怪兽被选为对象
			Duel.HintSelection(g)
			if tc:AddCounter(0x1041,1) and tc:GetLevel()>1 then
				-- 设置等级变化效果：当怪兽拥有捕食指示物时，等级变为1星
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
		-- 提示玩家选择要盖放的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
		-- 选择满足条件的融合魔法
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.setfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
		if #g>0 then
			-- 显示选中的卡被选为对象
			Duel.HintSelection(g)
			-- 将选中的卡盖放
			Duel.SSet(tp,g)
		end
	end
end
-- 等级变化效果的触发条件：当怪兽拥有捕食指示物时
function s.lvcon(e)
	return e:GetHandler():GetCounter(0x1041)>0
end
