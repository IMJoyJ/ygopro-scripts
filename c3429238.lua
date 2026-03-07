--ドリル・ウォリアー
-- 效果：
-- 「钻头同调士」＋调整以外的怪兽1只以上
-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力变成一半，这个回合这张卡可以直接攻击对方玩家。此外，1回合1次，自己的主要阶段时才能发动。丢弃1张手卡并把这张卡从游戏中除外。下次的自己的准备阶段时，这个效果除外的这张卡在自己场上特殊召唤。那之后，选自己墓地1只怪兽加入手卡。
function c3429238.initial_effect(c)
	-- 为怪兽添加允许使用的素材代码列表，指定只能使用代码为56286179的卡作为素材
	aux.AddMaterialCodeList(c,56286179)
	-- 添加同调召唤手续，要求1只满足tfilter条件的调整和1只以上调整以外的怪兽作为素材
	aux.AddSynchroProcedure(c,c3429238.tfilter,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- 1回合1次，自己的主要阶段时才能发动。这张卡的攻击力变成一半，这个回合这张卡可以直接攻击对方玩家。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(3429238,0))  --"攻击力变成一半数值"
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(c3429238.datcon)
	e1:SetTarget(c3429238.dattg)
	e1:SetOperation(c3429238.datop)
	c:RegisterEffect(e1)
	-- 1回合1次，自己的主要阶段时才能发动。丢弃1张手卡并把这张卡从游戏中除外。下次的自己的准备阶段时，这个效果除外的这张卡在自己场上特殊召唤。那之后，选自己墓地1只怪兽加入手卡。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(3429238,1))  --"把这张卡从游戏中除外"
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(c3429238.rmtg)
	e2:SetOperation(c3429238.rmop)
	c:RegisterEffect(e2)
	-- 下次的自己的准备阶段时，这个效果除外的这张卡在自己场上特殊召唤。那之后，选自己墓地1只怪兽加入手卡。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(3429238,2))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e3:SetRange(LOCATION_REMOVED)
	e3:SetCondition(c3429238.spcon)
	e3:SetTarget(c3429238.sptg)
	e3:SetOperation(c3429238.spop)
	c:RegisterEffect(e3)
end
c3429238.material_setcode=0x1017
-- 用于判断是否为钻头同调士或具有相同效果的卡
function c3429238.tfilter(c)
	return c:IsCode(56286179) or c:IsHasEffect(20932152)
end
-- 判断是否处于自己的主要阶段1且可以进行战斗相关操作
function c3429238.datcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前阶段为第一主要阶段且满足战斗条件
	return Duel.GetCurrentPhase()==PHASE_MAIN1 and aux.bpcon(e,tp,eg,ep,ev,re,r,rp)
end
-- 设置发动效果时的提示信息
function c3429238.dattg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
end
-- 将该怪兽的攻击力变为一半，使其可以在本回合直接攻击对方玩家
function c3429238.datop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 将该怪兽的攻击力设置为当前攻击力的一半
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(math.ceil(c:GetAttack()/2))
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 使该怪兽在本回合可以直接攻击对方玩家
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_DIRECT_ATTACK)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
end
-- 设置发动除外效果时的提示信息
function c3429238.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查手牌数量是否大于0且该怪兽可以被除外
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 and e:GetHandler():IsAbleToRemove() end
	-- 向对方玩家提示发动了效果
	Duel.Hint(HINT_OPSELECTED,1-tp,e:GetDescription())
	-- 设置操作信息，表示将要除外该怪兽
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,e:GetHandler(),1,0,0)
end
-- 执行除外效果，丢弃一张手牌并将该怪兽除外
function c3429238.rmop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要丢弃的手牌
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)  --"请选择要丢弃的手牌"
	-- 选择1张手牌丢弃
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_HAND,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的手牌送入墓地
		Duel.SendtoGrave(g,REASON_EFFECT+REASON_DISCARD)
		-- 判断该怪兽是否可以被除外并执行除外操作
		if c:IsRelateToEffect(e) and Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_EFFECT)~=0 then
			e:GetHandler():RegisterFlagEffect(3429238,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,0,1)
		end
	end
end
-- 判断是否轮到该玩家的准备阶段
function c3429238.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 当前轮到该玩家的准备阶段
	return Duel.GetTurnPlayer()==tp
end
-- 设置特殊召唤效果的提示信息
function c3429238.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():GetFlagEffect(3429238)~=0 end
	e:GetHandler():ResetFlagEffect(3429238)
	-- 设置操作信息，表示将要特殊召唤该怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 用于过滤墓地中可加入手牌的怪兽
function c3429238.filter(c)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToHand()
end
-- 执行特殊召唤并从墓地选1只怪兽加入手牌
function c3429238.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取墓地中所有可加入手牌的怪兽
	local tg=Duel.GetMatchingGroup(c3429238.filter,tp,LOCATION_GRAVE,0,nil)
	-- 检查是否受到王家长眠之谷的影响
	if aux.NecroValleyNegateCheck(tg) then return end
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) then return end
	-- 将该怪兽特殊召唤到场上
	if Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)~=0 then
		-- 中断当前效果处理
		Duel.BreakEffect()
		-- 提示玩家选择要加入手牌的卡
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
		local g=tg:Select(tp,1,1,nil)
		if g:GetCount()>0 then
			-- 将选中的卡加入手牌
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			-- 向对方玩家确认加入手牌的卡
			Duel.ConfirmCards(1-tp,g)
		end
	end
end
