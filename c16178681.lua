--オッドアイズ・ペンデュラム・ドラゴン
-- 效果：
-- ←4 【灵摆】 4→
-- 这个卡名的①②的灵摆效果1回合各能使用1次。
-- ①：可以把自己的灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
-- ②：自己结束阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
-- 【怪兽效果】
-- ①：这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
function c16178681.initial_effect(c)
	-- 给此灵摆怪兽添加灵摆怪兽属性，使其可以进行灵摆召唤、作为灵摆卡发动及放置在灵摆区。
	aux.EnablePendulumAttribute(c)
	-- 对应灵摆效果①（包含1回合1次的通用限制）：这个卡名的①②的灵摆效果1回合各能使用1次。①：可以把自己的灵摆怪兽的战斗发生的对自己的战斗伤害变成0。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16178681,0))  --"伤害变化"
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(c16178681.rdcon)
	e2:SetOperation(c16178681.rdop)
	c:RegisterEffect(e2)
	-- 对应灵摆效果②（包含1回合1次的通用限制）：这个卡名的①②的灵摆效果1回合各能使用1次。②：自己结束阶段才能发动。这张卡破坏，从卡组把1只攻击力1500以下的灵摆怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(16178681,1))  --"卡组检索"
	e3:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND+CATEGORY_SEARCH)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetRange(LOCATION_PZONE)
	e3:SetCountLimit(1,16178682)
	e3:SetCondition(c16178681.thcon)
	e3:SetTarget(c16178681.thtg)
	e3:SetOperation(c16178681.thop)
	c:RegisterEffect(e3)
	-- 对应怪兽效果①：①：这张卡用和对方怪兽的战斗给与对方的战斗伤害变成2倍。
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e4:SetCondition(c16178681.damcon)
	-- 设置效果值为将对手玩家受到的战斗伤害变为2倍（DOUBLE_DAMAGE），即此卡与对方怪兽战斗时给予对方的战斗伤害翻倍。
	e4:SetValue(aux.ChangeBattleDamage(1,DOUBLE_DAMAGE))
	c:RegisterEffect(e4)
end
-- 灵摆效果①的发动条件：检测即将发生的对自己的战斗伤害是否来自自己的灵摆怪兽的战斗，且本回合该效果尚未发动（flag为0）。只有满足这些条件时才能询问是否把伤害变成0。
function c16178681.rdcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前战斗中的攻击怪兽。
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方控制的，则将判定对象改为被攻击的怪兽；这样即可确定“自己的灵摆怪兽”是哪一只。
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	-- 返回条件：战斗伤害承受者是自己（ep==tp）、存在战斗怪兽tc、tc是灵摆怪兽，并且自己本回合没有发动过该效果（flag为0）。
	return ep==tp and tc and tc:IsType(TYPE_PENDULUM) and Duel.GetFlagEffect(tp,16178681)==0
end
-- 灵摆效果①的发动处理：询问玩家是否把对自己的战斗伤害变为0；若选择是，展示此卡动画，将本场战斗伤害变为0，并注册flag标记本回合已使用。
function c16178681.rdop(e,tp,eg,ep,ev,re,r,rp)
	-- 弹出是否发动效果的确认框，若玩家选择“是”才继续处理。
	if Duel.SelectYesNo(tp,aux.Stringid(16178681,2)) then  --"是否要把战斗伤害变成0？"
		-- 向双方展示异色眼灵摆龙，手动播放发动效果时的卡片动画。
		Duel.Hint(HINT_CARD,0,16178681)
		-- 将玩家tp本次受到的战斗伤害改变为0，实现伤害变为0的效果。
		Duel.ChangeBattleDamage(tp,0)
		-- 给tp注册一个到结束阶段重置的flag，记录本回合已发动过灵摆效果①，防止再次发动。
		Duel.RegisterFlagEffect(tp,16178681,RESET_PHASE+PHASE_END,0,1)
	end
end
-- 灵摆效果②的发动条件：只有当前回合玩家是自己（自己的结束阶段）时才允许发动。
function c16178681.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为效果持有者tp，即确保效果只能在自己的结束阶段发动。
	return Duel.GetTurnPlayer()==tp
end
-- 定义检索卡组的过滤器：选择攻击力1500以下、是灵摆怪兽且可以加入手卡的卡。
function c16178681.filter(c)
	return c:IsType(TYPE_PENDULUM) and c:IsAttackBelow(1500) and c:IsAbleToHand()
end
-- 灵摆效果②的发动目标判定：确认自身可以被破坏，同时卡组中存在满足检索条件的灵摆怪兽，否则不能发动。
function c16178681.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDestructable()
		-- 检查卡组中是否存在至少1只满足条件的灵摆怪兽，用于判定效果是否可发动。
		and Duel.IsExistingMatchingCard(c16178681.filter,tp,LOCATION_DECK,0,1,nil) end
	-- 登记破坏效果的操作信息：效果处理时将破坏此卡（自身）1张，用于连锁检测。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,e:GetHandler(),1,0,0)
	-- 登记检索加入手牌的操作信息：效果处理时从卡组将1张卡加入手牌（具体处理时选择）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 灵摆效果②的发动处理：先破坏自身，若破坏成功则从卡组选择1只攻击力1500以下的灵摆怪兽加入手牌，并向对方确认。
function c16178681.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身仍与效果关联后将其破坏；若效果发动后此卡已不关联或破坏未成功，则中断处理，不进行检索。
	if not c:IsRelateToEffect(e) or Duel.Destroy(c,REASON_EFFECT)==0 then return end
	-- 发送“请选择要加入手牌的卡”的提示，供玩家选择卡组中的目标。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 让玩家从自己卡组选择1只满足条件的灵摆怪兽作为加入手牌的对象。
	local g=Duel.SelectMatchingCard(tp,c16178681.filter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选择的卡加入其持有者的手卡（通常是自己），完成检索。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示此次加入手牌的卡，确认检索结果。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- 怪兽效果①的发动条件判定：此卡进行了战斗且存在战斗目标（BattleTarget）时，才会把给予对方的战斗伤害变成2倍。
function c16178681.damcon(e)
	return e:GetHandler():GetBattleTarget()~=nil
end
