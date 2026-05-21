--ドラグニティアームズ－ミスティル
-- 效果：
-- ①：这张卡可以把自己场上1只表侧表示的「龙骑兵团」怪兽送去墓地，从手卡特殊召唤。
-- ②：这张卡从手卡召唤·特殊召唤时，以自己墓地1只龙族「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备魔法卡使用给这张卡装备。
function c876330.initial_effect(c)
	-- ①：这张卡可以把自己场上1只表侧表示的「龙骑兵团」怪兽送去墓地，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c876330.spcon)
	e1:SetTarget(c876330.sptg)
	e1:SetOperation(c876330.spop)
	c:RegisterEffect(e1)
	-- ②：这张卡从手卡召唤·特殊召唤时，以自己墓地1只龙族「龙骑兵团」怪兽为对象才能发动。那只龙族怪兽当作装备魔法卡使用给这张卡装备。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(876330,0))  --"装备"
	e2:SetCategory(CATEGORY_LEAVE_GRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCondition(c876330.eqcon)
	e2:SetTarget(c876330.eqtg)
	e2:SetOperation(c876330.eqop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
-- 定义特殊召唤规则所需的送去墓地卡片的过滤条件
function c876330.spfilter(c,tp)
	-- 过滤条件：场上表侧表示的「龙骑兵团」怪兽，能作为cost送去墓地，且该卡送去墓地后能腾出可用的怪兽区域
	return c:IsFaceup() and c:IsSetCard(0x29) and c:IsAbleToGraveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 定义特殊召唤规则的条件判定函数
function c876330.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足送墓条件的「龙骑兵团」怪兽
	return Duel.IsExistingMatchingCard(c876330.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 定义特殊召唤规则的目标选择函数
function c876330.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足送墓条件的「龙骑兵团」怪兽组
	local g=Duel.GetMatchingGroup(c876330.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家发送提示信息：请选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 定义特殊召唤规则的具体操作函数
function c876330.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 将选择的怪兽作为特殊召唤的消耗送去墓地
	Duel.SendtoGrave(g,REASON_SPSUMMON)
end
-- 判定发动条件：这张卡原本的位置必须是手卡
function c876330.eqcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousLocation(LOCATION_HAND)
end
-- 过滤条件：墓地的龙族「龙骑兵团」怪兽，且不能是无法放置在魔陷区的卡
function c876330.filter(c)
	return c:IsSetCard(0x29) and c:IsRace(RACE_DRAGON) and not c:IsForbidden()
end
-- 定义装备效果的发动准备与目标选择函数
function c876330.eqtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and c876330.filter(chkc) end
	-- 在发动准备阶段，检查自己场上是否有可用的魔法与陷阱区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 并且检查自己墓地是否存在至少1只满足条件的龙族「龙骑兵团」怪兽
		and Duel.IsExistingTarget(c876330.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要装备的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)  --"请选择要装备的卡"
	-- 选择自己墓地1只满足条件的怪兽作为效果的对象
	local g=Duel.SelectTarget(tp,c876330.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果处理信息：涉及1张卡离开墓地
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,g,1,0,0)
end
-- 定义装备效果的具体处理函数
function c876330.eqop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 获取在发动时选择的作为对象的那只墓地怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsRace(RACE_DRAGON) then
		-- 将目标怪兽作为装备卡装备给这张卡，若装备失败则结束处理
		if not Duel.Equip(tp,tc,c,false) then return end
		-- 那只龙族怪兽当作装备魔法卡使用给这张卡装备。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(c876330.eqlimit)
		tc:RegisterEffect(e1)
	end
end
-- 定义装备限制：该装备卡只能装备给当前卡，且在当前卡效果无效时解除装备
function c876330.eqlimit(e,c)
	return e:GetOwner()==c and not c:IsDisabled()
end
