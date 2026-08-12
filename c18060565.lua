--ドラグニティ－プリムス・ピルス
-- 效果：
-- ①：这张卡召唤·特殊召唤成功时，以自己场上1只鸟兽族「龙骑兵团」怪兽为对象才能发动。从卡组选1只龙族·3星以下的「龙骑兵团」怪兽当作装备卡使用给作为对象的怪兽装备。
function c18060565.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功时，以自己场上1只鸟兽族「龙骑兵团」怪兽为对象才能发动。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(18060565,0))  --"装备"
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(c18060565.eqtg)
	e1:SetOperation(c18060565.eqop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
end
-- 过滤函数，用于判断场上是否存在满足条件的鸟兽族「龙骑兵团」怪兽
function c18060565.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsRace(RACE_WINDBEAST)
end
-- 效果处理函数，用于处理选择对象和装备卡的条件检查
function c18060565.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c18060565.filter(chkc) end
	-- 检查玩家场上是否有足够的魔法陷阱区域来装备卡片
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 检查玩家场上是否存在满足条件的鸟兽族「龙骑兵团」怪兽作为对象
		and Duel.IsExistingTarget(c18060565.filter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查玩家卡组中是否存在满足条件的龙族·3星以下的「龙骑兵团」怪兽
		and Duel.IsExistingMatchingCard(c18060565.eqfilter,tp,LOCATION_DECK,0,1,nil) end
	-- 向玩家提示选择表侧表示的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 选择满足条件的鸟兽族「龙骑兵团」怪兽作为装备对象
	Duel.SelectTarget(tp,c18060565.filter,tp,LOCATION_MZONE,0,1,1,nil)
end
-- 过滤函数，用于筛选卡组中满足条件的龙族·3星以下的「龙骑兵团」怪兽
function c18060565.eqfilter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and c:IsLevelBelow(3) and not c:IsForbidden()
end
-- 装备效果处理函数，执行装备操作并设置装备限制
function c18060565.eqop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查玩家场上是否有足够的魔法陷阱区域来装备卡片
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	-- 获取当前连锁效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsFacedown() then return end
	-- 向玩家提示选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 从卡组中选择一只满足条件的龙族·3星以下的「龙骑兵团」怪兽
	local eq=Duel.SelectMatchingCard(tp,c18060565.eqfilter,tp,LOCATION_DECK,0,1,1,nil)
	local eqc=eq:GetFirst()
	-- 将选中的怪兽装备给目标怪兽
	if eqc and Duel.Equip(tp,eqc,tc) then
		-- 设置装备对象限制，确保装备卡只能装备给指定的怪兽
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c18060565.eqlimit)
		e1:SetLabelObject(tc)
		eqc:RegisterEffect(e1)
	end
end
-- 装备对象限制判断函数，用于判断是否可以装备给指定怪兽
function c18060565.eqlimit(e,c)
	return c==e:GetLabelObject()
end
