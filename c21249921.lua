--ドラグニティナイト－ヴァジュランダ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：这张卡同调召唤时，以自己墓地1只3星以下的龙族「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备魔法卡使用给这张卡装备。
-- ②：1回合1次，把这张卡装备的自己场上1张装备卡送去墓地才能发动。这张卡的攻击力直到回合结束时变成2倍。
function c21249921.initial_effect(c)
	-- 为这张卡添加同调召唤手续：调整必须为龙族，调整以外的怪兽必须为鸟兽族，且数量至少1只。
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以自己墓地1只3星以下的龙族「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(21249921,0))  --"装备"
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c21249921.eqcon)
	e1:SetTarget(c21249921.eqtg)
	e1:SetOperation(c21249921.eqop)
	c:RegisterEffect(e1)
	-- ②：1回合1次，把这张卡装备的自己场上1张装备卡送去墓地才能发动。这张卡的攻击力直到回合结束时变成2倍。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(21249921,1))  --"攻击变化"
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetCountLimit(1)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCost(c21249921.atkcost)
	e2:SetOperation(c21249921.atkop)
	c:RegisterEffect(e2)
end
-- 效果①的发动条件：这张卡是以同调召唤方式特殊召唤成功的场合。
function c21249921.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 选择墓地对象的过滤条件：3星以下、龙族、「龙骑兵团」字段、且不是禁止卡。
function c21249921.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 效果①的发动阶段：若检查已选对象则验证其是否为我方墓地且满足条件；若为发动判定，则检查魔陷区有空位且墓地存在满足条件的对象。
function c21249921.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21249921.filter(chkc) end
	-- 发动效果时（chk==0）检查我方魔陷区是否有空位，以便装备卡能放置。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并确认墓地存在至少1只满足条件的龙族「龙骑兵团」怪兽可以作为对象。
		and Duel.IsExistingTarget(c21249921.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 显示选择提示信息，提示玩家选择要装备的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地选择1只满足条件的龙族「龙骑兵团」怪兽，并将其设为效果对象。
	local g=Duel.SelectTarget(tp,c21249921.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：该效果涉及墓地区的卡离场（CATEGORY_LEAVE_GRAVE），对象为选择的卡，数量1。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果①处理：将选择的对象怪兽作为装备魔法卡装备给这张卡；装备成功后，给该装备卡设置装备限制效果，使其只能装备给本卡。
function c21249921.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果发动时选择的对象卡（墓地那只龙族怪兽）。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 尝试将对象卡作为装备卡装备给这张卡，若装备失败则终止处理。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21249921.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制的值函数：仅允许装备给当前效果的所有者（即本卡），其他怪兽不能装备。
function c21249921.eqlimit(e,c)
	return e:GetOwner()==c
end
-- ②的代价筛选条件：装备卡的控制者为发动者，且可以作为代价送去墓地。
function c21249921.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- ②的代价：从这张卡装备的自己的装备卡中选择1张送去墓地；若没有符合条件的装备卡则不能发动。
function c21249921.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(c21249921.atkfilter,1,nil,e:GetHandlerPlayer()) end
	-- 显示选择提示信息，提示玩家选择要送去墓地的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=c:GetEquipGroup():FilterSelect(tp,c21249921.atkfilter,1,1,nil,e:GetHandlerPlayer())
	-- 将所选装备卡作为代价送入墓地。
	Duel.SendtoGrave(g,REASON_COST)
end
-- ②的效果处理：若这张卡表侧表示且仍与效果关联，则将其攻击力变为当前攻击力的2倍，直到回合结束。
function c21249921.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 这张卡的攻击力直到回合结束时变成2倍。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
