--ヘリオス・トリス・メギストス
-- 效果：
-- 这张卡可以用自己场上的1只「双子太阳 赫利俄斯」作为祭品特殊召唤。这张卡的攻击力·守备力为从游戏中除外的怪兽卡数量×300的数值。这张卡被战斗破坏送去墓地的场合，结束阶段时攻击力·守备力上升500并特殊召唤。对方场上有怪兽存在的场合，只有1次可以继续进行攻击。
function c17286057.initial_effect(c)
	-- 这张卡可以用自己场上的1只「双子太阳 赫利俄斯」作为祭品特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c17286057.hspcon)
	e1:SetTarget(c17286057.hsptg)
	e1:SetOperation(c17286057.hspop)
	c:RegisterEffect(e1)
	-- 这张卡的攻击力·守备力为从游戏中除外的怪兽卡数量×300的数值。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetValue(c17286057.value)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
	-- 这张卡被战斗破坏送去墓地的场合，结束阶段时攻击力·守备力上升500并特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(17286057,0))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e4:SetCode(EVENT_PHASE+PHASE_END)
	e4:SetRange(LOCATION_GRAVE)
	e4:SetCountLimit(1)
	e4:SetCondition(c17286057.spcon)
	e4:SetTarget(c17286057.sptg)
	e4:SetOperation(c17286057.spop)
	c:RegisterEffect(e4)
	-- 对方场上有怪兽存在的场合，只有1次可以继续进行攻击。
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_EXTRA_ATTACK)
	e5:SetValue(1)
	e5:SetCondition(c17286057.atcon)
	c:RegisterEffect(e5)
end
-- 过滤满足条件的「双子太阳 赫利俄斯」卡片，用于特殊召唤的祭品检查。
function c17286057.hspfilter(c,tp)
	return c:IsCode(80887952)
		-- 检查该卡片是否在场上且有可用怪兽区。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 检查是否有满足条件的「双子太阳 赫利俄斯」可作为祭品进行特殊召唤。
function c17286057.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 调用CheckReleaseGroupEx函数检查是否满足特殊召唤条件。
	return Duel.CheckReleaseGroupEx(tp,c17286057.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择并确认要解放的「双子太阳 赫利俄斯」卡片。
function c17286057.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取玩家可解放的「双子太阳 赫利俄斯」卡片组。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c17286057.hspfilter,nil,tp)
	-- 提示玩家选择要解放的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行解放操作，将选中的卡片从场上移除。
function c17286057.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 实际执行解放操作。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤场上正面表示的怪兽卡片。
function c17286057.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算场上正面表示的怪兽数量并乘以300作为攻击力和守备力。
function c17286057.value(e,c)
	-- 获取从游戏中除外的怪兽卡数量并乘以300。
	return Duel.GetMatchingGroupCount(c17286057.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
-- 判断该卡是否因战斗破坏而进入墓地且为当前回合。
function c17286057.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判断该卡是否因战斗破坏而进入墓地且为当前回合。
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end
-- 判断是否可以将该卡特殊召唤。
function c17286057.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查玩家场上是否有足够的怪兽区。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置特殊召唤的操作信息。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 执行特殊召唤后的处理，包括攻击力和守备力上升500。
function c17286057.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 判断该卡是否可以特殊召唤并开始特殊召唤步骤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 设置特殊召唤后攻击力上升500的效果。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		c:RegisterEffect(e2)
	end
	-- 完成特殊召唤流程。
	Duel.SpecialSummonComplete()
end
-- 判断对方场上是否有怪兽存在。
function c17286057.atcon(e)
	-- 获取对方场上的怪兽数量。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
