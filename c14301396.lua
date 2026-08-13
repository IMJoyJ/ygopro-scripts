--H－C マグナム・エクスカリバー
-- 效果：
-- 战士族4星怪兽×2
-- ①：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成2倍。
-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只其他的表侧表示怪兽为对象才能发动。自己场上的这张卡当作攻击力·守备力上升2000的装备魔法卡使用给作为对象的怪兽装备。
-- ③：把墓地的这张卡除外才能发动。从自己墓地让3只战士族怪兽回到卡组。
local s,id,o=GetID()
-- 给此卡添加超量召唤手续（战士族4星怪兽×2）与苏生限制，并注册三个效果：①伤害计算时取除2个超量素材使攻击力变为2倍；②主要阶段取对象装备并提升攻守2000；③除外自身将墓地3只战士族怪兽回卡组。
function s.initial_effect(c)
	-- 添加超量召唤手续：将2只战士族4星怪兽叠放进行超量召唤。
	aux.AddXyzProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_WARRIOR),4,2)
	c:EnableReviveLimit()
	-- ①：这张卡和对方怪兽进行战斗的伤害计算时，把这张卡2个超量素材取除才能发动。这张卡的攻击力只在那次伤害计算时变成2倍。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"攻击力变成2倍"
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.atkcon)
	e1:SetCost(s.atkcost)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己·对方的主要阶段，以自己场上1只其他的表侧表示怪兽为对象才能发动。自己场上的这张卡当作攻击力·守备力上升2000的装备魔法卡使用给作为对象的怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))  --"当作装备卡"
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_MAIN_END)
	e2:SetCountLimit(1)
	e2:SetCondition(s.eqcon)
	e2:SetTarget(s.eqtg)
	e2:SetOperation(s.eqop)
	c:RegisterEffect(e2)
	-- ③：把墓地的这张卡除外才能发动。从自己墓地让3只战士族怪兽回到卡组。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,2))  --"回到卡组"
	e3:SetCategory(CATEGORY_TODECK)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	-- 设置③效果的发动代价：将墓地的这张卡除外。
	e3:SetCost(aux.bfgcost)
	e3:SetTarget(s.tdtg)
	e3:SetOperation(s.tdop)
	c:RegisterEffect(e3)
end
-- ①效果的发动条件：这张卡正与对方怪兽进行战斗（存在战斗对象），也就是在和对方怪兽进行伤害计算时才能发动。
function s.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()~=nil
end
-- ①效果的发动代价：取除此卡的2个超量素材；同时确认本伤害计算阶段内未发动过此效果，取除素材后设置标记，防止同一次伤害计算中重复发动，标记在伤害计算阶段结束时重置。
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:CheckRemoveOverlayCard(tp,2,REASON_COST) and c:GetFlagEffect(id)==0 end
	c:RemoveOverlayCard(tp,2,2,REASON_COST)
	c:RegisterFlagEffect(id,RESET_PHASE+PHASE_DAMAGE_CAL,0,1)
end
-- ①效果处理：若此卡仍在场上且表侧表示，则将其当前攻击力变为2倍，该变化持续到本次伤害计算阶段结束。
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToChain() and c:IsFaceup() then
		local atk=c:GetAttack()
		-- 这张卡的攻击力只在那次伤害计算时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_DAMAGE_CAL)
		e1:SetValue(atk*2)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：当前是主要阶段（自己或对方的主要阶段均可）。
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前是否为主要阶段，作为②效果的发动条件。
	return Duel.IsMainPhase()
end
-- 对象选择过滤条件：选择自己场上表侧表示的其他怪兽（不能选择此卡自身）。
function s.eqfilter(c)
	return c:IsFaceup()
end
-- ②效果发动时：检查自己魔陷区是否有空位，且场上存在符合条件的表侧表示其他怪兽；连锁处理中若收到对象，则验证该对象是自己操控的表侧表示怪兽且不是此卡自身。
function s.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.eqfilter(chkc) and e:GetHandler()~=chkc end
	-- 检查自己魔陷区是否有空位，以确保能将此卡装备给对象。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查自己场上是否存在表侧表示的其他怪兽可作为装备对象（此卡自身除外）。
		and Duel.IsExistingTarget(s.eqfilter,tp,LOCATION_MZONE,0,1,e:GetHandler()) end
	-- 给当前玩家显示“请选择效果的对象”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)  --"请选择效果的对象"
	-- 从自己场上选择1只表侧表示的其他怪兽作为效果对象，并记录为连锁对象。
	Duel.SelectTarget(tp,s.eqfilter,tp,LOCATION_MZONE,0,1,1,e:GetHandler())
	-- 登记操作信息：本效果处理时将进行“装备”处理，装备卡为这张卡自身。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- ②效果处理：若此卡仍关联且表侧表示，且还有魔陷区空位、对象合法，则将此卡作为装备卡装备给对象，并赋予“只能装备给该对象”的限制以及攻击力·守备力各上升2000；若装备无法进行则此卡因规则送去墓地。
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取此效果发动时选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToChain() and c:IsFaceup() and c:IsControler(tp) then
		-- 检查自己魔陷区是否已没有可用空位（空位不足则装备无法进行）。
		if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0
			or tc:IsFacedown() or not tc:IsRelateToChain() or not tc:IsLocation(LOCATION_MZONE) then
			-- 因装备条件不满足，根据规则将这张卡送去墓地。
			Duel.SendtoGrave(c,REASON_RULE)
			return
		end
		-- 尝试将此卡装备给对象；若装备失败则直接结束效果处理。
		if not Duel.Equip(tp,c,tc) then return end
		-- 给作为对象的怪兽装备（此装备限制确保只能装备给发动时选择的对象）。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetLabelObject(tc)
		e1:SetValue(s.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		-- 攻击力·守备力上升2000（此处实现让这张卡作为装备卡时提升攻击力2000）。
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(2000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
	end
end
-- 装备限制判定：此卡只能装备给发动时选择的对象怪兽（通过LabelObject记录）。
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
-- ③效果的过滤条件：选择自己墓地的战士族怪兽（且为怪兽卡、能够回到卡组）。
function s.tdfilter(c)
	return c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck()
end
-- ③效果发动时：检查自己墓地是否存在至少3只符合条件的战士族怪兽，并登记操作信息：将3张卡返回卡组。
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己墓地中是否存在至少3只符合条件的战士族怪兽，满足才可发动。
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,LOCATION_GRAVE,0,3,e:GetHandler()) end
	-- 登记操作信息：此效果处理时从墓地选3只战士族怪兽返回卡组。
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,3,tp,LOCATION_GRAVE)
end
-- ③效果处理：再次确认墓地符合条件的战士族怪兽不少于3只；然后让玩家从自己墓地选择3只符合条件的战士族怪兽（考虑王家长眠之谷的影响）返回卡组，并洗切。
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时若自己墓地符合条件战士族怪兽不足3只，则效果不处理。
	if Duel.GetMatchingGroupCount(s.tdfilter,tp,LOCATION_GRAVE,0,nil)<3 then return end
	-- 给玩家显示“请选择要返回卡组的卡”的提示信息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)  --"请选择要返回卡组的卡"
	-- 从自己墓地选择3只符合条件的战士族怪兽（过滤时带王家长眠之谷抗性检查），作为返回卡组的对象。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.tdfilter),tp,LOCATION_GRAVE,0,3,3,nil)
	if g:GetCount()>0 then
		-- 为选中的卡显示被选中动画，并记录这些卡为效果对象。
		Duel.HintSelection(g)
		-- 将选择的战士族怪兽返回其持有者的卡组，然后洗切卡组。
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
