--鉄獣の撃鉄
-- 效果：
-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●从卡组把「铁兽的击铁」以外的1张「铁兽」魔法·陷阱卡加入手卡。
-- ●从自己墓地把「铁兽」卡任意数量除外才能发动。把持有和除外数量相同数量的连接标记的1只「铁兽」连接怪兽从额外卡组无视召唤条件特殊召唤。这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
local s,id,o=GetID()
-- 定义卡片发动时的效果
function s.initial_effect(c)
	-- ①：可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(TIMING_DRAW_PHASE,TIMINGS_CHECK_MONSTER+TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
-- 过滤卡组中「铁兽的击铁」以外的「铁兽」魔法·陷阱卡
function s.thfilter(c)
	return not c:IsCode(id) and c:IsSetCard(0x14d) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 过滤自己墓地中可以作为Cost除外的「铁兽」卡
function s.cfilter(c)
	return c:IsSetCard(0x14d) and c:IsAbleToRemoveAsCost()
end
-- 检查除外卡片数量是否与额外卡组中某只「铁兽」连接怪兽的连接标记数量相同
function s.fselect(g,tg)
	return tg:IsExists(Card.IsLink,1,nil,#g)
end
-- 过滤额外卡组中可以特殊召唤的「铁兽」连接怪兽
function s.spfilter(c,e,tp)
	return c:IsType(TYPE_LINK) and c:IsSetCard(0x14d)
		-- 检查怪兽是否能无视召唤条件特殊召唤，且额外怪兽区域或连接端有空位
		and c:IsCanBeSpecialSummoned(e,0,tp,true,false) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
-- 效果发动时的目标选择与Cost处理（包括分支选择、次数限制检查、除外Cost支付及操作信息设置）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在可检索的「铁兽」魔法·陷阱卡
	local b1=Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
		and (not e:IsCostChecked()
			-- 或者本回合尚未选择过第一个效果（检索效果）
			or Duel.GetFlagEffect(tp,id)==0)
	-- 获取自己墓地中所有可作为Cost除外的「铁兽」卡
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	-- 获取额外卡组中所有符合特殊召唤条件的「铁兽」连接怪兽
	local tg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp)
	local _,maxlink=tg:GetMaxGroup(Card.GetLink)
	local b2=#tg>0 and cg:CheckSubGroup(s.fselect,1,maxlink,tg)
		-- 且本回合尚未选择过第二个效果（特召效果），并且当前是在确认能否支付Cost的发动准备阶段
		and Duel.GetFlagEffect(tp,id+o)==0 and e:IsCostChecked()
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择要发动的效果分支
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"检索效果"
			{b2,aux.Stringid(id,2),2})  --"连接召唤"
	end
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
			-- 给玩家注册已使用第一个效果的标记，持续到回合结束
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		e:SetLabel(op,0)
		-- 设置将卡组的1张卡加入手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		-- 给玩家注册已使用第二个效果的标记，持续到回合结束
		Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		-- 提示玩家选择要除外的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		local rg=cg:SelectSubGroup(tp,s.fselect,false,1,maxlink,tg)
		-- 将选中的墓地卡片表侧表示除外作为发动的Cost
		Duel.Remove(rg,POS_FACEUP,REASON_COST)
		e:SetLabel(op,rg:GetCount())
		-- 设置从额外卡组特殊召唤1只怪兽的操作信息
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	end
end
-- 过滤额外卡组中连接标记数量等于除外卡片数量的「铁兽」连接怪兽
function s.spfilter1(c,e,tp,lk)
	return s.spfilter(c,e,tp) and c:IsLink(lk)
end
-- 效果处理的执行函数（根据选择的分支执行检索或特殊召唤，并适用特召限制）
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op,lk=e:GetLabel()
	if op==1 then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		-- 让玩家从卡组选择1张满足条件的「铁兽」魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 给对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==2 then
		-- 提示玩家选择要特殊召唤的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 让玩家从额外卡组选择1只连接标记数量与除外数量相同的「铁兽」连接怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter1,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,lk)
		local tc=g:GetFirst()
		if tc then
			-- 将选中的怪兽无视召唤条件表侧表示特殊召唤
			Duel.SpecialSummon(tc,0,tp,tp,true,false,POS_FACEUP)
		end
		-- 这个回合，自己不是兽族·兽战士族·鸟兽族怪兽不能从额外卡组特殊召唤。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetTargetRange(1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_PHASE+PHASE_END)
		-- 注册该回合内限制从额外卡组特殊召唤非兽族·兽战士族·鸟兽族怪兽的玩家效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 限制只能从额外卡组特殊召唤兽族、兽战士族、鸟兽族怪兽
function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA) and not c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR+RACE_WINDBEAST)
end
