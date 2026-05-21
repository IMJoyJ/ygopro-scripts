--EM稀代の決闘者
-- 效果：
-- ←8 【灵摆】 8→
-- ①：1回合1次，怪兽之间进行战斗的伤害步骤开始时才能发动。这张卡回到持有者手卡，从卡组把1张魔法卡除外。自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成一半。
-- 【怪兽效果】
-- ①：这张卡给与对方战斗伤害时才能发动。从卡组把1只「霸王眷龙」怪兽或者「霸王门」怪兽或者1张「霸王龙之魂」加入手卡。
-- ②：自己·对方的准备阶段发动。双方各自可以从自身卡组把1张魔法卡除外。
-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时发动。被攻击的玩家可以让以下效果适用。
-- ●选除外的1张自身的魔法卡加入手卡。那之后，那张卡丢弃，那次攻击无效。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数
function s.initial_effect(c)
	-- 启用灵摆怪兽属性（注册灵摆召唤及灵摆区域发动效果）
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，怪兽之间进行战斗的伤害步骤开始时才能发动。这张卡回到持有者手卡，从卡组把1张魔法卡除外。自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"自己怪兽不会被那次战斗破坏"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_START)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcon1)
	e1:SetTarget(s.atktg1)
	e1:SetOperation(s.atkop1)
	c:RegisterEffect(e1)
	-- ①：这张卡给与对方战斗伤害时才能发动。从卡组把1只「霸王眷龙」怪兽或者「霸王门」怪兽或者1张「霸王龙之魂」加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"卡组检索"
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DAMAGE)
	e2:SetCondition(s.thcon)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	-- ②：自己·对方的准备阶段发动。双方各自可以从自身卡组把1张魔法卡除外。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"双方从卡组把魔法卡除外"
	e3:SetCategory(CATEGORY_REMOVE)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	-- ③：1回合1次，自己或者对方的怪兽的攻击宣言时发动。被攻击的玩家可以让以下效果适用。●选除外的1张自身的魔法卡加入手卡。那之后，那张卡丢弃，那次攻击无效。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,3))  --"用除外的魔法卡把攻击无效"
	e4:SetCategory(CATEGORY_TOHAND+CATEGORY_HANDES)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_ATTACK_ANNOUNCE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.atktg2)
	e4:SetOperation(s.atkop2)
	c:RegisterEffect(e4)
end
-- 灵摆效果①的发动条件：怪兽之间进行战斗的伤害步骤开始时
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的双方怪兽
	local a,d=Duel.GetBattleMonster(tp)
	return a and d
end
-- 过滤条件：卡组中可以除外的魔法卡
function s.rmfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToRemove()
end
-- 灵摆效果①的发动准备：检查此卡是否能回到手卡，以及卡组中是否存在可除外的魔法卡
function s.atktg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToHand()
		-- 检查自己卡组是否存在至少1张可以除外的魔法卡
		and Duel.IsExistingMatchingCard(s.rmfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：将这张卡（自身）送回手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,c,1,0,0)
	-- 设置操作信息：从卡组除外1张卡
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果①的效果处理：此卡回手，除外卡组魔法卡，并适用战斗破坏抗性与伤害减半效果
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 若这张卡因效果成功回到手卡且目前存在于手卡中
	if Duel.SendtoHand(c,nil,REASON_EFFECT)>0 and c:IsLocation(LOCATION_HAND) then
		-- 提示玩家选择要除外的卡片
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
		-- 从卡组选择1张满足条件的魔法卡
		local g=Duel.SelectMatchingCard(tp,s.rmfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			-- 将选中的魔法卡表侧表示除外
			Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
		end
	end
	-- 获取自己进行战斗的怪兽
	local tc=Duel.GetBattleMonster(tp)
	if tc then
		-- 自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
	-- 那次战斗发生的对自己的战斗伤害变成一半。这张卡给与对方战斗伤害时才能发动。从卡组把1只「霸王眷龙」怪兽或者「霸王门」怪兽或者1张「霸王龙之魂」加入手卡。自己·对方的准备阶段发动。双方各自可以从自身卡组把1张魔法卡除外。1回合1次，自己或者对方的怪兽的攻击宣言时发动。被攻击的玩家可以让以下效果适用。●选除外的1张自身的魔法卡加入手卡。那之后，那张卡丢弃，那次攻击无效。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 在全局注册该次战斗伤害减半的效果
	Duel.RegisterEffect(e2,tp)
end
-- 怪兽效果①的发动条件：给与对方战斗伤害时
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
-- 过滤条件：卡组中的「霸王眷龙」怪兽、「霸王门」怪兽或「霸王龙之魂」
function s.thfilter(c)
	return c:IsAbleToHand() and (c:IsSetCard(0x10f8,0x20f8) and c:IsType(TYPE_MONSTER) or c:IsCode(92428405))
end
-- 怪兽效果①的发动准备：检查卡组中是否存在可检索的卡，并设置检索的操作信息
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组是否存在至少1张满足条件的卡
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置操作信息：从卡组将1张卡加入手卡
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 怪兽效果①的效果处理：从卡组选择1张满足条件的卡加入手卡并给对方确认
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手卡的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组选择1张满足条件的卡片
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡片加入手卡
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 给对方玩家确认加入手卡的卡片
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果②的效果处理：双方玩家在准备阶段可以各自从自身卡组把1张魔法卡除外
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前回合玩家
	local p=Duel.GetTurnPlayer()
	for i=1,2 do
		-- 获取该玩家卡组中所有可以除外的魔法卡
		local g=Duel.GetMatchingGroup(s.rmfilter,p,LOCATION_DECK,0,nil)
		-- 若卡组有可除外的魔法卡，询问该玩家是否选择除外
		if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,4)) then  --"是否从卡组把魔法卡除外？"
			-- 提示该玩家选择要除外的卡片
			Duel.Hint(HINT_SELECTMSG,p,HINTMSG_REMOVE)  --"请选择要除外的卡"
			local tg=g:Select(p,1,1,nil)
			-- 将该玩家选中的魔法卡表侧表示除外
			Duel.Remove(tg,POS_FACEUP,REASON_EFFECT)
		end
		p=1-p
	end
end
-- 怪兽效果③的发动准备：将效果适用的目标玩家设为被攻击的玩家
function s.atktg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 将当前连锁的目标玩家设置为被攻击的玩家（攻击怪兽控制者的对手）
	Duel.SetTargetPlayer(1-Duel.GetAttacker():GetControler())
end
-- 过滤条件：除外状态的表侧表示且可以加入手卡的魔法卡
function s.disfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsFaceup() and c:IsAbleToHand()
end
-- 怪兽效果③的效果处理：被攻击的玩家可选择将除外的1张自身魔法卡加入手卡，之后丢弃该卡并无效该次攻击
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前连锁的目标玩家（即被攻击的玩家）
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	-- 获取该玩家除外状态的表侧表示魔法卡
	local g=Duel.GetMatchingGroup(s.disfilter,p,LOCATION_REMOVED,0,nil)
	-- 若存在可回收的除外魔法卡，询问被攻击的玩家是否让效果适用
	if #g>0 and Duel.SelectYesNo(p,aux.Stringid(id,5)) then  --"是否用除外的魔法卡把攻击无效？"
		-- 提示被攻击的玩家选择要加入手卡的除外魔法卡
		Duel.Hint(HINT_SELECTMSG,p,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local tc=g:Select(p,1,1,nil):GetFirst()
		-- 若成功将选中的魔法卡加入手卡且该卡确实存在于手卡中
		if Duel.SendtoHand(tc,nil,REASON_EFFECT)>0 and tc:IsLocation(LOCATION_HAND) then
			-- 给对方玩家确认加入手卡的卡片
			Duel.ConfirmCards(1-p,tc)
			-- 中断当前效果处理，使后续的丢弃与无效攻击处理不与加入手卡视为同时进行
			Duel.BreakEffect()
			-- 若成功将该卡丢弃送去墓地
			if Duel.SendtoGrave(tc,REASON_EFFECT+REASON_DISCARD)>0 then
				-- 使那次攻击无效
				Duel.NegateAttack()
			end
		end
	end
end
