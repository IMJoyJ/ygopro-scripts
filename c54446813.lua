--ダイナレスラー・マーシャルアンペロ
-- 效果：
-- 这个卡名的②的效果1回合只能使用1次。
-- ①：自己的其他的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成一半。
-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。从卡组把「恐龙摔跤手·武术葡萄园龙」以外的1只「恐龙摔跤手」怪兽加入手卡。
function c54446813.initial_effect(c)
	-- ①：自己的其他的「恐龙摔跤手」怪兽和持有那个攻击力以上的攻击力的对方怪兽进行战斗的伤害计算时，把手卡·场上的这张卡送去墓地才能发动。那只自己怪兽不会被那次战斗破坏，那次战斗发生的对自己的战斗伤害变成一半。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(54446813,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE+LOCATION_HAND)
	e1:SetCondition(c54446813.btcon)
	e1:SetCost(c54446813.btcost)
	e1:SetOperation(c54446813.btop)
	c:RegisterEffect(e1)
	-- ②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。从卡组把「恐龙摔跤手·武术葡萄园龙」以外的1只「恐龙摔跤手」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(54446813,1))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,54446813)
	e2:SetCondition(c54446813.thcon)
	-- 把墓地的这张卡除外作为发动的代价
	e2:SetCost(aux.bfgcost)
	e2:SetTarget(c54446813.thtg)
	e2:SetOperation(c54446813.thop)
	c:RegisterEffect(e2)
end
-- 伤害计算时效果的发动条件：进行战斗的怪兽中有一方是自己场上除这张卡以外的「恐龙摔跤手」怪兽，且对方怪兽的攻击力在自己怪兽的攻击力以上
function c54446813.btcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前进行战斗的攻击怪兽
	local tc=Duel.GetAttacker()
	-- 如果攻击怪兽是对方的，则将tc指向被攻击的自己怪兽
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	if not tc then return false end
	local bc=tc:GetBattleTarget()
	e:SetLabelObject(tc)
	return tc:IsControler(tp) and tc:IsSetCard(0x11a) and tc~=e:GetHandler() and bc and bc:IsAttackAbove(tc:GetAttack())
end
-- 伤害计算时效果的发动代价：把手卡·场上的这张卡送去墓地
function c54446813.btcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将自身送去墓地
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 伤害计算时效果的处理：使进行战斗的自己怪兽不会被那次战斗破坏，且那次战斗发生的对自己的战斗伤害变成一半
function c54446813.btop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if tc:IsRelateToBattle() then
		-- 那只自己怪兽不会被那次战斗破坏
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE)
		tc:RegisterEffect(e1)
	end
	-- 那次战斗发生的对自己的战斗伤害变成一半。②：对方怪兽的攻击宣言时把墓地的这张卡除外才能发动。从卡组把「恐龙摔跤手·武术葡萄园龙」以外的1只「恐龙摔跤手」怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,0)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
	-- 注册使玩家受到的战斗伤害减半的全局效果
	Duel.RegisterEffect(e2,tp)
end
-- 检索效果的发动条件：对方怪兽进行攻击宣言时
function c54446813.thcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查攻击怪兽是否由对方玩家控制
	return Duel.GetAttacker():IsControler(1-tp)
end
-- 过滤条件：卡组中「恐龙摔跤手·武术葡萄园龙」以外的1只「恐龙摔跤手」怪兽
function c54446813.thfilter(c)
	return c:IsSetCard(0x11a) and c:IsType(TYPE_MONSTER) and not c:IsCode(54446813) and c:IsAbleToHand()
end
-- 检索效果的发动准备：检查卡组中是否存在符合条件的怪兽，并设置检索的操作信息
function c54446813.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查卡组中是否存在「恐龙摔跤手·武术葡萄园龙」以外的「恐龙摔跤手」怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c54446813.thfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 设置将卡组的1张卡加入手卡的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
end
-- 检索效果的处理：从卡组选择1只「恐龙摔跤手·武术葡萄园龙」以外的「恐龙摔跤手」怪兽加入手卡并给对方确认
function c54446813.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组中选择1张符合过滤条件的卡
	local g=Duel.SelectMatchingCard(tp,c54446813.thfilter,tp,LOCATION_DECK,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入手牌
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 向对方玩家展示加入手牌的卡
		Duel.ConfirmCards(1-tp,g)
	end
end
