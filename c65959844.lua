--化合電界
-- 效果：
-- ①：只要这张卡在场地区域存在，自己在5星以上的二重怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
-- ②：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只二重怪兽召唤。
-- ③：1回合1次，以对方场上1张卡为对象才能发动。自己场上1只再1次召唤状态的二重怪兽直到对方结束阶段除外，作为对象的卡破坏。
function c65959844.initial_effect(c)
	-- 永续魔陷/场地卡通用的“允许发动”空效果，无此效果则无法发动
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- ①：只要这张卡在场地区域存在，自己在5星以上的二重怪兽召唤的场合需要的解放可以不用。这个效果1回合只能适用1次。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(65959844,0))  --"不用解放作召唤"
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,0)
	e2:SetCountLimit(1)
	e2:SetCondition(c65959844.ntcon)
	e2:SetTarget(c65959844.nttg)
	c:RegisterEffect(e2)
	-- ②：只要这张卡在场地区域存在，自己在通常召唤外加上只有1次，自己主要阶段可以把1只二重怪兽召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(65959844,2))  --"使用「化合电界」的效果召唤"
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_EXTRA_SUMMON_COUNT)
	e3:SetRange(LOCATION_FZONE)
	e3:SetTargetRange(LOCATION_HAND+LOCATION_MZONE,0)
	-- 设置额外召唤的目标为二重怪兽
	e3:SetTarget(aux.TargetBoolFunction(Card.IsType,TYPE_DUAL))
	c:RegisterEffect(e3)
	-- ③：1回合1次，以对方场上1张卡为对象才能发动。自己场上1只再1次召唤状态的二重怪兽直到对方结束阶段除外，作为对象的卡破坏。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(65959844,1))  --"破坏"
	e4:SetCategory(CATEGORY_REMOVE+CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e4:SetRange(LOCATION_FZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(c65959844.destg)
	e4:SetOperation(c65959844.desop)
	c:RegisterEffect(e4)
end
c65959844.has_text_type=TYPE_DUAL
-- 判定不用解放进行召唤的条件函数
function c65959844.ntcon(e,c,minc)
	if c==nil then return true end
	-- 判定召唤不需要解放且自己场上有可用的怪兽区域
	return minc==0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
-- 过滤不用解放进行召唤的怪兽（5星以上的二重怪兽）
function c65959844.nttg(e,c)
	return c:IsLevelAbove(5) and c:IsType(TYPE_DUAL)
end
-- 过滤自己场上可以除外的、处于再1次召唤状态的二重怪兽
function c65959844.rmfilter(c)
	return c:IsDualState() and c:IsAbleToRemove()
end
-- 破坏效果的发动准备与对象选择
function c65959844.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	-- 检查自己场上是否存在至少1只可以除外的、处于再1次召唤状态的二重怪兽
	if chk==0 then return Duel.IsExistingMatchingCard(c65959844.rmfilter,tp,LOCATION_MZONE,0,1,nil)
		-- 检查对方场上是否存在可以作为对象破坏的卡
		and Duel.IsExistingTarget(aux.TRUE,tp,0,LOCATION_ONFIELD,1,nil) end
	-- 提示玩家选择要破坏的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)  --"请选择要破坏的卡"
	-- 选择对方场上1张卡作为效果的对象
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,0,LOCATION_ONFIELD,1,1,nil)
	-- 设置除外操作的信息（从自己场上除外1只怪兽）
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,nil,1,tp,LOCATION_MZONE)
	-- 设置破坏操作的信息（破坏选中的对象卡）
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
-- 破坏效果的效果处理（除外自己怪兽并破坏对方卡片，并注册结束阶段返回场上的效果）
function c65959844.desop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 提示玩家选择要除外的怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 玩家选择自己场上1只处于再1次召唤状态的二重怪兽
	local g=Duel.SelectMatchingCard(tp,c65959844.rmfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local rc=g:GetFirst()
	-- 将选中的二重怪兽因效果暂时除外，若成功除外则继续处理
	if rc and Duel.Remove(rc,0,REASON_EFFECT+REASON_TEMPORARY)~=0 and rc:IsLocation(LOCATION_REMOVED) then
		-- 获取作为破坏对象的卡
		local tc=Duel.GetFirstTarget()
		if tc:IsRelateToEffect(e) then
			-- 将作为对象的卡因效果破坏
			Duel.Destroy(tc,REASON_EFFECT)
		end
		rc:RegisterFlagEffect(65959844,RESET_PHASE+PHASE_END+RESET_OPPO_TURN,0,1)
		-- 直到对方结束阶段除外
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabelObject(rc)
		e1:SetCondition(c65959844.retcon)
		e1:SetOperation(c65959844.retop)
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN)
		-- 注册用于在对方结束阶段将除外怪兽返回场上的延迟效果
		Duel.RegisterEffect(e1,tp)
	end
end
-- 判定除外怪兽返回场上时点的条件函数
function c65959844.retcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定当前是否为对方回合，且被除外的怪兽仍带有特定的标记
	return Duel.GetTurnPlayer()==1-tp and e:GetLabelObject():GetFlagEffect(65959844)~=0
end
-- 执行除外怪兽返回场上的操作函数
function c65959844.retop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	-- 将暂时除外的怪兽返回到场上
	Duel.ReturnToField(tc)
end
