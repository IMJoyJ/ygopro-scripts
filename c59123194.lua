--覚醒の魔導剣士
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 「觉醒之魔导剑士」的①的效果1回合只能使用1次。
-- ①：「魔术师」灵摆怪兽作为素材让这张卡同调召唤成功的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
function c59123194.initial_effect(c)
	-- 添加同调召唤手续：调整+调整以外的怪兽1只以上
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 「觉醒之魔导剑士」的①的效果1回合只能使用1次。①：「魔术师」灵摆怪兽作为素材让这张卡同调召唤成功的场合，以自己墓地1张魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,59123194)
	e1:SetCondition(c59123194.thcon)
	e1:SetTarget(c59123194.thtg)
	e1:SetOperation(c59123194.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡战斗破坏对方怪兽时才能发动。给与对方那只怪兽的原本攻击力数值的伤害。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	-- 设置发动条件：自身战斗破坏对方怪兽并送去墓地
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c59123194.damtg)
	e2:SetOperation(c59123194.damop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自身同调召唤成功，且同调素材中存在「魔术师」灵摆怪兽
function c59123194.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetMaterial():IsExists(c59123194.pmfilter,1,nil)
end
-- 过滤条件：墓地的魔法卡且能加入手卡
function c59123194.thfilter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToHand()
end
-- 过滤条件：「魔术师」灵摆怪兽
function c59123194.pmfilter(c)
	return c:IsSetCard(0x98) and c:IsType(TYPE_PENDULUM)
end
-- 效果①的发动准备：选择自己墓地1张魔法卡作为对象
function c59123194.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c59123194.thfilter(chkc) end
	-- 检测自己墓地是否存在符合条件的魔法卡
	if chk==0 then return Duel.IsExistingTarget(c59123194.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要加入手牌的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 选择并锁定自己墓地1张符合条件的魔法卡作为效果对象
	local g=Duel.SelectTarget(tp,c59123194.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将选中的卡加入手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的效果处理：将作为对象的魔法卡加入手卡
function c59123194.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果对象（即选中的魔法卡）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片加入手卡
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动准备：获取被破坏怪兽的原本攻击力并设置伤害参数
function c59123194.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetHandler():GetBattleTarget()
	local dam=bc:GetTextAttack()
	if chk==0 then return dam>0 end
	-- 将战斗破坏的怪兽设为效果目标卡
	Duel.SetTargetCard(bc)
	-- 设置伤害的目标玩家为对方玩家
	Duel.SetTargetPlayer(1-tp)
	-- 设置伤害数值为该怪兽的原本攻击力
	Duel.SetTargetParam(dam)
	-- 设置操作信息：给与对方玩家对应数值的伤害
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
-- 效果②的效果处理：给与对方该怪兽原本攻击力数值的伤害
function c59123194.damop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果目标卡（即被战斗破坏的怪兽）
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 获取目标玩家（对方玩家）
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=tc:GetTextAttack()
		if dam<0 then dam=0 end
		-- 给与目标玩家对应数值的伤害
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
