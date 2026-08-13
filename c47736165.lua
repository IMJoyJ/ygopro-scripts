--水晶機巧－エレスケルタス
-- 效果：
-- 调整＋调整以外的怪兽1只以上
-- 这个卡名的①③的效果1回合各能使用1次。
-- ①：这张卡同调召唤的场合才能发动。自己的墓地·除外状态的1张「水晶机巧」卡加入手卡。
-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降500。
-- ③：同调召唤的这张卡被战斗·效果破坏的场合才能发动。自己的墓地·除外状态的1只「水晶机巧」怪兽特殊召唤。
local s,id,o=GetID()
-- 初始化方法：为卡片注册同调召唤手续、苏生限制，并注册①③两个1回合1次的诱发效果以及②的永续攻击·守备下降效果。
function s.initial_effect(c)
	-- 添加同调召唤手续：调整1只＋调整以外的怪兽1只以上。
	aux.AddSynchroProcedure(c,nil,aux.NonTuner(nil),1)
	c:EnableReviveLimit()
	-- ①：这张卡同调召唤的场合才能发动。自己的墓地·除外状态的1张「水晶机巧」卡加入手卡。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))  --"加入手卡"
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	-- ②：只要这张卡在怪兽区域存在，对方场上的怪兽的攻击力·守备力下降500。（此代码段实现攻击力下降部分）
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(-500)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e3)
	-- ③：同调召唤的这张卡被战斗·效果破坏的场合才能发动。自己的墓地·除外状态的1只「水晶机巧」怪兽特殊召唤。
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,1))  --"特殊召唤"
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_DESTROYED)
	e4:SetCountLimit(1,id+o)
	e4:SetCondition(s.spcon)
	e4:SetTarget(s.sptg)
	e4:SetOperation(s.spop)
	c:RegisterEffect(e4)
end
-- ①效果的发动条件：这张卡进行的是同调召唤（召唤类型为SUMMON_TYPE_SYNCHRO）的场合才能发动。
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO)
end
-- ①效果的选卡过滤：选择的卡必须是「水晶机巧」卡，且可以被加入手卡。
function s.thfilter(c)
	return c:IsFaceupEx() and c:IsSetCard(0xea) and c:IsAbleToHand()
end
-- ①效果的发动目标判定：检查自己墓地·除外状态是否存在至少1张可加入手卡的「水晶机巧」卡；若存在则登记操作信息为把1张卡加入手卡。
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 发动合法性检查：自己墓地·除外状态存在至少1张满足s.thfilter的「水晶机巧」卡。
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil) end
	-- 登记本次操作信息：效果将把1张卡加入手卡，目标范围是自己墓地·除外状态。
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ①效果处理：从自己墓地·除外状态选择1张「水晶机巧」卡加入手卡，并让对方确认。
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	-- 显示选择提示：“请选择要加入手牌的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)  --"请选择要加入手牌的卡"
	-- 从自己墓地·除外状态选择1张满足条件的「水晶机巧」卡（使用王家长眠之谷过滤，排除不能移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil)
	if g:GetCount()>0 then
		-- 将选中的卡加入其持有者的手卡，移动原因是效果。
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		-- 将加入手卡的卡展示给对方玩家确认。
		Duel.ConfirmCards(1-tp,g)
	end
end
-- ③效果的发动条件：这张卡是被同调召唤过的卡，且在怪兽区域被战斗或效果破坏时才能发动。
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO) and r&(REASON_EFFECT+REASON_BATTLE)~=0
end
-- ③效果的选卡过滤：选择的卡必须是「水晶机巧」怪兽，且能够被效果特殊召唤。
function s.spfilter(c,e,tp)
	return c:IsFaceupEx() and c:IsSetCard(0xea) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
-- ③效果的发动目标判定：自己主要怪兽区有空位，且墓地·除外状态存在至少1只可特殊召唤的「水晶机巧」怪兽；满足则登记特殊召唤操作。
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	-- 合法性检查之一：自己场上存在可用的主要怪兽区域空格。
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		-- 合法性检查之二：墓地·除外状态存在至少1只满足s.spfilter的「水晶机巧」怪兽。
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp) end
	-- 登记本次操作信息：效果将特殊召唤1只怪兽，目标范围是自己墓地·除外状态。
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
-- ③效果处理：从自己墓地·除外状态选择1只「水晶机巧」怪兽，以表侧表示特殊召唤到自己的怪兽区域。
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	-- 处理时再次确认自己场上是否有可用怪兽区域；若没有则终止处理。
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	-- 显示选择提示：“请选择要特殊召唤的卡”。
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)  --"请选择要特殊召唤的卡"
	-- 从自己墓地·除外状态选择1只满足条件的「水晶机巧」怪兽（使用王家长眠之谷过滤，排除不能移动的卡）。
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		-- 将选中的「水晶机巧」怪兽以表侧表示特殊召唤到自己的怪兽区域（不检查召唤条件与苏生限制）。
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
