--メガリス・アナスタシス
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：丢弃1张手卡才能发动。从卡组把4星以下和8星以上的「巨石遗物」怪兽各1只加入手卡。
-- ②：1回合1次，自己把「巨石遗物」怪兽仪式召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
-- ●自己抽2张。那之后，选自己1张手卡丢弃。
-- ●对方场上1只怪兽解放。
local s,id,o=GetID()
-- 初始化卡片效果，注册场地魔法卡的发动和触发效果
function s.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：丢弃1张手卡才能发动。从卡组把4星以下和8星以上的「巨石遗物」怪兽各1只加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))  --"检索效果"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：1回合1次，自己把「巨石遗物」怪兽仪式召唤的场合，可以从以下效果选择1个发动（这个卡名的以下效果1回合各能选择1次）。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))
	e3:SetCategory(CATEGORY_DRAW+CATEGORY_RELEASE+CATEGORY_HANDES)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.drcon)
	e3:SetTarget(s.drtg)
	e3:SetOperation(s.drop)
	c:RegisterEffect(e3)
end
-- 检索满足条件的「巨石遗物」怪兽并丢弃手卡
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家手牌中是否存在可丢弃的卡
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) end
	-- 丢弃1张手卡作为发动代价
	Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_COST+REASON_DISCARD)
end
-- 过滤函数，筛选可加入手牌的「巨石遗物」怪兽
function s.thfilter(c)
	return c:IsAbleToHand() and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x138)
end
-- 检查组中是否包含4星以下和8星以上的「巨石遗物」怪兽各1只
function s.gcheck(g)
	return g:FilterCount(Card.IsLevelAbove,nil,8)==1
		and g:FilterCount(Card.IsLevelBelow,nil,4)==1
end
-- 设置检索效果的目标信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取满足条件的卡组中的「巨石遗物」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if chk==0 then return g:CheckSubGroup(s.gcheck,2,2) end
	-- 设置检索效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_DECK)
end
-- 执行检索效果，选择并加入手牌
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取满足条件的卡组中的「巨石遗物」怪兽
	local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_DECK,0,nil)
	if #g>0 and g:CheckSubGroup(s.gcheck,2,2) then
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local sg=g:SelectSubGroup(tp,s.gcheck,false,2,2)
		if sg then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			-- 向对手确认加入手牌的卡
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
-- 过滤函数，筛选自己仪式召唤成功的「巨石遗物」怪兽
function s.spfilter(c,tp)
	return c:IsFaceup() and c:IsType(TYPE_RITUAL) and c:IsSummonType(SUMMON_TYPE_RITUAL) and c:IsSetCard(0x138) and c:IsSummonPlayer(tp)
end
-- 判断是否满足触发条件：自己有「巨石遗物」怪兽仪式召唤成功
function s.drcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.spfilter,1,nil,tp)
end
-- 设置效果选择的选项并注册效果
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家是否可以抽2张卡
	local b1=Duel.IsPlayerCanDraw(tp,2)
		-- 检查该效果是否已在本回合使用过
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id)==0)
	-- 检查对方场上是否存在可解放的怪兽
	local b2=Duel.IsExistingMatchingCard(Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,nil)
		-- 检查该效果是否已在本回合使用过
		and (not e:IsCostChecked() or Duel.GetFlagEffect(tp,id+o)==0)
	if chk==0 then return b1 or b2 end
	local op=0
	if b1 or b2 then
		-- 让玩家选择效果选项
		op=aux.SelectFromOptions(tp,
			{b1,aux.Stringid(id,1),1},  --"抽卡"
			{b2,aux.Stringid(id,2),2})  --"解放"
	end
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DRAW+CATEGORY_HANDES)
			-- 注册抽卡效果的使用标记
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置抽卡效果的目标玩家
		Duel.SetTargetPlayer(tp)
		-- 设置抽卡效果的目标数量
		Duel.SetTargetParam(2)
		-- 设置抽卡效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
		-- 设置丢弃手牌的操作信息
		Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	elseif op==2 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_RELEASE)
			-- 注册解放效果的使用标记
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		-- 设置解放效果的操作信息
		Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,1-tp,LOCATION_MZONE)
	end
end
-- 执行选择的效果
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取连锁中目标玩家
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		-- 执行抽2张卡的效果
		if Duel.Draw(p,2,REASON_EFFECT)==2 then
			-- 提示玩家选择要丢弃的手牌
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
			-- 选择要丢弃的手牌
			local dg=Duel.SelectMatchingCard(p,Card.IsDiscardable,p,LOCATION_HAND,0,1,1,nil,REASON_EFFECT+REASON_DISCARD)
			if dg:GetCount()>0 then
				-- 中断当前效果处理
				Duel.BreakEffect()
				-- 洗切玩家手牌
				Duel.ShuffleHand(p)
				-- 将选中的手牌送入墓地
				Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD,p)
			end
		end
	elseif e:GetLabel()==2 then
		-- 提示玩家选择要解放的怪兽
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
		-- 选择要解放的怪兽
		local g=Duel.SelectMatchingCard(tp,Card.IsReleasableByEffect,tp,0,LOCATION_MZONE,1,1,nil)
		local tc=g:GetFirst()
		if tc then
			-- 中断当前效果处理
			Duel.BreakEffect()
			-- 显示选中的怪兽被解放的动画
			Duel.HintSelection(g)
			-- 解放选中的怪兽
			Duel.Release(g,REASON_EFFECT)
		end
	end
end
