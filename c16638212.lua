--異次元の精霊
-- 效果：
-- ①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤的场合，下次的准备阶段发动。为这张卡特殊召唤而除外的怪兽回到场上。
function c16638212.initial_effect(c)
	-- 效果原文内容：①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c16638212.spcon)
	e1:SetTarget(c16638212.sptg)
	e1:SetOperation(c16638212.spop)
	c:RegisterEffect(e1)
end
-- 规则层面作用：过滤满足条件的场上怪兽，包括表侧表示、可作为除外费用、且有可用怪兽区。
function c16638212.spfilter(c,tp)
	-- 规则层面作用：检查目标怪兽是否满足表侧表示、可除外、且该玩家场上存在可用怪兽区。
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 效果原文内容：①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
function c16638212.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 规则层面作用：检查玩家场上是否存在满足条件的怪兽（表侧表示、可除外、有可用怪兽区）。
	return Duel.IsExistingMatchingCard(c16638212.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 效果原文内容：①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
function c16638212.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 规则层面作用：获取满足条件的场上怪兽数组，用于选择除外对象。
	local g=Duel.GetMatchingGroup(c16638212.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 规则层面作用：向玩家发送提示信息，提示选择要除外的卡。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 效果原文内容：②：这张卡的①的方法特殊召唤的场合，下次的准备阶段发动。为这张卡特殊召唤而除外的怪兽回到场上。
function c16638212.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 规则层面作用：将选中的怪兽以特殊召唤和暂时除外的方式从场上移除。
	Duel.Remove(tc,0,REASON_SPSUMMON+REASON_TEMPORARY)
	tc:RegisterFlagEffect(16638212,RESET_EVENT+RESETS_STANDARD,0,0)
	-- 效果原文内容：②：这张卡的①的方法特殊召唤的场合，下次的准备阶段发动。为这张卡特殊召唤而除外的怪兽回到场上。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(16638212,0))  --"返回场上"
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_PHASE+PHASE_STANDBY)
	e1:SetCountLimit(1)
	e1:SetReset(RESET_EVENT+0xff0000+RESET_PHASE+PHASE_STANDBY)
	e1:SetOperation(c16638212.retop)
	e1:SetLabelObject(tc)
	c:RegisterEffect(e1)
end
-- 规则层面作用：判断该怪兽是否具有标记效果，若有则在准备阶段将其返回场上。
function c16638212.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffect(16638212)~=0 then
		-- 规则层面作用：将该怪兽以原本表示形式返回到场上。
		Duel.ReturnToField(e:GetLabelObject())
	end
end
