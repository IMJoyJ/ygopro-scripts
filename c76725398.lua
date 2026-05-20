--巳剣之勾玉
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：自己·对方的主要阶段，可以从以下效果选择1个发动。
-- ●把自己场上1只爬虫类族怪兽解放，以对方场上1张表侧表示卡为对象才能发动。那张卡破坏。
-- ●等级合计直到变成仪式召唤的怪兽的等级以上为止，把自己场上的怪兽解放，从手卡把1只「巳剑」仪式怪兽仪式召唤。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：自己·对方的主要阶段，可以从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"发动"
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER+TIMING_MAIN_END)
	e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
-- 过滤可解放的爬虫类族怪兽，且对方场上必须存在至少1张表侧表示的卡作为潜在的破坏对象
function s.cfilter(c,tp)
	return c:IsRace(RACE_REPTILE) and (c:IsControler(tp) or c:IsFaceup())
		-- 检查对方场上是否存在除自身（被解放的怪兽）以外的表侧表示卡片作为对象
		and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,c)
end
-- 效果发动的阶段条件判定函数
function s.con(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为自己或对方的主要阶段
	return Duel.IsMainPhase()
end
-- 效果发动时的目标选择与合法性检测函数（处理分支选择、解放代价、取对象及仪式召唤的准备）
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	-- 检查是否满足解放1只爬虫类族怪兽的代价条件（若不检查代价则默认为真）
	local c1=not e:IsCostChecked() or Duel.CheckReleaseGroup(tp,s.cfilter,1,nil,tp)
	-- 判定分支1（破坏效果）是否满足发动条件（有可解放的爬虫类族怪兽且对方场上有表侧表示的卡）
	local b1=c1 and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,nil)
	-- 判定分支2（仪式召唤）是否满足发动条件（手卡有可仪式召唤的「巳剑」怪兽且场上有足够的解放素材）
	local b2=aux.RitualUltimateTarget(s.ritual_filter,Card.GetLevel,"Greater",LOCATION_HAND,nil,s.mfilter)(e,tp,eg,ep,ev,re,r,rp,0)
	if chkc then
		if e:GetLabel()~=1 then return false end
		return chkc:IsLocation(LOCATION_ONFIELD) and chkc:IsControler(1-tp) and chkc:IsFaceup()
	end
	if chk==0 then return b1 or b2 end
	-- 让玩家从满足发动条件的分支效果中选择1个发动
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},  --"破坏"
		{b2,aux.Stringid(id,2),2}  --"仪式召唤"
	)
	if op==1 then
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_DESTROY)
			e:SetProperty(EFFECT_FLAG_CARD_TARGET)
			-- 玩家选择场上1只满足条件的爬虫类族怪兽作为解放代价
			local g=Duel.SelectReleaseGroup(tp,s.cfilter,1,1,nil,tp)
			-- 应用代替解放等相关效果的次数限制
			aux.UseExtraReleaseCount(g,tp)
			-- 将选中的怪兽解放作为发动的代价
			Duel.Release(g,REASON_COST)
		end
		e:SetLabel(1)
		-- 提示玩家选择要破坏的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
		-- 选择对方场上1张表侧表示的卡作为效果的对象
		local g=Duel.SelectTarget(tp,Card.IsFaceup,tp,0,LOCATION_ONFIELD,1,1,nil)
		-- 设置效果处理信息为“破坏选中的1张卡”
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
	elseif op==2 then
		e:SetLabel(2)
		if e:IsCostChecked() then
			e:SetCategory(CATEGORY_SPECIAL_SUMMON)
			e:SetProperty(0)
		end
		-- 执行仪式召唤效果的目标检测与信息设置
		aux.RitualUltimateTarget(s.ritual_filter,Card.GetLevel,"Greater",LOCATION_HAND,nil,s.mfilter)(e,tp,eg,ep,ev,re,r,rp,chk)
	end
end
-- 效果处理的执行函数，根据发动的分支执行对应的破坏或仪式召唤处理
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		-- 获取在发动阶段选择的作为对象的卡片
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToChain() then
			-- 将作为对象的卡片破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
	elseif e:GetLabel()==2 then
		-- 执行仪式召唤的具体操作（解放场上怪兽并从手卡特殊召唤「巳剑」仪式怪兽）
		aux.RitualUltimateOperation(s.ritual_filter,Card.GetLevel,"Greater",LOCATION_HAND,nil,s.mfilter)(e,tp,eg,ep,ev,re,r,rp)
	end
end
-- 过滤仪式召唤的素材，限定为自己场上的怪兽
function s.mfilter(c)
	return c:IsLocation(LOCATION_MZONE)
end
-- 过滤可仪式召唤的怪兽，限定为「巳剑」仪式怪兽
function s.ritual_filter(c)
	return c:IsType(TYPE_RITUAL) and c:IsSetCard(0x1c3)
end
