--E・HERO エアーマン
-- 效果：
-- ①：这张卡召唤·特殊召唤时，可以从以下效果选择1个发动。
-- ●把最多有自己场上的其他的「英雄」怪兽数量的场上的魔法·陷阱卡破坏。
-- ●从卡组把1只「英雄」怪兽加入手卡。
function c40044918.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤时，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(40044918,0))  --"选择一个效果发动"
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_TRIGGER_O+EFFECT_TYPE_SINGLE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c40044918.tg)
	e1:SetOperation(c40044918.op)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，返回场上表侧表示的「英雄」怪兽数量
function c40044918.ctfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x8)
end
-- 过滤函数，返回卡组中可以加入手牌的「英雄」怪兽
function c40044918.schfilter(c)
	return c:IsSetCard(0x8) and c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 过滤函数，返回场上的魔法·陷阱卡
function c40044918.desfilter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP)
end
-- 效果处理的条件判断与选项选择，检查是否满足发动条件并选择效果
function c40044918.tg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		-- 获取自己场上表侧表示的「英雄」怪兽数量
		local ct=Duel.GetMatchingGroupCount(c40044918.ctfilter,tp,LOCATION_MZONE,0,c)
		local sel=0
		-- 若自己场上存在「英雄」怪兽且场上存在魔法·陷阱卡，则可选择破坏效果
		if ct>0 and Duel.IsExistingMatchingCard(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) then sel=sel+1 end
		-- 若卡组中存在「英雄」怪兽，则可选择检索效果
		if Duel.IsExistingMatchingCard(c40044918.schfilter,tp,LOCATION_DECK,0,1,nil) then sel=sel+2 end
		e:SetLabel(sel)
		return sel~=0
	end
	local sel=e:GetLabel()
	if sel==3 then
		-- 提示玩家选择发动效果
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(40044918,0))  --"选择一个效果发动"
		-- 选择发动破坏效果或检索效果
		sel=Duel.SelectOption(tp,aux.Stringid(40044918,1),aux.Stringid(40044918,2))+1  --"魔法·陷阱卡破坏/「英雄」怪兽加入手卡"
	elseif sel==1 then
		-- 选择发动破坏效果
		Duel.SelectOption(tp,aux.Stringid(40044918,1))  --"魔法·陷阱卡破坏"
	else
		-- 选择发动检索效果
		Duel.SelectOption(tp,aux.Stringid(40044918,2))  --"「英雄」怪兽加入手卡"
	end
	e:SetLabel(sel)
	if sel==1 then
		-- 获取场上的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		e:SetCategory(CATEGORY_DESTROY)
		-- 设置操作信息为破坏效果
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	else
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		-- 设置操作信息为检索效果
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
-- 效果处理的执行函数，根据选择的效果执行对应操作
function c40044918.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local sel=e:GetLabel()
	if sel==1 then
		-- 获取自己场上表侧表示的「英雄」怪兽数量
		local ct=Duel.GetMatchingGroupCount(c40044918.ctfilter,tp,LOCATION_MZONE,0,c)
		-- 获取场上的魔法·陷阱卡
		local g=Duel.GetMatchingGroup(c40044918.desfilter,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil)
		if ct>0 and g:GetCount()>0 then
			-- 提示玩家选择要破坏的卡
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
			local dg=g:Select(tp,1,ct,nil)
			-- 显示被选为对象的动画效果
			Duel.HintSelection(dg)
			-- 以效果原因破坏选中的卡
			Duel.Destroy(dg,REASON_EFFECT)
		end
	else
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 从卡组中选择1只「英雄」怪兽加入手牌
		local g=Duel.SelectMatchingCard(tp,c40044918.schfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 确认对方手牌
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
