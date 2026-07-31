--疾風の豹戦士パンサーウォリアー
local s,id,o=GetID()
-- 初始化卡片效果：注册记述卡号、①主要阶段二选一效果（手卡·卡组特召记述卡/卡组魔陷精堆）、②未解放怪兽不能攻击限制、③全局解放行为检测
function s.initial_effect(c)
	-- 注册记述卡号：40235813
	aux.AddCodeList(c,40235813)
	-- ①：自己·对方的主要阶段，解放自己场上1只怪兽才能发动。从以下效果选择1个适用。●从手卡·卡组把1只「疾风之豹战士」以外记述「豹战士」的怪兽特殊召唤。●从卡组把1张记述「豹战士」的魔法·陷阱卡送去墓地。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.recon)
	e1:SetCost(s.recost)
	e1:SetTarget(s.retg)
	e1:SetOperation(s.reop)
	c:RegisterEffect(e1)
	-- ②：这个回合没有怪兽被解放的场合，这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(s.atkcon)
	c:RegisterEffect(e2)
	if not s.global_check then
		s.global_check=true
		-- 注册全局监听效果：监测怪兽被解放的操作，并在发生解放时记录标志
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_RELEASE)
		ge1:SetOperation(s.checkop)
		-- 向双方玩家注册全局连续效果
		Duel.RegisterEffect(ge1,0)
	end
end
-- 解放过滤条件：离场前为怪兽或原本类型为怪兽
function s.checkfilter(c)
	return c:GetPreviousTypeOnField()&TYPE_MONSTER~=0 or (not c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetOriginalType()&TYPE_MONSTER~=0)
end
-- 全局监听处理：若发生怪兽解放，注册回合结束前生效的标记
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if eg:IsExists(s.checkfilter,1,nil) then
		-- 给双方玩家注册当回合有效的标记
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
-- ①效果发动条件：双方的主要阶段
function s.recon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段
	return Duel.IsMainPhase()
end
-- Cost过滤条件：场上的怪兽，且解放后满足后续处理条件（可送墓魔陷或可特召怪兽）
function s.cfilter(c,tp,e)
	return c:IsType(TYPE_MONSTER)
		-- 判断卡组是否存在可送墓的记述魔陷
		and (Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil) or
			-- 判断解放该卡后怪兽区是否有空位且手卡·卡组存在可特召怪兽
			Duel.GetMZoneCount(tp,c)>0 and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,c,e,tp))
end
-- ①效果发动Cost：解放自己场上1只怪兽
function s.recost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- Cost检查：场上是否存在满足条件的解放卡片
	if chk==0 then return Duel.CheckReleaseGroupEx(tp,s.cfilter,1,REASON_COST,true,e:GetHandler(),tp,e) end
	-- 提示玩家选择要解放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	-- 选择自己场上1只满足条件的怪兽
	local g=Duel.SelectReleaseGroupEx(tp,s.cfilter,1,1,REASON_COST,true,e:GetHandler(),tp,e)
	-- 解放选择的怪兽作为发动Cost
	Duel.Release(g,REASON_COST)
end
-- 卡组过滤条件：记述「豹战士」的魔法·陷阱卡且可送去墓地
function s.tgfilter(c)
	-- 判断是否为记述「豹战士」的魔法·陷阱卡
	return aux.IsCodeListed(c,40235813) and c:IsType(TYPE_SPELL+TYPE_TRAP)
		and c:IsAbleToGrave()
end
-- 特召过滤条件：非同名卡且记述「豹战士」的怪兽，且可特殊召唤
function s.spfilter(c,e,tp)
	-- 判断是否为非同名、记述「豹战士」且可特召的怪兽
	return not c:IsCode(id) and aux.IsCodeListed(c,40235813) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ①效果发动准备：选择要发动的效果分支并设置操作信息
function s.retg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查分支1（手卡·卡组特召）是否可行
	local b1=Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	-- 检查分支2（卡组送墓魔陷）是否可行
	local b2=Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
	if chk==0 then return b1 or b2 end
	-- 提示玩家选择要适用的效果分支
	local op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,2),1},
			{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		end
		-- 设置连锁操作信息：从手卡·卡组特殊召唤1只怪兽
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_TOGRAVE)
		end
		-- 设置连锁操作信息：从卡组将1张卡送去墓地
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
	end
end
-- ①效果处理：根据选择的分支执行特召或送墓
function s.reop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 分支1效果处理条件：确认怪兽区域是否有空位
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		-- 从手卡·卡组选择1只满足条件的怪兽
		local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
		if g:GetCount()>0 then
			-- 将选择的怪兽表侧表示特殊召唤
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要送去墓地的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
		-- 从卡组选择1张记述「豹战士」的魔法·陷阱卡
		local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
		if g:GetCount()>0 then
			-- 将选择的卡送去墓地
			Duel.SendtoGrave(g,REASON_EFFECT)
		end
	end
end
-- 攻击限制条件：当回合没有发生过怪兽解放
function s.atkcon(e)
	-- 判断全局解放标记数量是否为0
	return Duel.GetFlagEffect(0,id)==0
end
