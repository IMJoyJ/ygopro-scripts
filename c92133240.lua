--ダイノルフィア・テリジア
-- 效果：
-- 这个卡名的①②的效果1回合各能使用1次。
-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1张「恐啡肽狂龙」陷阱卡在自己的魔法与陷阱区域盖放。自己基本分是2000以下的场合，再让这张卡的攻击力上升500。
-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·镰刀龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
function c92133240.initial_effect(c)
	-- ①：这张卡召唤·特殊召唤成功的场合才能发动。从卡组选1张「恐啡肽狂龙」陷阱卡在自己的魔法与陷阱区域盖放。自己基本分是2000以下的场合，再让这张卡的攻击力上升500。
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O+CATEGORY_SSET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,92133240)
	e1:SetTarget(c92133240.sstg)
	e1:SetOperation(c92133240.ssop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	-- ②：这张卡被战斗·效果破坏的场合，从自己墓地把1张陷阱卡除外才能发动。从自己墓地选「恐啡肽狂龙·镰刀龙」以外的1只4星以下的「恐啡肽狂龙」怪兽特殊召唤。
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_DESTROYED)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCountLimit(1,92133241)
	e3:SetCondition(c92133240.spcon)
	e3:SetCost(c92133240.spcost)
	e3:SetTarget(c92133240.sptg)
	e3:SetOperation(c92133240.spop)
	c:RegisterEffect(e3)
end
-- 过滤条件：卡组中可以盖放的「恐啡肽狂龙」陷阱卡
function c92133240.ssfilter(c)
	return c:IsSetCard(0x173) and c:IsType(TYPE_TRAP) and c:IsSSetable()
end
-- ①效果的发动准备：检查魔法与陷阱区域是否有空位，以及卡组中是否存在可盖放的「恐啡肽狂龙」陷阱卡
function c92133240.sstg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动准备：检查自己的魔法与陷阱区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_SZONE)>0
		-- 以及卡组中是否存在至少1张满足过滤条件的卡
		and Duel.IsExistingMatchingCard(c92133240.ssfilter,tp,LOCATION_DECK,0,1,nil) end
end
-- ①效果的处理：从卡组选1张「恐啡肽狂龙」陷阱卡盖放，若自己基本分为2000以下则再让这张卡攻击力上升500
function c92133240.ssop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的魔法与陷阱区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_SZONE)<=0 then return end
	local c=e:GetHandler()
	-- 给玩家发送提示信息：请选择要盖放的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)  --"请选择要盖放的卡"
	-- 从卡组选择1张满足过滤条件的「恐啡肽狂龙」陷阱卡
	local g=Duel.SelectMatchingCard(tp,c92133240.ssfilter,tp,LOCATION_DECK,0,1,1,nil)
	local tc=g:GetFirst()
	-- 若成功盖放，且自己基本分为2000以下，且这张卡在场上表侧表示存在
	if tc and Duel.SSet(tp,tc)~=0 and Duel.GetLP(tp)<=2000 and c:IsRelateToEffect(e) and c:IsFaceup() then
		-- 中断当前效果，使后续的攻击力上升处理不与盖放同时处理
		Duel.BreakEffect()
		-- 再让这张卡的攻击力上升500。
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(500)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_DISABLE)
		c:RegisterEffect(e1)
	end
end
-- ②效果的发动条件：这张卡被战斗或效果破坏
function c92133240.spcon(e,tp,eg,ep,ev,re,r,rp)
	return bit.band(r,REASON_EFFECT+REASON_BATTLE)~=0
end
-- 过滤条件：自己墓地中可以除外的陷阱卡
function c92133240.costfilter(c)
	return c:IsType(TYPE_TRAP) and c:IsAbleToRemoveAsCost()
end
-- ②效果的费用：从自己墓地把1张陷阱卡除外
function c92133240.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 费用检查：检查自己墓地是否存在至少1张可以除外的陷阱卡
	if chk==0 then return Duel.IsExistingMatchingCard(c92133240.costfilter,tp,LOCATION_GRAVE,0,1,nil) end
	-- 给玩家发送提示信息：请选择要除外的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)  --"请选择要除外的卡"
	-- 从自己墓地选择1张满足过滤条件的陷阱卡
	local g=Duel.SelectMatchingCard(tp,c92133240.costfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	-- 将选择的卡表侧表示除外作为发动费用
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
-- 过滤条件：自己墓地中「恐啡肽狂龙·镰刀龙」以外的1只4星以下的「恐啡肽狂龙」怪兽
function c92133240.spfilter(c,e,tp)
	return c:IsSetCard(0x173) and not c:IsCode(92133240) and c:IsLevelBelow(4) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ②效果的发动准备：检查怪兽区域是否有空位，以及墓地中是否存在满足特殊召唤条件的怪兽
function c92133240.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动准备：检查自己的怪兽区域是否有空位
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 以及墓地中是否存在至少1张满足过滤条件的怪兽
		and Duel.IsExistingMatchingCard(c92133240.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	-- 设置连锁信息：包含从墓地特殊召唤1只怪兽的操作
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
-- ②效果的处理：从自己墓地选择1只满足过滤条件的怪兽特殊召唤
function c92133240.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 检查自己的怪兽区域是否有空位，若无则不处理
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 给玩家发送提示信息：请选择要特殊召唤的卡
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地选择1张满足过滤条件的怪兽
	local g=Duel.SelectMatchingCard(tp,c92133240.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选择的怪兽以表侧表示特殊召唤到自己场上
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
