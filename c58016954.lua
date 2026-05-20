--イェシャドール－セフィラナーガ
-- 效果：
-- ←1 【灵摆】 1→
-- ①：自己不是「影依」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
-- 【怪兽效果】
-- 这个卡名的怪兽效果1回合只能使用1次。
-- ①：这张卡灵摆召唤成功的场合或者这张卡被送去墓地的场合，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。这个效果在自己的灵摆区域有「神数」卡存在的场合才能发动和处理。
function c58016954.initial_effect(c)
	-- 初始化灵摆怪兽属性，注册灵摆召唤和灵摆卡发动相关的规则与效果
	aux.EnablePendulumAttribute(c)
	-- ①：自己不是「影依」怪兽以及「神数」怪兽不能灵摆召唤。这个效果不会被无效化。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CAN_FORBIDDEN)
	e2:SetTargetRange(1,0)
	e2:SetTarget(c58016954.splimit)
	c:RegisterEffect(e2)
	-- 这个卡名的怪兽效果1回合只能使用1次。①：这张卡灵摆召唤成功的场合或者这张卡被送去墓地的场合，以自己或者对方的灵摆区域1张卡为对象才能发动。那张卡回到持有者手卡。这个效果在自己的灵摆区域有「神数」卡存在的场合才能发动和处理。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetCountLimit(1,58016954)
	e3:SetCondition(c58016954.condition1)
	e3:SetTarget(c58016954.target)
	e3:SetOperation(c58016954.operation)
	c:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EVENT_TO_GRAVE)
	-- 将克隆出的送去墓地触发的效果（e4）的发动条件设为无条件（始终成立）
	e4:SetCondition(aux.TRUE)
	c:RegisterEffect(e4)
end
-- 限制灵摆召唤的过滤函数，使玩家只能灵摆召唤「影依」怪兽以及「神数」怪兽
function c58016954.splimit(e,c,sump,sumtype,sumpos,targetp)
	if c:IsSetCard(0x9d,0xc4) then return false end
	return bit.band(sumtype,SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM
end
-- 检查此卡是否是通过灵摆召唤特殊召唤成功的
function c58016954.condition1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_PENDULUM)
end
-- 过滤条件：是否为「神数」卡片
function c58016954.cfilter(c)
	return c:IsSetCard(0xc4)
end
-- 过滤条件：是否可以回到手牌
function c58016954.filter(c)
	return c:IsAbleToHand()
end
-- 怪兽效果的发动准备与目标选择函数
function c58016954.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_PZONE) and c58016954.filter(chkc) end
	-- 发动条件检查：检查自己的灵摆区域是否存在「神数」卡
	if chk==0 then return Duel.IsExistingMatchingCard(c58016954.cfilter,tp,LOCATION_PZONE,0,1,nil)
		-- 发动条件检查：检查双方的灵摆区域是否存在可以回到手牌的卡
		and Duel.IsExistingTarget(c58016954.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,nil) end
	-- 在客户端显示提示信息，要求玩家选择要返回手牌的卡片
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)  --"请选择要返回手牌的卡"
	-- 让玩家选择双方灵摆区域的1张卡作为效果对象
	local g=Duel.SelectTarget(tp,c58016954.filter,tp,LOCATION_PZONE,LOCATION_PZONE,1,1,nil)
	-- 设置效果处理信息，表明此效果的操作为将选中的1张卡送回手牌
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 怪兽效果的效果处理（操作）函数
function c58016954.operation(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时检查：若自己的灵摆区域没有「神数」卡存在，则不进行后续处理
	if not Duel.IsExistingMatchingCard(c58016954.cfilter,tp,LOCATION_PZONE,0,1,nil) then return end
	-- 获取发动时选择的作为效果对象的卡片
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡片送回持有者的手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
