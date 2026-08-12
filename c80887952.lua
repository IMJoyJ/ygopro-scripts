--ヘリオス・デュオ・メギストス
-- 效果：
-- 这张卡可以用自己场上的1只「原始太阳 赫利俄斯」作为祭品特殊召唤。这张卡的攻击力·守备力为从游戏中除外的怪兽卡数量×200的数值。这张卡被战斗破坏送去墓地的场合，结束阶段时攻击力·守备力上升300并特殊召唤。
function c80887952.initial_effect(c)
	-- 这张卡可以用自己场上的1只「原始太阳 赫利俄斯」作为祭品特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c80887952.hspcon)
	e1:SetTarget(c80887952.hsptg)
	e1:SetOperation(c80887952.hspop)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力为从游戏中除外的怪兽卡数量×200的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(c80887952.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏送去墓地的场合，结束阶段时攻击力·守备力上升300并特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(80887952,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c80887952.spcon)
	e4:SetTarget(c80887952.sptg)
	e4:SetOperation(c80887952.spop)
	c:RegisterEffect(e4)
end
-- 过滤自己场上用于特殊召唤的「原始太阳 赫利俄斯」
function c80887952.hspfilter(c,tp)
	return c:IsCode(54493213)
		-- 检查该卡解放后是否能空出怪兽区域，且该卡由自己控制或是表侧表示
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件函数，检查场上是否存在可解放的「原始太阳 赫利俄斯」
function c80887952.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查场上是否存在至少1只满足特殊召唤过滤条件的可解放怪兽
	return Duel.CheckReleaseGroupEx(tp,c80887952.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 特殊召唤规则的目标选择函数，选择要解放的怪兽
function c80887952.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取场上可解放的怪兽组，并过滤出满足特殊召唤条件的卡
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c80887952.hspfilter,nil,tp)
	-- 给玩家发送“请选择要解放的卡”的提示信息
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则的执行操作函数，解放选定的怪兽
function c80887952.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选定的怪兽
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤除外区表侧表示的怪兽卡
function c80887952.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 攻击力·守备力数值计算函数
function c80887952.value(e,c)
	-- 返回双方除外区表侧表示的怪兽卡数量乘以200的数值
	return Duel.GetMatchingGroupCount(c80887952.filter,c:GetControler(),LOCATION_REMOVED,LOCATION_REMOVED,nil)*200
end
-- 结束阶段特殊召唤效果的发动条件函数
function c80887952.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自身是否因战斗破坏，且是否在被破坏的当个回合
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end
-- 结束阶段特殊召唤效果的目标选择与检测函数
function c80887952.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否有空余的怪兽区域
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤自身的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 结束阶段特殊召唤效果的执行操作函数
function c80887952.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试以表侧表示特殊召唤自身
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力上升300
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(300)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤的后续处理
	Duel.SpecialSummonComplete()
end
