--ドラグニティ－ドゥクス
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升自己场上的「龙骑兵团」卡数量×200。
function c28183605.initial_effect(c)
	-- ②：这张卡的攻击力上升自己场上的「龙骑兵团」卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c28183605.atkval)
	c:RegisterEffect(e1)
	-- ①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(28183605,0))  --"装备"
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetTarget(c28183605.eqtg)
	e2:SetOperation(c28183605.eqop)
	c:RegisterEffect(e2)
end
-- 定义攻击力上升效果的数量统计过滤条件：场上表侧表示的「龙骑兵团」卡。
function c28183605.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 计算这张卡攻击力上升的数值，为自己场上表侧表示的「龙骑兵团」卡数量×200。
function c28183605.atkval(e,c)
	-- 返回自己场上表侧表示「龙骑兵团」卡的数量乘以200，作为攻击力上升数值。
	return Duel.GetMatchingGroupCount(c28183605.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*200
end
-- 定义效果对象过滤条件：自己墓地1只龙族·3星以下且持有「龙骑兵团」字段、未被禁止的怪兽（作为装备对象）。
function c28183605.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 发动条件的判定与选择对象：取自己墓地1只满足条件的龙族「龙骑兵团」怪兽为对象；同时确认魔陷区有空位。
function c28183605.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28183605.filter(chkc) end
	-- 效果发动时点检查：自己魔陷区是否有空位（用于放置装备卡）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 且自己墓地存在至少1只满足filter条件、可作为效果对象的龙族「龙骑兵团」怪兽。
		and Duel.IsExistingTarget(c28183605.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 向操作玩家显示选择装备卡的提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 让玩家从自己墓地的满足条件的怪兽中选择1只作为效果对象，并设定为连锁对象。
	local g=Duel.SelectTarget(tp,c28183605.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置本次连锁的操作信息：涉及墓地卡移动（从墓地离开），用于应对“王家长眠之谷”等效果。
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 效果处理时：将对象怪兽作为装备卡装备给这张卡；若装备成功，给装备怪兽附加“只能装备给这张卡的持有者”的装备限制效果。
function c28183605.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 取得效果发动时选择的装备对象怪兽。
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 尝试把对象怪兽作为装备卡装备给这张卡，若失败则结束处理（例如装备区已满或不允许装备时）。
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c28183605.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 判断装备对象是否只能装备给这张卡：限制条件为装备卡的持有者（原效果发动者）与这张卡相同。
function c28183605.eqlimit(e,c)
	return e:GetOwner()==c
end
