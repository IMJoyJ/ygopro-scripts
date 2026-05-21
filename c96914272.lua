--虚栄の大猿
-- 效果：
-- 这张卡不能通常召唤。从手卡把1只兽族怪兽送去墓地的场合可以特殊召唤。这个方法特殊召唤成功时，可以把送去墓地的那只兽族怪兽的等级确认，从下面效果选择1个发动。
-- ●这张卡的等级上升那个等级数值。
-- ●这张卡的等级下降那个等级数值。
function c96914272.initial_effect(c)
	c:EnableReviveLimit()
	-- 这张卡不能通常召唤。从手卡把1只兽族怪兽送去墓地的场合可以特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetRange(LOCATION_HAND)
	e1:SetCondition(c96914272.spcon)
	e1:SetTarget(c96914272.sptg)
	e1:SetOperation(c96914272.spop)
	e1:SetValue(SUMMON_VALUE_SELF)
	c:RegisterEffect(e1)
	-- 这个方法特殊召唤成功时，可以把送去墓地的那只兽族怪兽的等级确认，从下面效果选择1个发动。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(96914272,0))  --"选择效果发动"
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(c96914272.lvcon)
	e2:SetOperation(c96914272.lvop)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
end
-- 过滤手卡中可以作为特殊召唤手续送去墓地的兽族怪兽
function c96914272.spfilter(c)
	return c:IsRace(RACE_BEAST) and c:IsAbleToGraveAsCost()
end
-- 检查自身特殊召唤的条件是否满足（场上有空位且手卡有满足条件的兽族怪兽）
function c96914272.spcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	-- 检查自己场上是否有可用的怪兽区域
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 检查手卡中是否存在至少1只除自身以外可以送去墓地的兽族怪兽
		and Duel.IsExistingMatchingCard(c96914272.spfilter,tp,LOCATION_HAND,0,1,c)
end
-- 特殊召唤的准备阶段，让玩家选择要送去墓地的兽族怪兽，并将其记录在效果对象中
function c96914272.sptg(e,tp,eg,ep,ev,re,r,rp,chk,c)
	-- 获取手卡中除自身以外所有可以作为特殊召唤手续送去墓地的兽族怪兽
	local g=Duel.GetMatchingGroup(c96914272.spfilter,tp,LOCATION_HAND,0,c)
	-- 提示玩家选择要送去墓地的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)  --"请选择要送去墓地的卡"
	local tc=g:SelectUnselect(nil,tp,false,true,1,1)
	if tc then
		e:SetLabelObject(tc)
		return true
	else return false end
end
-- 执行特殊召唤的动作，将选定的兽族怪兽送去墓地，并记录其等级
function c96914272.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local tc=e:GetLabelObject()
	-- 将作为特殊召唤手续的兽族怪兽送去墓地
	Duel.SendtoGrave(tc,REASON_SPSUMMON)
	e:SetLabel(tc:GetLevel())
end
-- 检查此卡是否是通过自身特殊召唤规则特殊召唤成功
function c96914272.lvcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetSummonType()==SUMMON_TYPE_SPECIAL+SUMMON_VALUE_SELF
end
-- 确认送去墓地的兽族怪兽的等级，并根据情况让玩家选择让此卡的等级上升或下降该数值
function c96914272.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		local lv=e:GetLabelObject():GetLabel()
		local clv=c:GetLevel()
		-- ●这张卡的等级上升那个等级数值。●这张卡的等级下降那个等级数值。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		if lv<clv then
			-- 当送去墓地的怪兽等级小于此卡当前等级时，让玩家选择等级上升或下降
			if Duel.SelectOption(tp,aux.Stringid(96914272,1),aux.Stringid(96914272,2))==0 then  --"等级上升送去墓地的兽族怪兽的等级/等级下降送去墓地的兽族怪兽的等级"
				e1:SetValue(lv)
			else e1:SetValue(-lv) end
		else
			-- 当送去墓地的怪兽等级大于或等于此卡当前等级时，由于等级不能降为0或负数，强制玩家选择等级上升
			Duel.SelectOption(tp,aux.Stringid(96914272,1))  --"等级上升送去墓地的兽族怪兽的等级"
			e1:SetValue(lv)
		end
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
