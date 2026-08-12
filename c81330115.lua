--No.30 破滅のアシッド・ゴーレム
-- 效果：
-- 3星怪兽×2
-- ①：没有超量素材的这张卡不能攻击。
-- ②：只要这张卡在怪兽区域存在，自己不能把怪兽特殊召唤。
-- ③：自己准备阶段发动。这张卡1个超量素材取除或自己受到2000伤害。
function c81330115.initial_effect(c)
	-- 添加超量召唤手续，需要2只3星怪兽作为素材
	aux.AddXyzProcedure(c,nil,3,2)
	c:EnableReviveLimit()
	-- ③：自己准备阶段发动。这张卡1个超量素材取除或自己受到2000伤害。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(81330115,0))  --"去除素材"
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(c81330115.rmcon)
	e1:SetTarget(c81330115.rmtg)
	e1:SetOperation(c81330115.rmop)
	c:RegisterEffect(e1)
	-- ①：没有超量素材的这张卡不能攻击。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CANNOT_ATTACK)
	e2:SetCondition(c81330115.atcon)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在怪兽区域存在，自己不能把怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetTargetRange(1,0)
	c:RegisterEffect(e3)
end
-- 设置该卡片的「No.」编号为30
aux.xyz_number[81330115]=30
-- 定义不能攻击效果的生效条件：自身没有超量素材
function c81330115.atcon(e)
	return e:GetHandler():GetOverlayCount()==0
end
-- 定义准备阶段效果的发动条件：当前回合玩家是自己
function c81330115.rmcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断当前回合玩家是否为自己
	return Duel.GetTurnPlayer()==tp
end
-- 定义准备阶段效果的发动检测：若自身没有超量素材，则注册伤害操作信息
function c81330115.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	if e:GetHandler():GetOverlayCount()==0 then
		-- 设置在效果处理时会给与玩家2000点伤害的操作信息
		Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,2000)
	end
end
-- 定义准备阶段效果的处理：选择去除1个超量素材或受到2000点伤害
function c81330115.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 判断自身是否可以去除超量素材，并由玩家选择是否去除
	if e:GetHandler():CheckRemoveOverlayCard(tp,1,REASON_EFFECT) and Duel.SelectYesNo(tp,aux.Stringid(81330115,1)) then  --"是否要去除一个超量素材？"
		e:GetHandler():RemoveOverlayCard(tp,1,1,REASON_EFFECT)
	else
		-- 给与自己2000点效果伤害
		Duel.Damage(tp,2000,REASON_EFFECT)
	end
end
