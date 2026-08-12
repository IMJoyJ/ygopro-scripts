--幻奏の音女カノン
-- 效果：
-- 「幻奏的音女 卡农」的①的方法的特殊召唤1回合只能有1次。
-- ①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
-- ②：1回合1次，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的表示形式变更。
function c16021142.initial_effect(c)
	-- ①：自己场上有「幻奏」怪兽存在的场合，这张卡可以从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,16021142+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c16021142.spcon)
	c:RegisterEffect(e1)
	-- ②：1回合1次，以自己场上1只「幻奏」怪兽为对象才能发动。那只怪兽的表示形式变更。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16021142,0))  --"特殊召唤"
	e2:SetCategory(CATEGORY_POSITION)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetCountLimit(1)
	e2:SetTarget(c16021142.postg)
	e2:SetOperation(c16021142.posop)
	c:RegisterEffect(e2)
end
-- 判断目标怪兽是否为表侧表示且为「幻奏」卡族
function c16021142.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b)
end
-- 检查是否满足特殊召唤条件：场上存在「幻奏」怪兽且有空位
function c16021142.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否有空位
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查自己场上是否存在「幻奏」怪兽
		and Duel.IsExistingMatchingCard(c16021142.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
-- 判断目标怪兽是否为表侧表示且为「幻奏」卡族且可以变更表示形式
function c16021142.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x9b) and c:IsCanChangePosition()
end
-- 设置效果处理时的目标选择逻辑
function c16021142.postg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and c16021142.filter(chkc) end
	-- 判断是否满足发动条件：存在可选择的「幻奏」怪兽
	if chk==0 then return Duel.IsExistingTarget(c16021142.filter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择要变更表示形式的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)  --"请选择要改变表示形式的怪兽"
	-- 选择目标怪兽
	local g=Duel.SelectTarget(tp,c16021142.filter,tp,LOCATION_MZONE,0,1,1,nil)
	-- 设置效果处理信息，确定将要变更表示形式的怪兽
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,1,0,0)
end
-- 处理效果的发动，变更目标怪兽的表示形式
function c16021142.posop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取当前效果的目标怪兽
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标怪兽变为表侧守备表示
		Duel.ChangePosition(tc,POS_FACEUP_DEFENSE,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
	end
end
