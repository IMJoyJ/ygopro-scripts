--カラクリ蝦蟇油
-- 效果：
-- 这个卡名的卡在1回合只能发动1张。
-- ①：以自己墓地1只「机巧」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
-- ②：1回合1次，自己场上的表侧表示的「机巧」怪兽的表示形式变更的场合发动。装备怪兽的攻击力·守备力上升500。
function c11699941.initial_effect(c)
	-- 这个卡名的卡在1回合只能发动1张。①：以自己墓地1只「机巧」怪兽为对象才能把这张卡发动。那只怪兽特殊召唤，把这张卡装备。
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
-- 筛选函数：判断一张卡是否为「机巧」怪兽，且能否被当前效果特殊召唤。
function c11699941.filter(c,e,tp)
	return c:IsSetCard(0x11) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- 效果发动时的取对象与发动条件检查：若在检查对象，则确认对象是自己墓地的「机巧」怪兽且满足特殊召唤条件；若在发动时，则确认自己场上存在可用的怪兽区，且墓地存在至少1只符合条件的「机巧」怪兽。
function c11699941.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c11699941.filter(chkc,e,tp) end
	-- 发动条件之一：自己的主要怪兽区有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 发动条件之一：自己墓地存在至少1只符合条件的「机巧」怪兽可以成为对象。
		and Duel.IsExistingTarget(c11699941.filter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 向玩家显示选择提示，要求选择要特殊召唤的怪兽。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1只符合条件的「机巧」怪兽，并登记为当前连锁的效果对象。
	local g=Duel.SelectTarget(tp,c11699941.filter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	-- 登记操作信息：本效果将特殊召唤1只对象怪兽。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
	-- 登记操作信息：本效果将把发动效果的这张卡作为装备卡装备。
	Duel.SetOperationInfo(0,CATEGORY_EQUIP,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡和对象怪兽仍与本效果有联系，则将对象怪兽表侧表示特殊召唤；成功后把这张卡装备给那只怪兽，并给这张卡设置装备限制，使其只能装备给那只怪兽。
function c11699941.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取本效果的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc:IsRelateToEffect(e) then
		-- 将对象怪兽以表侧表示特殊召唤；若特殊召唤未成功则终止处理。
		if Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)==0 then return end
		-- 将发动效果的这张卡作为装备卡装备给对象怪兽。
		Duel.Equip(tp,c,tc)
		-- 那只怪兽特殊召唤，把这张卡装备。
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetValue(c11699941.eqlimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
	end
end
-- 装备限制函数：这张卡只能装备给当初由该效果特殊召唤的怪兽（即效果的所有者）。
function c11699941.eqlimit(e,c)
	return e:GetOwner()==c
end
-- 筛选函数：判断一只「机巧」怪兽的表示形式是否在攻击表示与表侧守备表示之间发生了变更。
function c11699941.cfilter(c,tp)
	local np=c:GetPosition()
	local pp=c:GetPreviousPosition()
	return c:IsSetCard(0x11) and c:IsControler(tp) and ((pp==0x1 and np==0x4) or (pp==0x4 and np==0x1))
end
-- ②效果的发动条件：本次表示形式变更事件中，存在至少1只自己场上的「机巧」怪兽发生了攻击/守备表示变更。
function c11699941.atkcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c11699941.cfilter,1,nil,tp)
end
-- ②效果处理：若这张卡仍装备着怪兽，则使装备怪兽的攻击力和守备力各上升500（持续到标准重置时机）。
function c11699941.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ec=c:GetEquipTarget()
	if ec and c:IsRelateToEffect(e) then
		-- 装备怪兽的攻击力·守备力上升500。
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
