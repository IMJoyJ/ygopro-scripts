--クリベー
-- 效果：
-- 这个卡名在规则上也当作「栗子球」卡使用。
-- ①：把这张卡从手卡丢弃，以自己场上1只「栗子球」怪兽为对象才能发动。那只怪兽的攻击力上升1500。这个效果在对方回合也能发动。
-- ②：把场上的这张卡和自己的手卡·场上的「栗子丸」「栗子团」「栗子圆」「栗子球」各1只解放才能发动。从自己的卡组·墓地选1只「盗贼栗子」加入手卡。那之后，可以从手卡把1只恶魔族怪兽召唤。
function c34419588.initial_effect(c)
	-- 记录这张卡的文本中记述的卡名（栗子丸、栗子团、栗子圆、栗子球），用于相关判定。
	aux.AddCodeList(c,44632120,71036835,7021574,40640057)
	-- ①：把这张卡从手卡丢弃，以自己场上1只「栗子球」怪兽为对象才能发动。那只怪兽的攻击力上升1500。这个效果在对方回合也能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(34419588,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(TIMING_DAMAGE_STEP)
	-- 设置效果发动条件：伤害步骤中仅在伤害计算前可以发动（配合可在对方回合发动的即时效果）。
	e1:SetCondition(aux.dscon)
	e1:SetCost(c34419588.atkcost)
	e1:SetTarget(c34419588.atktg)
	e1:SetOperation(c34419588.atkop)
	c:RegisterEffect(e1)
	-- ②：把场上的这张卡和自己的手卡·场上的「栗子丸」「栗子团」「栗子圆」「栗子球」各1只解放才能发动。从自己的卡组·墓地选1只「盗贼栗子」加入手卡。那之后，可以从手卡把1只恶魔族怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(34419588,1))
	e3:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_SUMMON)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCost(c34419588.thcost)
	e3:SetTarget(c34419588.thtg)
	e3:SetOperation(c34419588.thop)
	c:RegisterEffect(e3)
end
-- 生成一组检查函数，分别用于验证卡片是否为「栗子丸」「栗子团」「栗子圆」「栗子球」，确保在解放素材时四者各选1张。
c34419588.spchecks=aux.CreateChecks(Card.IsCode,{44632120,71036835,7021574,40640057})
-- 效果①的代价函数：确认手卡中的这张卡可以丢弃，然后将其作为代价送去墓地。
function c34419588.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsDiscardable() end
	-- 将这张卡从手卡丢弃到墓地，作为效果的发动代价（COST+丢弃）。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST+REASON_DISCARD)
end
-- 定义效果①的对象筛选条件：自己场上的表侧表示怪兽，且卡名属于「栗子球」系列（字段0xa4）。
function c34419588.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xa4)
end
-- 效果①的目标选择：从自己场上选择1只符合条件的「栗子球」怪兽作为对象，并进行取对象合法性检查。
function c34419588.atktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c34419588.atkfilter(chkc) end
	-- 发动合法性判定：确认自己场上存在至少1只可被选择为对象的表侧「栗子球」怪兽。
	if chk==0 then return Duel.IsExistingTarget(c34419588.atkfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 向玩家发送选择目标卡的提示消息（“请选择效果的对象”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 让玩家从自己场上选择1只符合条件的「栗子球」怪兽，并登记为当前连锁的效果对象。
	Duel.SelectTarget(tp,c34419588.atkfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 效果①处理：取得对象怪兽，若其仍与效果相关且表侧表示，则赋予它攻击力上升1500的效果。
function c34419588.atkop(e,tp,eg,ep,ev,re,r,rp)
	-- 取得效果对象卡（被选择的「栗子球」怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 那只怪兽的攻击力上升1500。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(1500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
-- 定义效果②的解放素材筛选条件：卡为「栗子丸」「栗子团」「栗子圆」「栗子球」之一，并且是己方控制或表侧表示（手卡中的这类卡也可作为素材）。
function c34419588.rlfilter(c,tp)
	return c:IsCode(44632120,71036835,7021574,40640057) and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查选定的解放素材加上这张卡后：解放后自己仍有空闲怪兽区，且这些卡能够作为解放代价被解放。
function c34419588.rlcheck(sg,c,tp)
	local g=sg:Clone()
	g:AddCard(c)
	-- 确认这些卡作为解放代价时，自己场上仍有可用怪兽区；并且这些卡均可被解放。
	return Duel.GetMZoneCount(tp,g)>0 and Duel.CheckReleaseGroupEx(tp,aux.IsInGroup,#g,REASON_COST,true,nil,g)
end
-- 效果②的代价：选择场上的这张卡以及自己手卡·场上的「栗子丸」「栗子团」「栗子圆」「栗子球」各1只，将其解放。
function c34419588.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 获取己方可解放的卡（包含手卡），并筛选出可作为素材的「栗子丸」「栗子团」「栗子圆」「栗子球」作为候选组。
	local g=Duel.GetReleaseGroup(tp,true):Filter(c34419588.rlfilter,c,tp)
	if chk==0 then return c:IsReleasable() and g:CheckSubGroupEach(c34419588.spchecks,c34419588.rlcheck,c,tp) end
	-- 提示玩家选择要解放的卡（“请选择要解放的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local rg=g:SelectSubGroupEach(tp,c34419588.spchecks,false,c34419588.rlcheck,c,tp)
	-- 消耗所选解放素材中带有的特殊追加解放次数效果（如暗影敌托邦等），确保解放手续合法。
	aux.UseExtraReleaseCount(rg,tp)
	rg:AddCard(c)
	-- 将选定的素材和这张卡解放，作为发动代价。
	Duel.Release(rg,REASON_COST)
end
-- 定义检索目标：卡名为「盗贼栗子」，且能够被加入手卡。
function c34419588.thfilter(c)
	return c:IsCode(16404809) and c:IsAbleToHand()
end
-- 效果②的目标设置：确认卡组·墓地有「盗贼栗子」，并登记加入手卡与追加召唤的操作信息。
function c34419588.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性判定：确认自己卡组·墓地存在至少1张「盗贼栗子」。
	if chk==0 then return Duel.IsExistingMatchingCard(c34419588.thfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil) end
	-- 登记“将1张卡从卡组·墓地加入手卡”的操作信息（用于连锁判定）。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	-- 登记“之后可以从手卡进行1次通常召唤”的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND)
end
-- 定义追加召唤的对象条件：手卡中的恶魔族怪兽，且当前可以进行不消耗通常召唤权的通常召唤。
function c34419588.sumfilter(c)
	return c:IsSummonable(true,nil) and c:IsRace(RACE_FIEND)
end
-- 效果②处理：从卡组·墓地选1只「盗贼栗子」加入手卡并给对方确认；之后询问玩家是否从手卡召唤1只恶魔族怪兽，若同意则进行召唤。
function c34419588.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择要加入手牌的卡（“请选择要加入手牌的卡”）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从卡组·墓地选择1张「盗贼栗子」（过滤掉受王家长眠之谷影响而无法加入手卡的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(c34419588.thfilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil)
	-- 若成功选择到检索卡且加入手卡成功，则继续执行后续召唤处理。
	if g:GetCount()>0 and Duel.SendtoHand(g,nil,REASON_EFFECT)>0 then
		-- 将加入手卡的「盗贼栗子」展示给对方确认。
		Duel.ConfirmCards(1-tp,g)
		-- 检查手卡中是否存在可召唤的恶魔族怪兽，作为是否询问追加召唤的条件。
		if Duel.IsExistingMatchingCard(c34419588.sumfilter,tp,LOCATION_HAND,0,1,nil)
			-- 若存在可召唤的恶魔族怪兽，则询问玩家“是否把恶魔族怪兽召唤？”。
			and Duel.SelectYesNo(tp,aux.Stringid(34419588,2)) then  --"是否把恶魔族怪兽召唤？"
			-- 中断当前效果处理，使后续召唤在独立时点结算（避免错失时点）。
			Duel.BreakEffect()
			-- 提示玩家选择要召唤的卡（“请选择要召唤的卡”）。
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)  --"请选择要召唤的卡"
			-- 从手卡选择1只符合条件的恶魔族怪兽，准备进行召唤。
			local sg=Duel.SelectMatchingCard(tp,c34419588.sumfilter,tp,LOCATION_HAND,0,1,1,nil)
			if sg:GetCount()>0 then
				local tc=sg:GetFirst()
				-- 以效果进行通常召唤，忽略每回合通常召唤次数限制。
				Duel.Summon(tp,tc,true,nil)
			end
		end
	end
end
