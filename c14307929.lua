--白き森の妖魔ディアベル
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡用同调怪兽调整为素材作同调召唤的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
-- ②：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己的额外卡组·墓地·除外状态的1只7星以下的同调怪兽调整特殊召唤。
local s,id,o=GetID()
-- 初始化效果函数
function s.initial_effect(c)
	-- 添加同调召唤手续，要求1只调整和1只调整以外的怪兽
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡用同调怪兽调整为素材作同调召唤的场合，以自己墓地1张魔法·陷阱卡为对象才能发动。那张卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：对方把魔法·陷阱·怪兽的效果发动时，从自己的手卡·场上把1张魔法·陷阱卡送去墓地才能发动。自己的额外卡组·墓地·除外状态的1只7星以下的同调怪兽调整特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_SPSUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id+o)
	e2:SetCondition(s.spcon)
	e2:SetCost(s.spcost)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
-- 判断是否为同调怪兽调整
function s.cfilter(c)
	return bit.band(c:GetType(),TYPE_SYNCHRO+TYPE_TUNER)==TYPE_SYNCHRO+TYPE_TUNER
end
-- 效果①的发动条件：确认是否为同调召唤且使用了调整作为素材
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetHandler():GetMaterial()
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and g:IsExists(s.cfilter,1,nil)
end
-- 过滤满足条件的魔法·陷阱卡
function s.filter(c)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToHand()
end
-- 效果①的目标选择函数
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.filter(chkc) end
	-- 检查是否满足效果①的目标条件
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 提示玩家选择目标
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	-- 选择目标魔法·陷阱卡
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 设置效果①的操作信息
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
-- 效果①的处理函数
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 获取效果①的目标卡
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		-- 将目标卡加入手牌
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end
-- 效果②的发动条件：对方发动效果时
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==1-tp
end
-- 判断是否满足效果②的费用条件
function s.costfilter(c,e,tp)
	return c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGraveAsCost()
		-- 检查是否存在满足条件的同调怪兽用于特殊召唤
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp,c)
end
-- 效果②的费用处理函数
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 检查是否满足效果②的费用条件
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,nil,e,tp) end
	-- 提示玩家选择送去墓地的魔法·陷阱卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	-- 选择送去墓地的魔法·陷阱卡
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,nil,e,tp)
	-- 将选中的魔法·陷阱卡送去墓地作为费用
	Duel.SendtoGrave(g,REASON_COST)
end
-- 判断是否满足特殊召唤的条件
function s.spfilter(c,e,tp,ec)
	return c:IsType(TYPE_SYNCHRO) and c:IsType(TYPE_TUNER)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and c:IsLevelBelow(7)
		-- 判断是否满足特殊召唤的场地条件（非额外区）
		and (not c:IsLocation(LOCATION_EXTRA) and c:IsFaceupEx() and Duel.GetMZoneCount(tp,ec)>0
			-- 判断是否满足特殊召唤的场地条件（额外区）
			or c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,ec,c)>0)
end
-- 效果②的目标选择函数
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	-- 设置效果②的操作信息
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED)
end
-- 效果②的处理函数
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 提示玩家选择特殊召唤的同调怪兽
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	-- 选择满足条件的同调怪兽
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_EXTRA+LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp,nil)
	if g:GetCount()>0 then
		-- 将选中的同调怪兽特殊召唤
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
