--空牙団の豪傑 ダイナ
-- 效果：
-- 这个卡名的①的效果1回合只能使用1次。
-- ①：这张卡特殊召唤成功的场合才能发动。选最多有自己场上的「空牙团」怪兽种类数量的对方墓地的卡除外。
-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的「空牙团」怪兽作为攻击对象。
function c25123713.initial_effect(c)
	-- 这个卡名的①的效果1回合只能使用1次。①：这张卡特殊召唤成功的场合才能发动。选最多有自己场上的「空牙团」怪兽种类数量的对方墓地的卡除外。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,25123713)
	e1:SetTarget(c25123713.rmtg)
	e1:SetOperation(c25123713.rmop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方不能选择其他的「空牙团」怪兽作为攻击对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(c25123713.atlimit)
	c:RegisterEffect(e2)
end
-- 定义过滤函数：筛选表侧表示且拥有「空牙团」字段（0x114）的怪兽，用于检索自己场上的空牙团怪兽。
function c25123713.filter(c)
	return c:IsFaceup() and c:IsSetCard(0x114)
end
-- 效果发动条件判定：获取自己场上表侧表示的空牙团怪兽，且对方墓地存在至少1张可除外的卡时，效果才能发动（chk==0）。
function c25123713.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 获取自己场上所有满足filter条件的「空牙团」怪兽，组成集合g，用于判断是否存在空牙团怪兽。
	local g=Duel.GetMatchingGroup(c25123713.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return g:GetCount()~=0
		-- 检查对方墓地是否存在至少1张可以被除外的卡（Card.IsAbleToRemove），作为发动条件之一。
		and Duel.IsExistingMatchingCard(Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,nil) end
	-- 设置效果处理信息：除外对象为对方墓地的卡，目标玩家为对方，count为1（满足最低检测，实际处理时数量由空牙团种类数决定）。
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,1-tp,LOCATION_GRAVE)
end
-- 效果处理：重新获取自己场上的空牙团怪兽，计算其中卡名种类数ct；若ct为0则直接结束；否则提示玩家从对方墓地选择1到ct张可除外的卡并除外。
function c25123713.rmop(e,tp,eg,ep,ev,re,r,rp)
	-- 效果处理时重新获取自己场上的空牙团怪兽集合，以当前实际存在情况确定可除外的最大数量。
	local cg=Duel.GetMatchingGroup(c25123713.filter,tp,LOCATION_MZONE,0,nil)
	local ct=cg:GetClassCount(Card.GetCode)
	if ct==0 then return end
	-- 显示选择提示：向操作玩家显示'请选择要除外的卡'的提示信息（HINTMSG_REMOVE）。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从对方墓地中选择1到ct张满足可除外条件的卡（Card.IsAbleToRemove），作为本次要除外的卡。
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemove,tp,0,LOCATION_GRAVE,1,ct,nil)
	if g:GetCount()>0 then
		-- 将选中的卡以表侧表示除外（POS_FACEUP，REASON_EFFECT），执行除外操作。
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
-- 定义②效果的判定规则：若攻击对象候选卡是表侧表示的空牙团怪兽且不是本卡（戴纳），则对方不能选择该卡作为攻击对象。
function c25123713.atlimit(e,c)
	return c:IsFaceup() and c:IsSetCard(0x114) and c~=e:GetHandler()
end
