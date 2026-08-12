--Emウィンド・サッカー
-- 效果：
-- ←4 【灵摆】 4→
-- ①：1回合1次，可以以自己场上1只「娱乐法师」灵摆怪兽为对象，从以下效果选择1个发动。
-- ●作为对象的怪兽的等级下降1星。
-- ●这张卡的灵摆刻度上升作为对象的怪兽的灵摆刻度数值。
-- 【怪兽效果】
-- 这个卡名的①的怪兽效果1回合只能使用1次。
-- ①：对方场上有怪兽存在的场合或者场上有「娱乐法师」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。只要这个效果特殊召唤的这张卡在怪兽区域存在，自己不是「娱乐法师」怪兽不能特殊召唤。
-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级下降1星。
-- ③：1回合1次，可以发动。自己场上的全部4星「娱乐法师」怪兽的等级变成5星。
local s,id,o=GetID()
-- 注册卡片效果的初始化函数，包含灵摆效果、手卡特殊召唤、特召成功时降星、场上4星「娱乐法师」变5星的效果。
function s.initial_effect(c)
	-- 启用灵摆怪兽的灵摆属性（注册灵摆召唤和灵摆卡的发动）。
	aux.EnablePendulumAttribute(c)
	-- ①：1回合1次，可以以自己场上1只「娱乐法师」灵摆怪兽为对象，从以下效果选择1个发动。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1)
	e1:SetTarget(s.lvtg)
	e1:SetOperation(s.lvop)
	c:RegisterEffect(e1)
	-- ①：对方场上有怪兽存在的场合或者场上有「娱乐法师」怪兽存在的场合才能发动。这张卡从手卡特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))  --"特殊召唤"
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	-- ②：这张卡特殊召唤的场合才能发动。这张卡的等级下降1星。
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,3))  --"下降等级"
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetTarget(s.lvtg2)
	e3:SetOperation(s.lvop2)
	c:RegisterEffect(e3)
	-- ③：1回合1次，可以发动。自己场上的全部4星「娱乐法师」怪兽的等级变成5星。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,4))  --"改变等级"
	e4:SetType(EFFECT_TYPE_IGNITION)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCountLimit(1)
	e4:SetTarget(s.lvtg3)
	e4:SetOperation(s.lvop3)
	c:RegisterEffect(e4)
end
-- 过滤自己场上表侧表示的「娱乐法师」灵摆怪兽，且其等级至少为2或灵摆刻度大于0。
function s.lvfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6) and c:IsType(TYPE_PENDULUM)
		and (c:IsLevelAbove(2) or c:GetLeftScale()>0)
end
-- 灵摆效果的发动准备（检查并选择自己场上1只「娱乐法师」灵摆怪兽作为对象，并根据其状态让玩家选择发动哪个分支效果）。
function s.lvtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.lvfilter(chkc) end
	-- 检查自己场上是否存在可以作为对象的「娱乐法师」灵摆怪兽。
	if chk==0 then return Duel.IsExistingTarget(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) end
	-- 提示玩家选择表侧表示的卡片。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)  --"请选择表侧表示的卡"
	-- 玩家选择1只符合条件的怪兽作为效果的对象。
	local g=Duel.SelectTarget(tp,s.lvfilter,tp,LOCATION_MZONE,0,1,1,nil)
	local tc=g:GetFirst()
	local off=1
	local ops={}
	local opval={}
	if tc:IsLevelAbove(2) then
		ops[off]=aux.Stringid(id,0)  --"下降等级"
		opval[off-1]=1
		off=off+1
	end
	if tc:GetLeftScale()>0 then
		ops[off]=aux.Stringid(id,1)  --"上升刻度"
		opval[off-1]=2
		off=off+1
	end
	-- 让玩家在可用的分支效果中选择一个发动。
	local op=Duel.SelectOption(tp,table.unpack(ops))
	e:SetLabel(opval[op])
end
-- 灵摆效果的实际处理（根据玩家的选择，使对象怪兽等级下降1星，或者使这张卡的灵摆刻度上升对象怪兽的刻度数值）。
function s.lvop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local op=e:GetLabel()
	-- 获取当前连锁中被选择的对象怪兽。
	local tc=Duel.GetFirstTarget()
	if op==1 then
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and tc:IsLevelAbove(2) then
			-- ●作为对象的怪兽的等级下降1星。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			e1:SetValue(-1)
			tc:RegisterEffect(e1)
		end
	elseif op==2 then
		if tc:IsFaceup() and tc:IsRelateToEffect(e) and tc:IsType(TYPE_MONSTER) and c:IsRelateToEffect(e) then
			local ct=tc:GetLeftScale()
			-- ●这张卡的灵摆刻度上升作为对象的怪兽的灵摆刻度数值。
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LSCALE)
			e1:SetValue(ct)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_RSCALE)
			c:RegisterEffect(e2)
		end
	end
end
-- 过滤场上表侧表示的「娱乐法师」怪兽。
function s.cfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xc6)
end
-- 检查手卡特殊召唤效果的发动条件（对方场上有怪兽存在，或者场上有「娱乐法师」怪兽存在）。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	-- 检查场上是否存在「娱乐法师」怪兽。
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil)
		-- 或者检查对方场上是否存在怪兽。
		or Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_MZONE,1,nil)
end
-- 手卡特殊召唤效果的发动准备（检查怪兽区域是否有空位，以及自身是否能特殊召唤）。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	-- 检查自己场上的主要怪兽区域是否有空位。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	-- 设置连锁的操作信息为特殊召唤自身。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end
-- 手卡特殊召唤效果的实际处理（将自身特殊召唤，并注册“自己不是「娱乐法师」怪兽不能特殊召唤”的限制）。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	-- 检查自身是否仍与效果相关，并尝试将自身以表侧表示特殊召唤。
	if c:IsRelateToEffect(e) and Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)>0 then
		-- 只要这个效果特殊召唤的这张卡在怪兽区域存在，自己不是「娱乐法师」怪兽不能特殊召唤。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetRange(LOCATION_MZONE)
		e1:SetAbsoluteRange(tp,1,0)
		e1:SetTarget(s.splimit)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		c:RegisterEffect(e1,true)
	end
end
-- 限制只能特殊召唤「娱乐法师」怪兽。
function s.splimit(e,c)
	return not c:IsSetCard(0xc6)
end
-- 特召成功时降星效果的发动准备（检查自身等级是否至少为2）。
function s.lvtg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsLevelAbove(2) end
end
-- 特召成功时降星效果的实际处理（使自身等级下降1星）。
function s.lvop2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) and not c:IsImmuneToEffect(e) and c:IsLevelAbove(2) then
		-- 这张卡的等级下降1星。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_LEVEL)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		e1:SetValue(-1)
		c:RegisterEffect(e1)
	end
end
-- 过滤自己场上表侧表示的4星「娱乐法师」怪兽。
function s.lvfilter3(c)
	return c:IsFaceup() and c:IsLevel(4) and c:IsSetCard(0xc6)
end
-- 场上4星「娱乐法师」变5星效果的发动准备（检查自己场上是否存在4星「娱乐法师」怪兽）。
function s.lvtg3(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查自己场上是否存在4星「娱乐法师」怪兽。
	if chk==0 then return Duel.IsExistingMatchingCard(s.lvfilter3,tp,LOCATION_MZONE,0,1,nil) end
end
-- 场上4星「娱乐法师」变5星效果的实际处理（获取自己场上所有的4星「娱乐法师」怪兽，并将其等级全部变成5星）。
function s.lvop3(e,tp,eg,ep,ev,re,r,rp)
	-- 获取自己场上所有表侧表示的4星「娱乐法师」怪兽。
	local g=Duel.GetMatchingGroup(s.lvfilter3,tp,LOCATION_MZONE,0,nil)
	-- 遍历获取到的怪兽组。
	for tc in aux.Next(g) do
		-- 自己场上的全部4星「娱乐法师」怪兽的等级变成5星。
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_CHANGE_LEVEL)
		e1:SetValue(5)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
	end
end
