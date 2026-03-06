--ドラグニティ－ドゥクス
-- 效果：
-- ①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
-- ②：这张卡的攻击力上升自己场上的「龙骑兵团」卡数量×200。
function c28183605.initial_effect(c)
	-- 效果原文：②：这张卡的攻击力上升自己场上的「龙骑兵团」卡数量×200。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(c28183605.atkval)
	c:RegisterEffect(e1)
	-- 效果原文：①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
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
-- 过滤函数：筛选场上正面表示的「龙骑兵团」怪兽
function c28183605.atkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 计算效果：计算场上「龙骑兵团」怪兽数量并乘以200作为攻击力加成
function c28183605.atkval(e,c)
	-- 返回场上「龙骑兵团」怪兽数量乘以200的值
	return Duel.GetMatchingGroupCount(c28183605.atkfilter,c:GetControler(),LOCATION_ONFIELD,0,nil)*200
end
-- 过滤函数：筛选墓地里等级3以下、龙族、且未被禁止的「龙骑兵团」怪兽
function c28183605.filter(c)
	return c:IsLevelBelow(3) and c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 处理函数：判断是否满足装备条件，包括魔陷区是否有空位和墓地是否存在符合条件的怪兽
function c28183605.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c28183605.filter(chkc) end
	-- 判断魔陷区是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c28183605.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择目标：从自己墓地选择一只符合条件的怪兽
	local g=Duel.SelectTarget(tp,c28183605.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置连锁操作信息：标记将要从墓地离开的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 装备处理函数：将选中的怪兽装备给自身，并设置装备限制
function c28183605.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 尝试将目标怪兽装备给自身，若失败则返回
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 效果原文：①：这张卡召唤成功时，以自己墓地1只龙族·3星以下的「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c28183605.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备限制函数：确保只有装备者能装备该卡
function c28183605.eqlimit(e,c)
	return e:GetOwner()==c
end
