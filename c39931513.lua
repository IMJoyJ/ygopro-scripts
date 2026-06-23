--天盃龍パイドラ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「灿幻」魔法·陷阱卡加入手卡或在自己场上盖放。
-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽的战斗发生的对自己的战斗伤害变成0。
-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
local s,id,o=GetID()
-- 创建并注册天杯龙 白龙的三个效果，包括检索、战斗伤害无效和同调召唤效果
function c39931513.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤的场合才能发动。从卡组选1张「灿幻」魔法·陷阱卡加入手卡或在自己场上盖放。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"检索"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SSET)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己的龙族·炎属性怪兽的战斗发生的对自己的战斗伤害变成0。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.target)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己·对方的战斗阶段才能发动。用包含这张卡的自己场上的怪兽为素材进行同调召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(50091196,1))  --"同调召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_QUICK_O)
	e4:SetCode(EVENT_FREE_CHAIN)
	e4:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_STEP_END+TIMING_BATTLE_END)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetCondition(s.sccon)
	e4:SetTarget(s.sctarg)
	e4:SetOperation(s.scop)
	c:RegisterEffect(e4)
end
-- 定义检索效果的过滤函数，用于筛选「灿幻」魔法·陷阱卡
function s.thfilter(c)
	if not (c:IsSetCard(0x1a9) and c:IsType(TYPE_SPELL+TYPE_TRAP)) then return false end
	return c:IsAbleToHand() or c:IsSSetable()
end
-- 检索效果的发动条件判断，检查卡组中是否存在符合条件的卡
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在符合条件的「灿幻」魔法·陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向对方玩家提示发动了检索效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,0))  --"检索"
end
-- 执行检索效果的操作，选择并处理一张「灿幻」魔法·陷阱卡
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要操作的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_OPERATECARD)  --"请选择要操作的卡"
	-- 从卡组中选择一张符合条件的「灿幻」魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 判断是否将卡加入手牌或盖放
		if tc:IsAbleToHand() and (not tc:IsSSetable() or Duel.SelectOption(tp,1190,1153)==0) then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(tc,nil,REASON_EFFECT)
			-- 向对方玩家确认手牌
			Duel.ConfirmCards(1-tp,tc)
		else
			-- 将选中的卡盖放在场上
			Duel.SSet(tp,tc)
		end
	end
end
-- 定义战斗伤害无效效果的目标过滤函数，筛选龙族·炎属性怪兽
function s.target(e,c)
	return c:IsAttribute(ATTRIBUTE_FIRE) and c:IsRace(RACE_DRAGON)
end
-- 判断同调召唤效果是否可以发动，检查当前阶段是否为战斗阶段
function s.sccon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前游戏阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 同调召唤效果的发动条件判断，检查额外卡组中是否存在可同调召唤的怪兽
function s.sctarg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查额外卡组中是否存在可同调召唤的怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,1,nil,c) end
	-- 向对方玩家提示发动了同调召唤效果
	Duel.Hint(HINT_OPSELECTED,1-tp,aux.Stringid(id,1))  --"同调召唤"
	-- 设置同调召唤效果的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
-- 执行同调召唤效果的操作，选择并进行同调召唤
function s.scop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	-- 获取额外卡组中所有可同调召唤的怪兽
	local g=Duel.GetMatchingGroup(Card.IsSynchroSummonable,tp,LOCATION_EXTRA,0,nil,c)
	if g:GetCount()>0 then
		-- 提示玩家选择要特殊召唤的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
		local sg=g:Select(tp,1,1,nil)
		-- 执行同调召唤手续
		Duel.SynchroSummon(tp,sg:GetFirst(),c)
	end
end
