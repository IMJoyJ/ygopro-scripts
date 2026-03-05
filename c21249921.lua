--ドラグニティナイト－ヴァジュランダ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：这张卡同调召唤时，以自己墓地1只3星以下的龙族「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备魔法卡使用给这张卡装备。
-- ②：1回合1次，把这张卡装备的自己场上1张装备卡送去墓地才能发动。这张卡的攻击力直到回合结束时变成2倍。
function c21249921.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（龙族）和至少1只调整以外的鸟兽族怪兽作为素材
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
-- 效果发动的条件：此卡为同调召唤成功
function c21249921.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 满足条件的墓地龙族怪兽过滤器：等级3以下、龙骑兵团系列、龙族、未被禁止
function c21249921.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 设置效果目标：选择满足条件的墓地1只怪兽作为对象
function c21249921.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c21249921.filter(chkc) end
	-- 判断是否满足发动条件：场上存在空魔陷区
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：自己墓地存在满足条件的怪兽
		and Duel.IsExistingTarget(c21249921.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c21249921.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：将被装备的怪兽加入效果处理对象
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理：将选中的墓地怪兽装备给此卡
function c21249921.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 执行装备操作，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 为装备卡设置装备对象限制效果，只能被此卡装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c21249921.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备对象限制效果的值函数：只能被装备卡的拥有者装备
function c21249921.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 用于判断装备卡是否可以作为cost送入墓地的过滤器
function c21249921.atkfilter(c,tp)
	return c:IsControler(tp) and c:IsAbleToGraveAsCost()
end
-- 效果发动的cost处理：选择1张自己场上的装备卡送去墓地作为cost
function c21249921.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:GetEquipGroup():IsExists(c21249921.atkfilter,1,nil,e:GetHandlerPlayer()) end
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local g=c:GetEquipGroup():FilterSelect(tp,c21249921.atkfilter,1,1,nil,e:GetHandlerPlayer())
	-- 将选中的装备卡送去墓地作为cost
	Duel.SendtoGrave(g,REASON_COST)
end
-- 效果处理：使此卡攻击力变为2倍
function c21249921.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		-- 设置此卡攻击力变为2倍的效果
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetValue(c:GetAttack()*2)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
	end
end
