--カラクリ蝦蟇油
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「机巧」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
-- ②：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合发动。装备怪兽的攻击力·守备力上升500。
function c11699941.initial_effect(c)
	-- ①：以自己墓地1只「机巧」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,11699941+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(c11699941.target)
	e1:SetOperation(c11699941.operation)
	c:RegisterEffect(e1)
	-- ②：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合发动。装备怪兽的攻击力·守备力上升500。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(11699941,1))
	e2:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e2:SetType(EFFECT_TYPE_TRIGGER_F+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHANGE_POS)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(c11699941.atkcon)
	e2:SetOperation(c11699941.atkop)
	c:RegisterEffect(e2)
end
-- 过滤满足条件的墓地「机巧」怪兽
function c11699941.filter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果①的发动选择目标处理
function c11699941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11699941.filter(chkc,e,tp) end
	-- 判断是否满足发动条件：场上是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 判断是否满足发动条件：墓地是否存在符合条件的怪兽
		and Duel.IsExistingTarget(c11699941.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 提示玩家选择要特殊召唤的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的墓地怪兽作为效果对象
	local g=Duel.SelectTarget(tp,c11699941.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 设置效果处理信息：特殊召唤怪兽
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 设置效果处理信息：装备卡
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果①的发动处理
function c11699941.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取效果对象怪兽
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽特殊召唤到场上
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将此卡装备给特殊召唤的怪兽
		Duel.Equip(tp,c,tc)
		-- 设置装备对象限制效果，防止被其他装备卡装备
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c11699941.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备对象限制效果的判断函数
function c11699941.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 判断表示形式变更的怪兽是否为「机巧」怪兽
function c11699941.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- 效果②的发动条件处理
function c11699941.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11699941.cfilter,1,nil,tp)
end
-- 效果②的发动处理
function c11699941.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 装备怪兽的攻击力上升500
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		ec:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		ec:RegisterEffect(e2)
	end
end
