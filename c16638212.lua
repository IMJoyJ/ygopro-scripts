--異次元の精霊
-- 效果：
-- ①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
-- ②：这张卡的①的方法特殊召唤的场合，下次的准备阶段发动。为这张卡特殊召唤而除外的怪兽回到场上。
function c16638212.initial_effect(c)
	-- ①：这张卡可以把自己场上1只表侧表示怪兽除外，从手卡特殊召唤。
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
-- 检查候选怪兽是否满足作为特殊召唤手续代价的条件：必须表侧表示、可以作为代价除外，并且除外后自己场上仍有可用的怪兽区来特殊召唤这张卡。
function c16638212.spfilter(c,tp)
	-- 返回该怪兽是否满足：表侧表示、可作为代价除外，且除外后自己场上仍有空余怪兽区。
	return c:IsFaceup() and c:IsAbleToRemoveAsCost() and Duel.GetMZoneCount(tp,c)>0
end
-- 特殊召唤手续的发动条件：如果调用方未指定要特殊召唤的卡则视为规则询问（返回true）；否则检查自己场上是否存在至少1只满足代价条件的表侧表示怪兽。
function c16638212.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否存在至少1只满足代价条件的表侧表示怪兽。
	return Duel.IsExistingMatchingCard(c16638212.spfilter,tp,LOCATION_MZONE,0,1,nil,tp)
end
-- 选择要除外的怪兽作为特殊召唤的代价：从自己场上符合条件的表侧表示怪兽中选取1张，存入效果标签后返回true；未选择则返回false。
function c16638212.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取自己场上所有满足特殊召唤代价条件的表侧表示怪兽的集合。
	local g=Duel.GetMatchingGroup(c16638212.spfilter,tp,LOCATION_MZONE,0,nil,tp)
	-- 给玩家显示“请选择要除外的卡”的选择提示。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤手续：将选中的怪兽暂时除外并做标记，然后为这张卡设置一个在下一次准备阶段发动的返回效果，把因这次召唤而除外的怪兽送回场上。
function c16638212.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将之前选择的怪兽以“特殊召唤+暂时除外”的原因除外，使其成为暂时离场状态，以便后续用Duel.ReturnToField返回。
	Duel.Remove(tc,0,REASON_SPSUMMON+REASON_TEMPORARY)
	tc:RegisterFlagEffect(16638212,RESET_EVENT+RESETS_STANDARD,0,0)
	-- ②：这张卡的①的方法特殊召唤的场合，下次的准备阶段发动。为这张卡特殊召唤而除外的怪兽回到场上。
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
-- 准备阶段的诱发必发效果处理：检查之前被除外的怪兽是否仍带有标记，若还在暂时除外状态则将其返回场上。
function c16638212.retop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabelObject():GetFlagEffect(16638212)~=0 then
		-- 将被暂时除外的怪兽以离场前的表示形式返回其持有者的场上。
		Duel.ReturnToField(e:GetLabelObject())
	end
end
