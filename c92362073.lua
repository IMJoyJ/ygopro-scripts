--銀河衛竜
-- 效果：
-- 龙族怪兽2只
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：自己·对方的战斗阶段，把场上·墓地的这张卡除外，以自己场上1只原本的种族·属性是龙族·光属性的「No.」超量怪兽为对象才能发动。直到战斗阶段结束时，对方受到的战斗伤害变成一半，作为对象的怪兽的攻击力变成那只怪兽持有的「No.」数值×100。
-- ②：对方结束阶段才能发动。从卡组选1张卡在卡组最上面放置。
function c92362073.initial_effect(c)
	c:EnableReviveLimit()
	-- 设置连接召唤的手续，需要2只龙族怪兽作为连接素材
	aux.AddLinkProcedure(c,aux.FilterBoolFunction(Card.IsLinkRace,RACE_DRAGON),2,2)
	-- ①：自己·对方的战斗阶段，把场上·墓地的这张卡除外，以自己场上1只原本的种族·属性是龙族·光属性的「No.」超量怪兽为对象才能发动。直到战斗阶段结束时，对方受到的战斗伤害变成一半，作为对象的怪兽的攻击力变成那只怪兽持有的「No.」数值×100。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(92362073,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_GRAVE+LOCATION_MZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,92362073)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	e1:SetCondition(c92362073.atkcon)
	-- 把场上·墓地的这张卡除外作为效果发动的cost
	e1:SetCost(aux.bfgcost)
	e1:SetTarget(c92362073.atktg)
	e1:SetOperation(c92362073.atkop)
	c:RegisterEffect(e1)
	-- ②：对方结束阶段才能发动。从卡组选1张卡在卡组最上面放置。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92362073,1))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCountLimit(1,92362074)
	e2:SetCondition(c92362073.tpcon)
	e2:SetTarget(c92362073.tptg)
	e2:SetOperation(c92362073.tpop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：自己或对方的战斗阶段
function c92362073.atkcon(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前的阶段
	local ph=Duel.GetCurrentPhase()
	return ph>=PHASE_BATTLE_START and ph<=PHASE_BATTLE
end
-- 过滤满足“原本的种族·属性是龙族·光属性的「No.」超量怪兽”且在场上表侧表示的卡片
function c92362073.atkfilter(c)
	-- 获取该怪兽持有的「No.」数值
	local no=aux.GetXyzNumber(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ) and c:IsSetCard(0x48) and no
		and c:GetOriginalAttribute()==ATTRIBUTE_LIGHT and c:GetOriginalRace()==RACE_DRAGON
end
-- 效果①的目标选择处理（选择自己场上1只原本是龙族·光属性的「No.」超量怪兽为对象）
function c92362073.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c92362073.atkfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的、原本是龙族·光属性的「No.」超量怪兽
	if chk==0 then return Duel.IsExistingTarget(c92362073.atkfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 提示玩家选择表侧表示的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择自己场上1只原本是龙族·光属性的「No.」超量怪兽作为效果对象
	Duel.SelectTarget(tp,c92362073.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①的效果处理（使对象怪兽攻击力变成其No.数值×100，并使对方受到的战斗伤害变成一半）
function c92362073.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果①选择的对象怪兽
	local tc=Duel.GetFirstTarget()
	-- 获取作为对象的怪兽持有的「No.」数值
	local no=aux.GetXyzNumber(tc)
	if no and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		-- 作为对象的怪兽的攻击力变成那只怪兽持有的「No.」数值×100。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(no*100)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
		tc:RegisterEffect(e1)
	end
	-- 直到战斗阶段结束时，对方受到的战斗伤害变成一半
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(0,1)
	e2:SetValue(HALF_DAMAGE)
	e2:SetReset(RESET_PHASE+PHASE_BATTLE)
	-- 为玩家注册对方受到的战斗伤害变成一半的效果
	Duel.RegisterEffect(e2,tp)
end
-- 效果②的发动条件：对方的结束阶段
function c92362073.tpcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前回合玩家是否不是自己（即判定是否为对方回合）
	return Duel.GetTurnPlayer()~=tp
end
-- 效果②的发动准备与可行性检查（确认卡组中存在至少2张卡）
function c92362073.tptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己卡组中是否存在至少1张卡
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,LOCATION_DECK,0,1,nil)
		-- 并且自己卡组的卡片数量必须大于1张
		and Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>1 end
end
-- 效果②的效果处理（从卡组选1张卡，洗切卡组后放置在卡组最上面）
function c92362073.tpop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要放置在卡组最上面的卡
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(92362073,2))  --"请选择要放置在卡组最上面的卡"
	-- 从卡组中选择任意1张卡
	local g=Duel.SelectMatchingCard(tp,aux.TRUE,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		-- 洗切自己的卡组
		Duel.ShuffleDeck(tp)
		-- 将选择的卡移动到卡组最上面
		Duel.MoveSequence(tc,SEQ_DECKTOP)
	end
end
