--ドラグニティナイト－バルーチャ
-- 效果：
-- 龙族调整＋调整以外的鸟兽族怪兽1只以上
-- ①：这张卡同调召唤时，以自己墓地的龙族「龙骑兵团」怪兽任意数量为对象才能发动。那些龙族怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡的攻击力上升这张卡装备的「龙骑兵团」卡数量×300。
function c25682811.initial_effect(c)
	-- 添加同调召唤手续，要求1只龙族调整和1只以上鸟兽族调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsRace,RACE_DRAGON),aux.NonTuner(Card.IsRace,RACE_WINDBEAST),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤时，以自己墓地的龙族「龙骑兵团」怪兽任意数量为对象才能发动。那些龙族怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(25682811,0))  --"装备"
	e1:SetCategory(CATEGORY_LEAVE_GRAVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCondition(c25682811.eqcon)
	e1:SetTarget(c25682811.eqtg)
	e1:SetOperation(c25682811.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡的攻击力上升这张卡装备的「龙骑兵团」卡数量×300。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetValue(c25682811.atkval)
	c:RegisterEffect(e2)
end
-- 效果发动条件：这张卡是同调召唤成功时才能发动
function c25682811.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- 过滤满足条件的墓地龙族「龙骑兵团」怪兽
function c25682811.filter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 设置效果发动时的处理目标，选择墓地的龙族「龙骑兵团」怪兽
function c25682811.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c25682811.filter(chkc) end
	-- 判断场上是否有足够的魔法区域来装备
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断墓地是否存在满足条件的龙族「龙骑兵团」怪兽
		and Duel.IsExistingTarget(c25682811.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 获取玩家可用的魔法区域数量
	local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择满足条件的墓地怪兽作为装备对象
	local g=Duel.SelectTarget(tp,c25682811.filter,tp,LOCATION_GRAVE,0,1,ft,nil)
	-- 设置操作信息，记录将要离开墓地的卡
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,g:GetCount(),0,0)
	-- 设置操作信息，记录将要装备的卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,g:GetCount(),0,0)
end
-- 执行装备操作，将选中的卡作为装备卡装备给自身
function c25682811.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取连锁中设定的目标卡组
	local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
	local sg=g:Filter(Card.IsRelateToEffect,nil,e)
	-- 判断场上是否还有足够的魔法区域来装备所有选中的卡
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<sg:GetCount() then return end
	local c=e:GetHandler()
	if c:IsFacedown() or not c:IsRelateToEffect(e) then return end
	local tc=sg:GetFirst()
	while tc do
		-- 将选中的卡装备给自身
		Duel.Equip(tp,tc,c,false,true)
		-- 为装备卡设置装备限制效果，只能被自身装备
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c25682811.eqlimit)
		tc:RegisterEffect(e1)
		tc=sg:GetNext()
	end
	-- 完成装备过程的时点处理
	Duel.EquipComplete()
end
-- 装备限制效果的判定函数，只能被装备者自身装备
function c25682811.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 计算装备的「龙骑兵团」卡数量并乘以300作为攻击力加成
function c25682811.atkval(e,c)
	return c:GetEquipGroup():FilterCount(Card.IsSetCard,nil,0x29)*300
end
