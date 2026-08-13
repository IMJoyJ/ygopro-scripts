--灰滅せし成れの果て
-- 效果：
-- 炎族怪兽×2
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡融合召唤的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
-- ②：这张卡和对方的炎族怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。这个效果在自己回合发动的场合，这张卡只再1次可以继续攻击。
local s,id,o=GetID()
-- 为「灰灭堕变者」注册基础设定：解除苏生限制、设定融合素材为2只炎族怪兽，并创建注册①效果（融合召唤成功时回收墓地场地魔法卡）和②效果（与对方炎族怪兽战斗时破坏并追加攻击），两个效果均设为1回合1次（对应卡名①②效果的限制）。
function s.initial_effect(c)
	c:EnableReviveLimit()
	-- 设定这张卡以2只炎族怪兽为融合素材进行融合召唤，为这张卡添加该融合召唤手续。
	aux.AddFusionProcFunRep(c,aux.FilterBoolFunction(Card.IsRace,RACE_PYRO),2,true)
	-- 这个卡名的①②的效果1回合各能使用1次。①：这张卡融合召唤的场合，以自己墓地1张场地魔法卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：这张卡和对方的炎族怪兽进行战斗的伤害步骤开始时才能发动。那只对方怪兽破坏。这个效果在自己回合发动的场合，这张卡只再1次可以继续攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_START)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.descon)
	e2:SetTarget(s.destg)
	e2:SetOperation(s.desop)
	c:RegisterEffect(e2)
end
-- ②效果的发动条件判定：本卡与对方炎族怪兽进行战斗且该战斗对象仍与战斗关联，同时将该战斗对象暂存至效果标签中。
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	e:SetLabelObject(bc)
	return bc and bc:IsControler(1-tp) and bc:IsRelateToBattle() and bc:IsRace(RACE_PYRO)
end
-- ②效果的发动目标检测：确认存在刚才暂存的战斗对象（即要破坏的对方怪兽），并在发动前声明破坏该对象。
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local bc=e:GetLabelObject()
	if chk==0 then return bc end
	-- 向连锁系统登记本次效果将破坏的对象及数量，用于后续其他与破坏相关的效果联动判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,bc,1,0,0)
end
-- ②效果处理：若战斗对象仍关联、是怪兽且仍由对方控制，则将其破坏；并在自己回合时进一步判断是否追加攻击。
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=e:GetHandler():GetBattleTarget()
	if bc:IsRelateToBattle() and bc:IsType(TYPE_MONSTER) and bc:IsControler(1-tp) then
		-- 以效果原因将该对方怪兽破坏，实际执行破坏操作。
		Duel.Destroy(bc,REASON_EFFECT)
	end
	-- 判定追加攻击条件：当前为自己的回合、此卡仍与效果关联且此卡尚未失去可攻击资格（未被多次攻击限制）。
	if Duel.GetTurnPlayer()==tp and c:IsRelateToEffect(e) and c:IsChainAttackable() then
		-- 使此卡可以再进行一次攻击宣言。
		Duel.ChainAttack()
	end
end
-- ①效果发动条件：此卡特殊召唤成功且召唤方式为融合召唤。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
-- ①效果的对象筛选：选择自己墓地中1张场地魔法卡且能够加入手卡的卡。
function s.thfilter(c,tp)
	return c:IsType(TYPE_FIELD) and c:IsAbleToHand()
end
-- ①效果发动时的目标选择：从自己墓地选择1张符合条件的场地魔法卡作为对象，并登记回手牌的操作信息。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	-- 在效果发动合法性检查时，确认自己墓地存在至少1张符合条件的场地魔法卡，否则不能发动。
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 发出选择提示，提示玩家选择要加入手卡的那张墓地场地魔法卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 玩家选择自己墓地1张符合条件的场地魔法卡，并将其设为效果对象。
	local sg=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 向连锁系统登记本次效果将把对象卡加入手卡的信息。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,sg,1,0,0)
end
-- ①效果处理：取得效果对象，若该卡仍与效果关联，则将其加入手卡。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得①效果发动时选择的对象卡（墓地的那张场地魔法卡）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 以效果原因将对象卡送去持有者手卡。
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
