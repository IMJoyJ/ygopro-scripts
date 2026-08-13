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
-- 过滤条件：候选祭品必须是卡号80887952的「双子太阳 赫利俄斯」，并且解放后自己场上仍有空余怪兽区。
function c17286057.hspfilter(c,tp)
	return c:IsCode(80887952)
		-- 要求该「双子太阳 赫利俄斯」被解放后自己场上有空余怪兽区，且该卡是自己控制的或表侧表示，以保证可以解放。
		and Duel.GetMZoneCount(tp,c)>0 and (c:IsControler(tp) or c:IsFaceup())
end
-- 特殊召唤规则的条件：若c为空表示询问是否可用；否则检查自己场上是否存在满足hspfilter的1只可解放怪兽作为祭品。
function c17286057.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上（非上级召唤用）是否存在至少1只满足hspfilter且可解放的「双子太阳 赫利俄斯」用于祭品特殊召唤。
	return Duel.CheckReleaseGroupEx(tp,c17286057.hspfilter,1,REASON_SPSUMMON,false,nil,tp)
end
-- 选择要解放的「双子太阳 赫利俄斯」；若选到则将其存入效果标签并返回true，否则返回false。
function c17286057.hsptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上可解放（非上级召唤用）的怪兽组，并筛选出满足hspfilter的「双子太阳 赫利俄斯」作为候选。
	local g=Duel.GetReleaseGroup(tp,false,REASON_SPSUMMON):Filter(c17286057.hspfilter,nil,tp)
	-- 显示“请选择要解放的卡”的选择提示消息。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)  --"请选择要解放的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 特殊召唤规则处理：取出之前选择的「双子太阳 赫利俄斯」作为祭品解放，完成从手卡的特殊召唤手续。
function c17286057.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	-- 解放选中的「双子太阳 赫利俄斯」，作为这次特殊召唤的祭品。
	Duel.Release(g,REASON_SPSUMMON)
end
-- 过滤函数：用于统计除外区的表侧表示怪兽卡。
function c17286057.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_MONSTER)
end
-- 计算攻击力（守备力）数值：除外区表侧表示怪兽卡数量×300。
function c17286057.value(e,c)
	-- 返回除外区表侧表示怪兽卡数量乘以300，作为攻击力（守备力）的数值。
	return Duel.GetMatchingGroupCount(c17286057.filter,0,LOCATION_REMOVED,LOCATION_REMOVED,nil)*300
end
-- 诱发条件：这张卡因战斗破坏被送去墓地，且该事件发生在当前回合。
function c17286057.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 判定这张卡的送入墓地原因是战斗破坏，并且进入墓地的回合是当前回合。
	return e:GetHandler():IsReason(REASON_BATTLE) and e:GetHandler():GetTurnID()==Duel.GetTurnCount()
end
-- 效果发动的目标阶段：检查是否存在空余怪兽区以及这张卡是否可以被特殊召唤。
function c17286057.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- chk==0时，确认自己场上有可用怪兽区，且这张卡满足特殊召唤条件（苏生限制、召唤条件等）。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置操作信息：本效果将特殊召唤这张卡，供相关时点/效果检测（如星尘龙等）。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
-- 效果处理：若这张卡仍与效果关联且特殊召唤成功，则立即赋予其攻击力·守备力上升500的效果；最后完成特殊召唤处理。
function c17286057.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 确认墓地中的这张卡与当前效果仍有联系，并且可以以表侧表示特殊召唤到自己场上。
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		-- 攻击力·守备力上升500
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
	-- 完成特殊召唤处理并触发召唤成功时的时点。
	Duel.SpecialSummonComplete()
end
-- 额外攻击次数的条件：对方场上有怪兽存在时才适用。
function c17286057.atcon(e)
	-- 返回对方场上怪兽区是否存在怪兽；存在时允许再进行一次攻击。
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),0,LOCATION_MZONE)>0
end
