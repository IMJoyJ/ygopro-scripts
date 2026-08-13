--アームド・ドラゴン LV5
-- 效果：
-- ①：从手卡把1只怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。持有为这个效果发动而送去墓地的怪兽的攻击力以下的攻击力的作为对象的对方怪兽破坏。
-- ②：这张卡战斗破坏怪兽的回合的结束阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV7」特殊召唤。
function c46384672.initial_effect(c)
	-- 这张卡战斗破坏怪兽的回合
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLE_DESTROYING)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(c46384672.bdop)
	c:RegisterEffect(e1)
	-- ①：从手卡把1只怪兽送去墓地，以对方场上1只表侧表示怪兽为对象才能发动。持有为这个效果发动而送去墓地的怪兽的攻击力以下的攻击力的作为对象的对方怪兽破坏。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(46384672,0))  --"破坏"
	e2:SetCategory(CATEGORY_DESTROY)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c46384672.descost)
	e2:SetTarget(c46384672.destg)
	e2:SetOperation(c46384672.desop)
	c:RegisterEffect(e2)
	-- ②：这张卡战斗破坏怪兽的回合的结束阶段，把场上的这张卡送去墓地才能发动。从手卡·卡组把1只「武装龙 LV7」特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(46384672,1))  --"特殊召唤"
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCondition(c46384672.spcon)
	e3:SetCost(c46384672.spcost)
	e3:SetTarget(c46384672.sptg)
	e3:SetOperation(c46384672.spop)
	c:RegisterEffect(e3)
end
c46384672.lvup={73879377}
c46384672.lvdn={980973}
-- 当这张卡战斗破坏怪兽送去墓地时，给自身注册一个标志，记录该回合已战斗破坏过怪兽，该标志在回合结束阶段或离场等条件下重置，用于②效果的发动条件判断。
function c46384672.bdop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(46384672,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
end
-- cost用怪兽的过滤器：手牌中满足是怪兽卡、可作为cost送入墓地，且对方场上有表侧表示怪兽攻击力不大于该怪兽攻击力的对象可选择，保证发动①时至少存在可破坏目标。
function c46384672.cfilter(c,tp)
	local atk=c:GetAttack()
	if atk<0 then atk=0 end
	return c:IsType(TYPE_MONSTER) and c:IsAbleToGraveAsCost()
		-- 进一步确认对方场上存在表侧表示且攻击力不超过atk的怪兽，可作为①效果取对象破坏的目标。
		and Duel.IsExistingTarget(c46384672.dfilter,tp,0,LOCATION_MZONE,1,nil,atk)
end
-- 破坏对象的过滤器：目标必须表侧表示，且当前攻击力不超过作为cost送入墓地的怪兽的攻击力。
function c46384672.dfilter(c,atk)
	return c:IsFaceup() and c:GetAttack()<=atk
end
-- ①效果的cost处理：玩家从手牌选择1只怪兽作为cost送入墓地，并将其攻击力记录到效果标签中，作为后续选择破坏对象的攻击力上限；若没有可选择的怪兽则不能发动。
function c46384672.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- cost合法性检查：确认手牌中存在可作为cost送入墓地、且对方场上有符合条件的怪兽可供①效果选为对象的情况。
	if chk==0 then return Duel.IsExistingMatchingCard(c46384672.cfilter,tp,LOCATION_HAND,0,1,nil,tp) end
	-- 弹出选择提示，让玩家选择要作为cost送去墓地的手牌怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	-- 从手牌选择1只满足条件的怪兽作为①效果的发动cost。
	local g=Duel.SelectMatchingCard(tp,c46384672.cfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local atk=g:GetFirst():GetAttack()
	if atk<0 then atk=0 end
	e:SetLabel(atk)
	-- 将选中的手牌怪兽以cost形式送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ①效果的取对象处理：从对方场上选择1只表侧表示且攻击力不超过记录值的怪兽作为对象，并设定即将破坏该对象的操作信息。
function c46384672.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) and c46384672.dfilter(chkc,e:GetLabel()) end
	if chk==0 then return true end
	-- 弹出选择提示，让玩家选择要破坏的对方怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 从对方场上选择1只满足表侧表示且攻击力不超过记录的cost怪兽攻击力的怪兽作为效果对象，并自动与当前效果建立关联。
	local g=Duel.SelectTarget(tp,c46384672.dfilter,tp,0,LOCATION_MZONE,1,1,nil,e:GetLabel())
	-- 设置连锁操作信息：本连锁包含破坏1只对象怪兽的效果，供其他卡（如星尘龙等）进行连锁判定。
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- ①效果处理：取得取对象阶段选择的目标，若其仍在对方场上、表侧表示、与效果关联且攻击力不高于记录的cost怪兽攻击力，则将其破坏。
function c46384672.desop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取①效果处理时锁定的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:GetAttack()<=e:GetLabel() and tc:IsControler(1-tp) then
		-- 用效果破坏该对象怪兽。
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
-- ②效果的发动条件：检查自身是否带有之前战斗破坏怪兽时设置的标记（即本回合战斗破坏过怪兽）。
function c46384672.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetFlagEffect(46384672)>0
end
-- ②效果的cost处理：将场上的这张卡自身送去墓地作为发动代价；若自身不能送去墓地则不能发动。
function c46384672.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() end
	-- 将这张卡自身以cost形式送去墓地。
	Duel.SendtoGrave(e:GetHandler(),REASON_COST)
end
-- 特殊召唤对象的过滤器：限定为「武装龙 LV7」（卡号73879377），并允许无视苏生限制、召唤条件进行特殊召唤。
function c46384672.spfilter(c,e,tp)
	return c:IsCode(73879377) and c:IsCanBeSpecialSummoned(e,0,tp,true,true)
end
-- ②效果的发动目标检查：判断自己场上是否有可供特殊召唤的空位（由于自身将作为cost送墓，可接受当前无空位），且手牌·卡组中存在可特殊召唤的「武装龙 LV7」。
function c46384672.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己主要怪兽区空位数量是否>-1，即考虑到自身cost送墓后会空出1个格子，所以最低允许当前没有空位也能发动。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>-1
		-- 确认手牌或卡组中存在满足特殊召唤条件的「武装龙 LV7」，以保证效果处理时有卡可特殊召唤。
		and Duel.IsExistingMatchingCard(c46384672.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,nil,e,tp) end
	-- 设置操作信息：本连锁效果为从手牌·卡组特殊召唤1只怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_DECK)
end
-- ②效果处理：从手牌·卡组将1只「武装龙 LV7」特殊召唤到自己的主要怪兽区，并完成其特殊召唤手续。
function c46384672.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时再次检查自己场上是否有可用怪兽区，若没有空位则直接终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 弹出选择提示，让玩家选择要特殊召唤的「武装龙 LV7」。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从手牌·卡组选择1只满足条件的「武装龙 LV7」准备特殊召唤。
	local g=Duel.SelectMatchingCard(tp,c46384672.spfilter,tp,LOCATION_HAND+LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		-- 将选择的「武装龙 LV7」以表侧攻击表示特殊召唤到场上（无视召唤条件与苏生限制）。
		Duel.SpecialSummon(tc,0,tp,tp,true,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
