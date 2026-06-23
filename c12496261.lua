--ドラグニティナイト－ハールーン
-- 效果：
-- 「龙骑兵团」调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡特殊召唤的场合，以自己墓地1只「龙骑兵团」怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。
-- ②：这张卡被送去墓地的场合，以自己场上1只「龙骑兵团」怪兽为对象才能发动。这张卡当作攻击力·守备力上升1000的装备魔法卡使用给作为对象的自己怪兽装备。
function c12496261.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整（属于龙骑兵团）和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,aux.FilterBoolFunction(Card.IsSetCard,0x29),aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡特殊召唤的场合，以自己墓地1只「龙骑兵团」怪兽为对象才能发动。那只怪兽当作装备魔法卡使用给这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(12496261,0))
	e1:SetCategory(CATEGORY_LEAVE_GRAVE+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,12496261)
	e1:SetTarget(c12496261.eqtg)
	e1:SetOperation(c12496261.eqop)
	c:RegisterEffect(e1)
	-- ②：这张卡被送去墓地的场合，以自己场上1只「龙骑兵团」怪兽为对象才能发动。这张卡当作攻击力·守备力上升1000的装备魔法卡使用给作为对象的自己怪兽装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(12496261,1))
	e2:SetCategory(CATEGORY_EQUIP)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,12496262)
	e2:SetTarget(c12496261.eqstg)
	e2:SetOperation(c12496261.eqsop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的「龙骑兵团」怪兽（包括墓地中的）
function c12496261.filter(c)
	return c:IsSetCard(0x29) and c:IsType(TYPE_MONSTER) and not c:IsForbidden()
end
-- 处理效果①的发动时的取对象步骤
function c12496261.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c12496261.filter(chkc) end
	-- 判断是否满足发动条件：场上是否有空置的魔陷区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：自己墓地是否有「龙骑兵团」怪兽
		and Duel.IsExistingTarget(c12496261.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择目标：自己墓地的「龙骑兵团」怪兽
	local g=Duel.SelectTarget(tp,c12496261.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置操作信息：将目标怪兽从墓地移除
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
	-- 设置操作信息：将目标怪兽装备给自身
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,g,1,0,0)
end
-- 处理效果①的发动时的执行步骤
function c12496261.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 尝试将目标怪兽装备给自身
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 设置装备对象限制，确保只有自身能装备该怪兽
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_OWNER_RELATE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12496261.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 装备对象限制的判断函数
function c12496261.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 过滤满足条件的「龙骑兵团」场上怪兽
function c12496261.eqfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x29)
end
-- 处理效果②的发动时的取对象步骤
function c12496261.eqstg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and c12496261.eqfilter(chkc) end
	-- 判断是否满足发动条件：场上是否有空置的魔陷区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 判断是否满足发动条件：自己场上是否有「龙骑兵团」怪兽
		and Duel.IsExistingTarget(c12496261.eqfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要装备的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
	-- 选择目标：自己场上的「龙骑兵团」怪兽
	Duel.SelectTarget(tp,c12496261.eqfilter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置操作信息：将自身装备给目标怪兽
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 处理效果②的发动时的执行步骤
function c12496261.eqsop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断是否满足发动条件：场上是否有空置的魔陷区域
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 获取当前连锁的目标卡
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		-- 将自身装备给目标怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制，确保只有目标怪兽能装备自身
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c12496261.eqlimit)
		c:RegisterEffect(e1)
		-- 使自身攻击力上升1000
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_EQUIP)
		e2:SetCode(EFFECT_UPDATE_ATTACK)
		e2:SetValue(1000)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e2)
		local e3=e2:Clone()
		e3:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e3)
	end
end
